//
//  CoreManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 04/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class CoreManager {
    
    private static func groupIBeacon(_ ibeacons: [IBeaconDto]) -> IBeaconDto?{
        
        if ibeacons.count == 0{
            return nil
        }
        
        if ibeacons.count == 1{
            return ibeacons[0]
        }
        
        var rssis = [Int64]()
        var accuracies = [Double]()
        var distances = [Int]()
        var interval = 0.0
        var lastDate : Date? = nil
        let identifier = ibeacons[0].identifier
        
        for beacon in ibeacons{
            if let d = lastDate{
                interval += abs(d.timeIntervalSince(beacon.timestamp))
            }
            rssis.append(beacon.rssi)
            accuracies.append(beacon.accuracy)
            distances.append(beacon.distance)
            lastDate = beacon.timestamp
        }
        // add the minimum interval to take into account the last interaction
        interval += Constants.Setup.minimumIntervalTime
        
        let res = IBeaconDto(identifier: identifier,
                             timestamp: ibeacons[0].timestamp,
                             rssi: rssis.sorted(by: <)[rssis.count / 2],
                             distance: distances.sorted(by: <)[distances.count / 2],
                             accuracy: accuracies.sorted(by: <)[accuracies.count / 2],
                             lat: ibeacons[ibeacons.count-1].lat,
                             lon: ibeacons[ibeacons.count-1].lon,
                             interval: max(interval, Constants.Setup.minimumIntervalTime))
        return res
    }
    
    private static func meanFromBeacons(_ beacons : [IBeaconDto]) -> IBeaconDto?{
        if beacons.count == 0{
            return nil
        }
        
        var rssis : Int64 = 0
        var accuracies : Double = 0
        let distance = beacons[0].distance
        var interval = 0.0
        var lastDate : Date? = nil
        let identifier = beacons[0].identifier
        
        for beacon in beacons{
            interval += beacon.interval
            rssis += beacon.rssi
            accuracies += beacon.accuracy
            lastDate = beacon.timestamp
        }
        return IBeaconDto(identifier: identifier, timestamp: beacons[0].timestamp, rssi: Int64(Int(rssis) / beacons.count),
                          distance: distance, accuracy: accuracies / Double(beacons.count), interval: interval)
    }
    
    private static func secondAggregation(_ beacons : [IBeaconDto]) -> [IBeaconDto]{
        
        var aggregation = [IBeaconDto]()
        var currentIterations = [IBeaconDto]()
        
        for beacon in beacons{
            if currentIterations.count == 0{
                currentIterations.append(beacon)
                continue
            }
            let last = currentIterations[currentIterations.count-1]
            if beacon.distance == currentIterations[0].distance && abs(last.timestamp.addingTimeInterval(last.interval).timeIntervalSince(beacon.timestamp)) < Constants.Setup.minTimeSecondAggregation{
                currentIterations.append(beacon)
            }else{
                if let i = meanFromBeacons(currentIterations){
                    aggregation.append(i)
                }
                currentIterations = [beacon]
            }
        }
        if let i = meanFromBeacons(currentIterations){
            aggregation.append(i)
        }
        
        return aggregation
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
        
        print("first iterations", validIbeacons)
        let secondAggregation = CoreManager.secondAggregation(validIbeacons)
        
        let timeOfPush = Date()
        print("gonna push aggregated", secondAggregation)
        
        if secondAggregation.count == 0{
            StorageManager.shared.setLastTimePush(timeOfPush)
            let lastNT = StorageManager.shared.getLastNextTry()
            let next_try = lastNT + Double.random(in: -0.25 ... 0.25) * lastNT
            StorageManager.shared.setPushInterval(next_try)
            StorageManager.shared.resetPushInProgress()
            return
        }
        
        if isBackground {
            print("pushing positions on background")
            ApiManager.shared.uploadInteractionsInBackground(secondAggregation, token: tokenJWT)
            print("updating last time push")
            StorageManager.shared.setLastTimePush(timeOfPush)
        } else {
            ApiManager.shared.uploadInteractions(secondAggregation, token: tokenJWT) { pushDelay in
                print("updating last time push")
                StorageManager.shared.setLastTimePush(timeOfPush)
                StorageManager.shared.resetPushInProgress()
            }
        }
    }
    
    private static func getTokenAndProceed(_ ibeacons: [IBeaconDto], isBackground : Bool){
        ApiManager.shared.handshakeNewDevice(googleToken: nil) {
            deviceID, token, error in
            if let jwt = token{
                CoreManager.prepareAndPush(ibeacons, isBackground: isBackground, tokenJWT: jwt)
            }
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
            distance: iBeacon.proximity.rawValue,
            accuracy: iBeacon.accuracy)
        
        if StorageManager.shared.getShareLocation(){
            if let cl = LocationManager.shared.getLocationAndUpdate(){
                ib.setLocation(cl)
            }
        }
        print("WILL BE ", ib)
        
        StorageManager.shared.saveIBeacon(ib)
        CoreManager.pushInteractions(isBackground: UIApplication.shared.applicationState == .background)
    }
}
