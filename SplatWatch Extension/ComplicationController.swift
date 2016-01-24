//
//  ComplicationController.swift
//  SplatWatch Extension
//
//  Created by Kevin Sullivan on 1/16/16.
//  Copyright © 2016 Kevin Sullivan. All rights reserved.
//

import ClockKit
import SwiftyJSON

extension NSDate {
    func isAfterDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isBeforeDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addMinutes(minutesToAdd: Int) -> NSDate {
        let secondsInMinutes: NSTimeInterval = Double(minutesToAdd) * 60
        let dateWithMinutesAdded: NSDate = self.dateByAddingTimeInterval(secondsInMinutes)
        
        //Return Result
        return dateWithMinutesAdded
    }
}

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.Forward])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        // Call the handler with the current timeline entry
        var template: CLKComplicationTemplate? = nil
        
        let data = loadData()
        let mode = data["rankedModes"][0].stringValue
        let modeImage = getImageForMode(mode)
        
        switch complication.family {
        case .ModularSmall:
            let newTemplate = CLKComplicationTemplateModularSmallRingImage()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: modeImage)
            template = newTemplate
        case .ModularLarge:
            let endTime = data["endTimes"][0].doubleValue
            let fractionalHour = (endTime - NSDate().timeIntervalSince1970) / 60 / 60 % 1
            var modeText = "Error"
            var map1Text = "Error"
            var map2Text = "Error"
            
            if fractionalHour > 0.5 {
                modeText = mode
                map1Text = data["rankedMaps"][0].stringValue
                map2Text = data["rankedMaps"][1].stringValue
            } else {
                modeText = "Turf War"
                map1Text = data["turfMaps"][0].stringValue
                map2Text = data["turfMaps"][1].stringValue
            }
            
            let newTemplate = CLKComplicationTemplateModularLargeStandardBody()
            newTemplate.headerTextProvider = CLKSimpleTextProvider(text: modeText)
            newTemplate.body1TextProvider = CLKSimpleTextProvider(text: map1Text)
            newTemplate.body2TextProvider = CLKSimpleTextProvider(text: map2Text)
            template = newTemplate
        case .UtilitarianSmall:
            let endTime = data["endTimes"][0].doubleValue
            let changeTime = NSDate(timeIntervalSince1970: NSTimeInterval(endTime))
            let newTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: modeImage)
            newTemplate.textProvider = CLKRelativeDateTextProvider(date: changeTime, style: .Timer, units: [.Hour, .Minute, .Second])
            template = newTemplate
        case .UtilitarianLarge:
            let endTime = data["endTimes"][0].doubleValue
            let changeTime = NSDate(timeIntervalSince1970: NSTimeInterval(endTime))
            let newTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: modeImage)
            newTemplate.textProvider = CLKRelativeDateTextProvider(date: changeTime, style: .Timer, units: [.Hour, .Minute, .Second])
            template = newTemplate
        case .CircularSmall:
            let newTemplate = CLKComplicationTemplateCircularSmallSimpleImage()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: modeImage)
            template = newTemplate
        }
        
        handler(CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template!))
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        var entries = [CLKComplicationTimelineEntry]()
        let data = loadData()
        
        switch complication.family {
        case .ModularSmall:
            var x = 1
            
            while x <= limit && x <= 2 {
                if let start = data["startTimes"][x].double {
                    let startDate = NSDate(timeIntervalSince1970: start)
                    
                    if !startDate.isBeforeDate(date)  {
                        let newTemplate = CLKComplicationTemplateModularSmallSimpleImage()
                        newTemplate.imageProvider = CLKImageProvider(onePieceImage: getImageForMode(data["rankedModes"][x].stringValue))
                        entries.append(CLKComplicationTimelineEntry(date: startDate, complicationTemplate: newTemplate))
                    }
                }
                
                x += 1
            }
        case .ModularLarge:
            var x = 0
            
            while x <= 2 {
                if let
                    start = data["startTimes"][x].double,
                    mode = data["rankedModes"][x].string,
                    rankedMap1 = data["rankedMaps"][x * 2].string,
                    rankedMap2 = data["rankedMaps"][x * 2 + 1].string,
                    turfMap1 = data["turfMaps"][x * 2].string,
                    turfMap2 = data["turfMaps"][x * 2 + 1].string
                {
                    var currentDate = NSDate(timeIntervalSince1970: start)
                    
                    for y in 0...7 {
                        if currentDate.isBeforeDate(date) {
                            currentDate = currentDate.addMinutes(30)
                            continue
                        }
                        
                        let template = CLKComplicationTemplateModularLargeStandardBody()
                        
                        if y % 2 == 1 {
                            template.headerTextProvider = CLKSimpleTextProvider(text: mode)
                            template.body1TextProvider = CLKSimpleTextProvider(text: rankedMap1)
                            template.body2TextProvider = CLKSimpleTextProvider(text: rankedMap2)
                        } else {
                            template.headerTextProvider = CLKSimpleTextProvider(text: "Turf War")
                            template.body1TextProvider = CLKSimpleTextProvider(text: turfMap1)
                            template.body2TextProvider = CLKSimpleTextProvider(text: turfMap2)
                        }
                        
                        entries.append(CLKComplicationTimelineEntry(date: currentDate, complicationTemplate: template))
                        currentDate = currentDate.addMinutes(30)
                    }
                }
                
                x += 1
            }
//        case .UtilitarianSmall:
//            let endTime = data["endTimes"][0].doubleValue
//            let changeTime = NSDate(timeIntervalSince1970: NSTimeInterval(endTime))
//            let newTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
//            newTemplate.imageProvider = CLKImageProvider(onePieceImage: modeImage)
//            newTemplate.textProvider = CLKRelativeDateTextProvider(date: changeTime, style: .Timer, units: [.Hour, .Minute, .Second])
//            template = newTemplate
//        case .UtilitarianLarge:
//            let endTime = data["endTimes"][0].doubleValue
//            let changeTime = NSDate(timeIntervalSince1970: NSTimeInterval(endTime))
//            let newTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
//            newTemplate.imageProvider = CLKImageProvider(onePieceImage: modeImage)
//            newTemplate.textProvider = CLKRelativeDateTextProvider(date: changeTime, style: .Timer, units: [.Hour, .Minute, .Second])
//            template = newTemplate
//        case .CircularSmall:
//            let newTemplate = CLKComplicationTemplateCircularSmallSimpleImage()
//            newTemplate.imageProvider = CLKImageProvider(onePieceImage: modeImage)
//            template = newTemplate
        default:
            break
        }
        
        handler(entries)
    }
    
    func loadData() -> JSON {
        let path = getDocumentsDirectory().stringByAppendingPathComponent("dataBuffer.json")
        
        if let jsonData = NSData(contentsOfFile: path) {
            return JSON(data: jsonData)
        }
        
        return JSON([:])
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getImageForMode(mode: String) -> UIImage {
        if mode == "Rainmaker" {
            return UIImage(named: "rainmakerIcon")!
        }
        else if mode == "Splat Zones" {
            return UIImage(named: "zonesIcon")!
        }
        else if mode == "Tower Control" {
            return UIImage(named: "towerIcon")!
        }
        
        return UIImage(named: "squidIcon")!
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        let data = loadData()
        let nextUpdateEpoch = data["endTimes"][0].doubleValue as NSTimeInterval
        
        handler(NSDate(timeIntervalSince1970: nextUpdateEpoch))
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        var template: CLKComplicationTemplate? = nil
        switch complication.family {
        case .ModularSmall:
            let newTemplate = CLKComplicationTemplateModularSmallSimpleImage()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "squidIcon.png")!)
            template = newTemplate
        case .ModularLarge:
            let newTemplate = CLKComplicationTemplateModularLargeStandardBody()
            newTemplate.headerTextProvider = CLKSimpleTextProvider(text: "Ranked Mode")
            newTemplate.body1TextProvider = CLKSimpleTextProvider(text: "Map 1")
            newTemplate.body2TextProvider = CLKSimpleTextProvider(text: "Map 2")
            template = newTemplate
        case .UtilitarianSmall:
            let newTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "squidIcon.png")!)
            newTemplate.textProvider = CLKSimpleTextProvider(text: "00:00:00")
            template = newTemplate
        case .UtilitarianLarge:
            let newTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "squidIcon.png")!)
            newTemplate.textProvider = CLKSimpleTextProvider(text: "00:00:00")
            template = newTemplate
        case .CircularSmall:
            let newTemplate = CLKComplicationTemplateCircularSmallSimpleImage()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "squidIcon.png")!)
            template = newTemplate
        }
        handler(template)
    }
    
}
