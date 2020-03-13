//
//  CoreManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 04/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation
import CoreLocation

class CoreManager {
    
    private static func groupIBeacon(_ ibeacons: [IBeaconDto]) -> IBeaconDto?{
        
//        print("ASK TO GROUP", ibeacons)
        
        if ibeacons.count == 0{
            return nil
        }
        
        if ibeacons.count == 1{
            return ibeacons[0]
        }
        
        var rssis = [Int64]()
        var interval = 0.0
        var lastDate : Date? = nil
        let identifier = ibeacons[0].identifier
        
        for beacon in ibeacons{
            if let d = lastDate{
                interval += abs(d.timeIntervalSince(beacon.timestamp))
            }
            rssis.append(beacon.rssi)
            lastDate = beacon.timestamp
        }
        let res = IBeaconDto(identifier: identifier, timestamp: ibeacons[0].timestamp,
                             rssi: rssis.sorted(by: <)[rssis.count / 2], interval: min(interval, Costants.Setup.minimumIntervalTime))
//        print("WILL RETURN", res)
        return res
    }
    
    private static func prepareAndPush(_ ibeacons: [IBeaconDto], isBackground : Bool){
//        print("\n\nRECEIVED beacons", ibeacons)
        var id2list = [Int64: [IBeaconDto]]()
        var validIbeacons = [IBeaconDto]()
        
        for beacon in ibeacons{
            if id2list[beacon.identifier] != nil{
                if let last = id2list[beacon.identifier]?.last{
                    if abs(last.timestamp.timeIntervalSince(beacon.timestamp)) <= Costants.Setup.timeAggregationIBeacons{
                        id2list[beacon.identifier]?.append(beacon)
                    }else{
                        if let b = CoreManager.groupIBeacon(id2list[beacon.identifier]!){
                            validIbeacons.append(b)
                        }
                        id2list[beacon.identifier] = [beacon]
                    }
                }
            }else{
                id2list[beacon.identifier] = [beacon]
            }
        }
        
        for indexBeacon in id2list.keys{
            if let b = CoreManager.groupIBeacon(id2list[indexBeacon]!){
                validIbeacons.append(b)
            }
        }
        
        let timeOfPush = Date()
        print("gonna push", validIbeacons)
        if isBackground{
            print("pushing positions on background")
            ApiManager.shared.uploadInteractionsInBackground(validIbeacons)
            print("updating last time push")
            StorageManager.shared.setLastTimePush(timeOfPush)
        }else{
            ApiManager.shared.uploadInteractions(validIbeacons) {
                print("updating last time push")
                StorageManager.shared.setLastTimePush(timeOfPush)
            }
        }
    }
    
    public static func pushInteractions(isBackground : Bool){
        
        print("checking interactions to push")
        if let lastDatePush = StorageManager.shared.getLastTimePush(){
            if lastDatePush.addingTimeInterval(Costants.Setup.secondsIntervalBetweenPushes) < Date(){
                print("interval elapsed, time to push")
                //push old interactions
                if let ibeacons = StorageManager.shared.readIBeaconsNewerThanDate(lastDatePush){
                    CoreManager.prepareAndPush(ibeacons, isBackground: isBackground)
                }
            }else{
                print("no need to push yet last time was", lastDatePush)
            }
        }else{
            print("no last push found, pushing everything")
            if let ibeacons = StorageManager.shared.readAllIBeacons(){
                CoreManager.prepareAndPush(ibeacons, isBackground: isBackground)
            }
        }
        // no interactions to push
    }
    
//    public static func pushInteractionsInBackground() {
//        // will need to schedule this using the task scheduler
//        // https://developer.apple.com/documentation/backgroundtasks/bgtaskscheduler
//        // In this case, delegate handles setting last push time - we don't want to update it if the upload fails
//        print("checking interactions to push")
//        if let lastDatePush = StorageManager.shared.getLastTimePush(){
//            if lastDatePush.addingTimeInterval(Costants.Setup.secondsIntervalBetweenPushes) < Date(){
//                print("interval elapsed, time to push")
//                //push old interactions
//                if let ibeacons = StorageManager.shared.readIBeaconsNewerThanDate(lastDatePush){
//                    ApiManager.shared.uploadInteractionsInBackground(ibeacons)
//                }
//            }else{
//                print("no need to push yet")
//            }
//        }else{
//            print("no last push found, pushing everything")
//            if let ibeacons = StorageManager.shared.readAllIBeacons(){
//                ApiManager.shared.uploadInteractionsInBackground(ibeacons)
//            }
//        }
//
//    }
    
    public static func addIBeacon(_ iBeacon : CLBeacon){
        print("addIbeacon", iBeacon)
        let uuid = Utils.buildIdentifierBy(minor: iBeacon.minor.intValue, major: iBeacon.major.intValue)
        let ib : IBeaconDto = IBeaconDto(
            identifier: uuid,
            timestamp: Date(),
            rssi: Int64(iBeacon.rssi))
        
        StorageManager.shared.saveIBeacon(ib)
        
        CoreManager.pushInteractions(isBackground: false)
    }
}
