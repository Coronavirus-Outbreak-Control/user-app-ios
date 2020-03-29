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
        var distances = [Int]()
        var interval = 0.0
        var lastDate : Date? = nil
        let identifier = ibeacons[0].identifier
        
        for beacon in ibeacons{
            if let d = lastDate{
                interval += abs(d.timeIntervalSince(beacon.timestamp))
            }
            rssis.append(beacon.rssi)
            distances.append(beacon.distance)
            lastDate = beacon.timestamp
        }
        // add the minimum interval to take into account the last interaction
        interval += Constants.Setup.minimumIntervalTime
        
        let res = IBeaconDto(identifier: identifier,
                             timestamp: ibeacons[0].timestamp,
                             rssi: rssis.sorted(by: <)[rssis.count / 2],
                             distance: distances.sorted(by: <)[distances.count / 2],
                             lat: ibeacons[ibeacons.count-1].lat,
                             lon: ibeacons[ibeacons.count-1].lon,
                             interval: max(interval, Constants.Setup.minimumIntervalTime))
//        print("WILL RETURN", res)
        return res
    }
    
    private static func prepareAndPush(_ ibeacons: [IBeaconDto], isBackground : Bool, tokenJWT : String){
//        print("\n\nRECEIVED beacons", ibeacons)
        var id2list = [Int64: [IBeaconDto]]()
        var validIbeacons = [IBeaconDto]()
        
        for beacon in ibeacons{
            if id2list[beacon.identifier] != nil{
                if let last = id2list[beacon.identifier]?.first{
                    if abs(last.timestamp.timeIntervalSince(beacon.timestamp)) <= Constants.Setup.timeAggregationIBeacons{
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
        
        if isBackground {
            print("pushing positions on background")
            ApiManager.shared.uploadInteractionsInBackground(validIbeacons, token: tokenJWT)
            print("updating last time push")
            StorageManager.shared.setLastTimePush(timeOfPush)
        } else {
            ApiManager.shared.uploadInteractions(validIbeacons, token: tokenJWT) { pushDelay in
                print("updating last time push")
                StorageManager.shared.setLastTimePush(timeOfPush)
                StorageManager.shared.setPushInterval(pushDelay)
                StorageManager.shared.resetPushInProgress()
            }
        }
    }
    
    private static func getTokenAndProceed(_ ibeacons: [IBeaconDto], isBackground : Bool){
        ApiManager.shared.handshakeNewDevice(id: DeviceInfoManager.getId(), model: DeviceInfoManager.getModel(), version: DeviceInfoManager.getVersion()) {
            deviceID, token in

            CoreManager.prepareAndPush(ibeacons, isBackground: isBackground, tokenJWT: token)
        }
    }
    
    public static func pushInteractions(isBackground : Bool){
        
        if StorageManager.shared.getPushInProgress() {
            print("push in progress")
            return
        }
        print("checking interactions to push")
        if let lastDatePush = StorageManager.shared.getLastTimePush() {
            if lastDatePush.addingTimeInterval(StorageManager.shared.getPushInterval()) < Date(){
                print("interval elapsed, time to PUSH")
                //push old interactions
                if let ibeacons = StorageManager.shared.readIBeaconsNewerThanDate(lastDatePush){
                    StorageManager.shared.setPushInProgress()
                    CoreManager.getTokenAndProceed(ibeacons, isBackground: isBackground)
                }
            }else{
                print("no need to push yet last time was", lastDatePush, "next at", lastDatePush.addingTimeInterval(StorageManager.shared.getPushInterval()))
            }
        }else{
            print("no last push found, pushing everything")
            if let ibeacons = StorageManager.shared.readAllIBeacons(){
                StorageManager.shared.setPushInProgress()
                CoreManager.getTokenAndProceed(ibeacons, isBackground: isBackground)
            }
        }
        // no interactions to push
    }
    
    public static func addIBeacon(_ iBeacon : CLBeacon){
        print("addIbeacon", iBeacon)
        let uuid = Utils.buildIdentifierBy(minor: iBeacon.minor.intValue, major: iBeacon.major.intValue)
        let ib : IBeaconDto = IBeaconDto(
            identifier: uuid,
            timestamp: Date(),
            rssi: Int64(iBeacon.rssi),
            distance: iBeacon.proximity.rawValue)
        
        if StorageManager.shared.getShareLocation(){
            if let cl = LocationManager.shared.getLocationAndUpdate(){
                ib.setLocation(cl)
            }
        }
        print("WILL BE ", ib)
        
        StorageManager.shared.saveIBeacon(ib)
        CoreManager.pushInteractions(isBackground: false)
    }
}
