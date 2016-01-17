//
//  ComplicationController.swift
//  SplatWatch Extension
//
//  Created by Kevin Sullivan on 1/16/16.
//  Copyright © 2016 Kevin Sullivan. All rights reserved.
//

import ClockKit
import SwiftyJSON

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
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    func saveData(data: JSON) -> Bool {
        let path = getDocumentsDirectory().stringByAppendingPathComponent("dataBuffer.json")
        
        do {
            try data.rawString()!.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
            return true
        } catch {
            return false
        }
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
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        handler(NSDate(timeIntervalSinceNow: 60*60*3))
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
            let newTemplate = CLKComplicationTemplateUtilitarianSmallRingImage()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "squidIcon.png")!)
            newTemplate.ringStyle = .Closed
            newTemplate.fillFraction = 1.0
            template = newTemplate
        case .UtilitarianLarge:
            let newTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "squidIcon.png")!)
            newTemplate.textProvider = CLKSimpleTextProvider(text: "SplatPal")
            template = newTemplate
        case .CircularSmall:
            let newTemplate = CLKComplicationTemplateCircularSmallSimpleImage()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "squidIcon.png")!)
            template = newTemplate
        }
        handler(template)
    }
    
}
