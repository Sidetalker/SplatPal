//
//  MapsTableViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/9/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import SwiftyJSON

let mapRefreshCooldown = 60

class MapsTableViewController: UITableViewController {
    
    var mapData: JSON?
    var mapsUpdating = false
    var mapsUpdateCooldown = -1
    var mapError = false
    var mapErrorCode = -1
    var mapErrorMessage = ""
    
    var liveLabel: UILabel?
    var liveLabelTimer: NSTimer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundView = UIView(frame: tableView.frame)
        backgroundView.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTile.jpg")!)
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundView = backgroundView
        tableView.reloadData()
        
        liveLabelTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateLabel", userInfo: nil, repeats: true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let
            errorCode = mapData?["errorCode"].int,
            errorMessage = mapData?["errorMessage"].string
        {
            mapError = true
            mapErrorCode = errorCode
            mapErrorMessage = errorMessage
            
            return 1
        } else {
            mapError = false
            return 3
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapError ? 0 : 6
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.row % 3 == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("cellGameMode", forIndexPath: indexPath)
            cell.backgroundColor = UIColor.clearColor()
            
            let lbl = cell.viewWithTag(1) as! UILabel
            lbl.text = indexPath.row == 0 ? mapData!["rankedModes"][indexPath.section].stringValue : "Turf Wars"
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier("cellMap", forIndexPath: indexPath)
            cell.backgroundColor = UIColor.clearColor()
            
            let mapName = [1, 2].contains(indexPath.row) ?
                mapData!["rankedMaps"][indexPath.row - 1 + indexPath.section * 2].stringValue :
                mapData!["turfMaps"][indexPath.row - 4 + indexPath.section * 2].stringValue
            
            let imgMap = cell.viewWithTag(1) as! UIImageView
            imgMap.layer.cornerRadius = 5
            imgMap.image = UIImage(named: "Stage\(mapName.removeWhitespace()).jpg")
            
            let imgBadge = cell.viewWithTag(2) as! UIImageView
            imgBadge.image = [1, 2].contains(indexPath.row) ? UIImage(named: "rankedBadge.png") : UIImage(named: "turfWarBadge.png")
            
            let lblName = cell.viewWithTag(3) as! UILabel
            lblName.text = mapName
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard cell.reuseIdentifier == "cellMap" else { return }
        
        // Resize map label font to give it some padding
        let lblName = cell.viewWithTag(3) as! UILabel
        let insets = UIEdgeInsetsMake(2, 5, 2, 5)
        let desiredFrame = UIEdgeInsetsInsetRect(lblName.frame, insets)
        let constraintSize = CGSizeMake(desiredFrame.width, 100000)
        let minFontSize: CGFloat = 10
        var fontSize: CGFloat = 25
        
        repeat {
            lblName.font = UIFont(name: lblName.font.fontName, size: fontSize)
            
            let size = (lblName.text! as NSString).boundingRectWithSize(constraintSize,
                options: .UsesLineFragmentOrigin,
                attributes: [NSFontAttributeName: lblName.font],
                context: nil).size
            
            if size.height <= desiredFrame.height { break }
            
            fontSize -= 1
        } while (fontSize > minFontSize);
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 85
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellTimeRemaining")!
        cell.contentView.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTile.jpg")!)
        
        let lblHeader = cell.viewWithTag(1) as! UILabel
        let lblFooter = cell.viewWithTag(2) as! UILabel
        
        if section == 0 {
            if cell.contentView.gestureRecognizers?.count == 1 {
                cell.contentView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "topHeaderLongPress:"))
            }
            if mapError && !mapsUpdating {
                lblHeader.text = "Error Loading Data"
                lblFooter.text = "Tap + Hold to Refresh"
            } else {
                if mapsUpdating {
                    lblHeader.text = "Retrieving Updates"
                    lblFooter.text = "· · ·"
                }
                else {
                    liveLabel = lblFooter
                    updateLabel()
                    lblHeader.text = mapsUpdateCooldown > 0 ? "Retrieving Updates" : "Time Until Next Rotation"
                }
            }
        } else {
            let startTime = mapData!["startTimes"][section].doubleValue
            let endTime = mapData!["endTimes"][section].doubleValue
            lblHeader.text = epochDateString(startTime)
            lblFooter.text = "\(epochTimeString(startTime)) - \(epochTimeString(endTime))"
        }
        
        return cell.contentView
    }
    
    func topHeaderLongPress(sender: UITapGestureRecognizer) {
        guard sender.state == .Began && mapsUpdating == false else { return }
        updateMaps(true)
    }
    
    // MARK: - Update functions
    
    func getTimeRemainingSeconds() -> Int {
        return Int(mapData!["endTimes"][0].doubleValue - NSDate().timeIntervalSince1970)
    }
    
    func getTimeRemainingText(epochInt: Int) -> String {
        var seconds = epochInt
        var minutes = seconds / 60
        let hours = minutes / 60
        seconds -= minutes * 60
        minutes -= hours * 60
        let secondsText = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        let minutesText = minutes < 10 && hours > 0 ? "0\(minutes)" : "\(minutes)"
        
        return hours > 0 ? "\(hours):\(minutesText):\(secondsText)" : "\(minutesText):\(secondsText)"
    }
    
    func updateLabel() {
        guard liveLabel != nil && !mapError else { return }
        
        if mapsUpdateCooldown >= 0 {
            liveLabel?.text = "Waiting \(mapsUpdateCooldown)"
            mapsUpdateCooldown -= 1
            
            if mapsUpdateCooldown == -1 {
                tableView.reloadData()
            }
        } else {
            let timeRemainingSeconds = getTimeRemainingSeconds()
            if timeRemainingSeconds <= 0 && !mapError { updateMaps(false) }
            else { liveLabel?.text = getTimeRemainingText(timeRemainingSeconds) }
        }
    }
    
    func updateMaps(manually: Bool) {
        mapsUpdating = true
        tableView.reloadData()
        
        loadMaps({ data in
            self.mapsUpdating = false
            
            if self.mapData == data {
                self.mapsUpdateCooldown = manually ? -1 : mapRefreshCooldown
            }
            else {
                self.mapData = data
            }
            
            self.tableView.reloadData()
        })
    }
}
