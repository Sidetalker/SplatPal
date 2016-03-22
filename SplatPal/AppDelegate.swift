//
//  AppDelegate.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/9/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import XCGLogger
import Doorbell
import Fabric
import Crashlytics
import SwiftyJSON
import Alamofire
import Armchair

let log = XCGLogger.defaultInstance()
let feedback = Doorbell(apiKey: "huNJHAdBmvWXZKIMHrdYjdZ0XZJEL03aReY71ASNWY8hhguVXb2oZhLMD5ji8ERv", appId: "2756")

var brandData = [JSON]()
var gearData = [Gear]()
var weaponData = [JSON]()
var mapData = [String]()
var modeData = [String]()
var abilityData = [String : JSON]()
var abilityDataEnum = [String]()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Configure Fabric modules
        Fabric.with([Crashlytics.self])
        
        // Intialize Armchair
        Armchair.appID("1067040948")
        Armchair.daysUntilPrompt(7)
        Armchair.usesUntilPrompt(5)
        
        // Initialize XCGLogger
        log.setup(.Debug, showLogIdentifier: false, showFunctionName: false, showThreadName: false, showLogLevel: true, showFileNames: true, showLineNumbers: false, showDate: false, writeToFile: nil, fileLogLevel: nil)
        
        // Configure Doorbell feedback prefs
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String
        let build = NSBundle.mainBundle().infoDictionary?[kCFBundleVersionKey as String] as! String

        feedback.addPropertyWithName("Version", andValue: "\(version) (\(build))")
        
        let defaultPrefsFile = NSBundle.mainBundle().pathForResource("UserDefaults", ofType: "plist")
        let defaultPrefs = NSDictionary(contentsOfFile: defaultPrefsFile!) as? [String : AnyObject]
        
        // Register user default store
        NSUserDefaults.standardUserDefaults().registerDefaults(defaultPrefs!)
        
        // Load map/gear/weapon/etc data
        loadJSONData()
        
        // Configure NNID cookies
        let nnid = NNID.sharedInstance
        
        if !nnid.saveLogin {
            nnid.clearCookies()
        }
        else {
            if let cookie = nnid.cookieObj {
                Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.setCookie(NSHTTPCookie(properties: cookie)!)
            } else { loginNNID { error in } }
        }
        
        // Prepare tab bar
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        
        return true
    }
    
    func loadJSONData() {
        if let
            brandPath = NSBundle.mainBundle().pathForResource("data.min", ofType: "json"),
            jsonData = NSData(contentsOfFile: brandPath)
        {
            let jsonResult = JSON(data: jsonData)
            let preferredLanguage = NSLocale.preferredLanguages()[0]
            var localeMod = ""
            
            if (preferredLanguage != "en-US" && preferredLanguage != "en") {
                localeMod = "eu"
            }
            
            brandData = jsonResult["brands"].arrayValue
            gearData = jsonResult["gear"].arrayValue.map({ Gear(data: $0, locale: localeMod) })
            gearData.sortInPlace { $0.localizedName < $1.localizedName }
            weaponData = jsonResult["weapons"].arrayValue
            abilityData = jsonResult["abilities"].dictionaryValue
            mapData = jsonResult["maps"].arrayObject as! [String]
            modeData = jsonResult["modes"].arrayObject as! [String]
            abilityDataEnum = jsonResult["abilitiesEnum"].arrayObject as! [String]
            
            // Ugly hardcoded hack to fix Museum D'Alfonsino escape char
            mapData[12] = mapData[12].replace("\\", replacement: "")
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        NSNotificationCenter.defaultCenter().postNotificationName("localNotificationsStateUpdated", object: nil)
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if
            let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems,
            let name = queryItems[0].value,
            let data = queryItems[1].value,
            let tabBarController = self.window!.rootViewController! as? UITabBarController
        {
            if !isValidLoadout(data) { return false }
            
            for (x, vc) in tabBarController.viewControllers!.enumerate() {
                if let loadoutView = vc as? LoadoutViewController {
                    if let tableView = loadoutView.loadoutTVC {
                        tableView.importLoadout(name, data: data)
                    } else {
                        loadoutView.importLoadout(name, data: data)
                    }
                    
                    tabBarController.selectedIndex = x
                    
                    return true
                }
            }
        }
        
        return false
    }
}

