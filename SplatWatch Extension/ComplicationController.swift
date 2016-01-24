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
        handler(NSDate())
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        let data = loadData()
        
        for x in 0...2 {
            if let end = data["endTimes"][2 - x].double {
                handler(NSDate(timeIntervalSince1970: end))
                return
            }
        }
        
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
            let endTime = data["endTimes"][0].doubleValue
            let progress = Float((endTime - NSDate().timeIntervalSince1970) / Double(14400))
            let newTemplate = CLKComplicationTemplateModularSmallRingImage()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: modeImage)
            newTemplate.ringStyle = .Closed
            newTemplate.fillFraction = progress
            newTemplate.imageProvider.tintColor = UIColor(red:0.58, green:0.93, blue:0, alpha:1)
            newTemplate.tintColor = UIColor(red:0, green:0.85, blue:0.76, alpha:1)
            template = newTemplate
        case .ModularLarge:
            let endTime = data["endTimes"][0].doubleValue
            let fractionalHour = (endTime - NSDate().timeIntervalSince1970) / 60 / 60 % 1
            var modeText = "Error"
            var map1Text = "Error"
            var map2Text = "Error"
            var image = getImageForMode("turf")
            
            if fractionalHour > 0.5 {
                modeText = mode
                image = getImageForMode(mode)
                map1Text = data["rankedMaps"][0].stringValue
                map2Text = data["rankedMaps"][1].stringValue
            } else {
                modeText = "Turf War"
                map1Text = data["turfMaps"][0].stringValue
                map2Text = data["turfMaps"][1].stringValue
            }
            
            let newTemplate = CLKComplicationTemplateModularLargeStandardBody()
            newTemplate.headerImageProvider = CLKImageProvider(onePieceImage: image)
            newTemplate.headerTextProvider = CLKSimpleTextProvider(text: modeText)
            newTemplate.body1TextProvider = CLKSimpleTextProvider(text: map1Text)
            newTemplate.body2TextProvider = CLKSimpleTextProvider(text: map2Text)
            newTemplate.body1TextProvider.tintColor = UIColor(red:0.58, green:0.93, blue:0, alpha:1)
            newTemplate.body2TextProvider?.tintColor = UIColor(red:0, green:0.85, blue:0.76, alpha:1)
            template = newTemplate
        case .UtilitarianSmall:
            let endTime = data["endTimes"][0].doubleValue
            let changeTime = NSDate(timeIntervalSince1970: NSTimeInterval(endTime))
            let newTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: modeImage)
            newTemplate.textProvider = CLKRelativeDateTextProvider(date: changeTime, style: .Timer, units: [.Hour, .Minute, .Second])
            newTemplate.imageProvider?.tintColor = UIColor(red:0.58, green:0.93, blue:0, alpha:1)
            newTemplate.textProvider.tintColor = UIColor(red:0, green:0.85, blue:0.76, alpha:1)
            template = newTemplate
        case .UtilitarianLarge:
            let endTime = data["endTimes"][0].doubleValue
            let changeTime = NSDate(timeIntervalSince1970: NSTimeInterval(endTime))
            let newTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: modeImage)
            newTemplate.textProvider = CLKRelativeDateTextProvider(date: changeTime, style: .Timer, units: [.Hour, .Minute, .Second])
            newTemplate.imageProvider?.tintColor = UIColor(red:0.58, green:0.93, blue:0, alpha:1)
            newTemplate.textProvider.tintColor = UIColor(red:0, green:0.85, blue:0.76, alpha:1)
            template = newTemplate
        case .CircularSmall:
            let endTime = data["endTimes"][0].doubleValue
            let progress = Float((endTime - NSDate().timeIntervalSince1970) / Double(14400))
            let newTemplate = CLKComplicationTemplateCircularSmallRingImage()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: modeImage)
            newTemplate.ringStyle = .Closed
            newTemplate.fillFraction = progress
            newTemplate.imageProvider.tintColor = UIColor(red:0.58, green:0.93, blue:0, alpha:1)
            newTemplate.tintColor = UIColor(red:0, green:0.85, blue:0.76, alpha:1)
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
            var x = 0
            
            while x <= limit && x <= 2 {
                if let start = data["startTimes"][x].double {
                    var currentDate = NSDate(timeIntervalSince1970: start)
                    
                    for y in 0...23 {
                        if x * 24 + y > limit || currentDate.isBeforeDate(date) {
                            currentDate = currentDate.addMinutes(10)
                            continue
                        }
                        
                        let newTemplate = CLKComplicationTemplateModularSmallRingImage()
                        newTemplate.imageProvider = CLKImageProvider(onePieceImage: getImageForMode(data["rankedModes"][x].stringValue))
                        newTemplate.imageProvider.tintColor = UIColor(red:0.58, green:0.93, blue:0, alpha:1)
                        newTemplate.tintColor = UIColor(red:0, green:0.85, blue:0.76, alpha:1)
                        newTemplate.ringStyle = .Closed
                        newTemplate.fillFraction = 1 - Float(y) / 23
                        
                        entries.append(CLKComplicationTimelineEntry(date: currentDate, complicationTemplate: newTemplate))
                        currentDate = currentDate.addMinutes(10)
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
                        if x * 8 + y > limit || currentDate.isBeforeDate(date) {
                            currentDate = currentDate.addMinutes(30)
                            continue
                        }
                        
                        let template = CLKComplicationTemplateModularLargeStandardBody()
                        
                        if y % 2 == 1 {
                            template.headerImageProvider = CLKImageProvider(onePieceImage: getImageForMode(mode))
                            template.headerTextProvider = CLKSimpleTextProvider(text: mode)
                            template.body1TextProvider = CLKSimpleTextProvider(text: rankedMap1)
                            template.body2TextProvider = CLKSimpleTextProvider(text: rankedMap2)
                        } else {
                            template.headerImageProvider = CLKImageProvider(onePieceImage: getImageForMode("turf"))
                            template.headerTextProvider = CLKSimpleTextProvider(text: "Turf War")
                            template.body1TextProvider = CLKSimpleTextProvider(text: turfMap1)
                            template.body2TextProvider = CLKSimpleTextProvider(text: turfMap2)
                        }
                        
                        template.body1TextProvider.tintColor = UIColor(red:0.58, green:0.93, blue:0, alpha:1)
                        template.body2TextProvider?.tintColor = UIColor(red:0, green:0.85, blue:0.76, alpha:1)
                        
                        entries.append(CLKComplicationTimelineEntry(date: currentDate, complicationTemplate: template))
                        currentDate = currentDate.addMinutes(30)
                    }
                }
                
                x += 1
            }
        case .UtilitarianSmall:
            var x = 1
            
            while x <= 2 {
                if let
                    start = data["startTimes"][x].double,
                    end = data["endTimes"][x].double,
                    mode = data["rankedModes"][x].string
                {
                    let currentDate = NSDate(timeIntervalSince1970: start)
                    
                    if currentDate.isBeforeDate(date) { continue }
                    
                    let changeTime = NSDate(timeIntervalSince1970: NSTimeInterval(end))
                    let template = CLKComplicationTemplateUtilitarianSmallFlat()
                    template.imageProvider = CLKImageProvider(onePieceImage: getImageForMode(mode))
                    template.textProvider = CLKRelativeDateTextProvider(date: changeTime, style: .Timer, units: [.Hour, .Minute, .Second])
                    template.imageProvider?.tintColor = UIColor(red:0.58, green:0.93, blue:0, alpha:1)
                    template.textProvider.tintColor = UIColor(red:0, green:0.85, blue:0.76, alpha:1)
                    
                    entries.append(CLKComplicationTimelineEntry(date: currentDate, complicationTemplate: template))
                }
                
                x += 1
            }
        case .UtilitarianLarge:
            var x = 1
            
            while x <= 2 {
                if let
                    start = data["startTimes"][x].double,
                    end = data["endTimes"][x].double,
                    mode = data["rankedModes"][x].string
                {
                    let currentDate = NSDate(timeIntervalSince1970: start)
                    
                    if currentDate.isBeforeDate(date) { continue }
                    
                    let changeTime = NSDate(timeIntervalSince1970: NSTimeInterval(end))
                    let template = CLKComplicationTemplateUtilitarianLargeFlat()
                    template.imageProvider = CLKImageProvider(onePieceImage: getImageForMode(mode))
                    template.textProvider = CLKRelativeDateTextProvider(date: changeTime, style: .Timer, units: [.Hour, .Minute, .Second])
                    template.imageProvider?.tintColor = UIColor(red:0.58, green:0.93, blue:0, alpha:1)
                    template.textProvider.tintColor = UIColor(red:0, green:0.85, blue:0.76, alpha:1)
                    
                    entries.append(CLKComplicationTimelineEntry(date: currentDate, complicationTemplate: template))
                }
                
                x += 1
            }
        case .CircularSmall:
            var x = 0
            
            while x <= limit && x <= 2 {
                if let start = data["startTimes"][x].double {
                    var currentDate = NSDate(timeIntervalSince1970: start)
                    
                    for y in 0...23 {
                        if x * 24 + y > limit || currentDate.isBeforeDate(date) {
                            currentDate = currentDate.addMinutes(10)
                            continue
                        }
                        
                        let newTemplate = CLKComplicationTemplateCircularSmallRingImage()
                        newTemplate.imageProvider = CLKImageProvider(onePieceImage: getImageForMode(data["rankedModes"][x].stringValue))
                        newTemplate.ringStyle = .Closed
                        newTemplate.fillFraction = 1 - Float(y) / 23
                        newTemplate.imageProvider.tintColor = UIColor(red:0.58, green:0.93, blue:0, alpha:1)
                        newTemplate.tintColor = UIColor(red:0, green:0.85, blue:0.76, alpha:1)
                        
                        entries.append(CLKComplicationTimelineEntry(date: currentDate, complicationTemplate: newTemplate))
                        currentDate = currentDate.addMinutes(10)
                    }
                }
                
                x += 1
            }
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
            let newTemplate = CLKComplicationTemplateModularSmallRingImage()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "squidIcon.png")!)
            newTemplate.imageProvider.tintColor = UIColor(red:0.58, green:0.93, blue:0, alpha:1)
            newTemplate.tintColor = UIColor(red:0, green:0.85, blue:0.76, alpha:1)
            newTemplate.ringStyle = .Closed
            newTemplate.fillFraction = 0.66
            template = newTemplate
        case .ModularLarge:
            let newTemplate = CLKComplicationTemplateModularLargeStandardBody()
            newTemplate.headerImageProvider = CLKImageProvider(onePieceImage: getImageForMode("squid"))
            newTemplate.headerTextProvider = CLKSimpleTextProvider(text: "Ranked Mode")
            newTemplate.body1TextProvider = CLKSimpleTextProvider(text: "Map 1")
            newTemplate.body2TextProvider = CLKSimpleTextProvider(text: "Map 2")
            newTemplate.body1TextProvider.tintColor = UIColor(red:0.58, green:0.93, blue:0, alpha:1)
            newTemplate.body2TextProvider?.tintColor = UIColor(red:0, green:0.85, blue:0.76, alpha:1)
            template = newTemplate
        case .UtilitarianSmall:
            let newTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "squidIcon.png")!)
            newTemplate.textProvider = CLKSimpleTextProvider(text: "00:00:00")
            newTemplate.imageProvider?.tintColor = UIColor(red:0.58, green:0.93, blue:0, alpha:1)
            newTemplate.textProvider.tintColor = UIColor(red:0, green:0.85, blue:0.76, alpha:1)
            template = newTemplate
        case .UtilitarianLarge:
            let newTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "squidIcon.png")!)
            newTemplate.textProvider = CLKSimpleTextProvider(text: "00:00:00")
            newTemplate.imageProvider?.tintColor = UIColor(red:0.58, green:0.93, blue:0, alpha:1)
            newTemplate.textProvider.tintColor = UIColor(red:0, green:0.85, blue:0.76, alpha:1)
            template = newTemplate
        case .CircularSmall:
            let newTemplate = CLKComplicationTemplateCircularSmallRingImage()
            newTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "squidIcon.png")!)
            newTemplate.ringStyle = .Closed
            newTemplate.fillFraction = 0.66
            newTemplate.imageProvider.tintColor = UIColor(red:0.58, green:0.93, blue:0, alpha:1)
            newTemplate.tintColor = UIColor(red:0, green:0.85, blue:0.76, alpha:1)
            template = newTemplate
        }
        handler(template)
    }
    
}
