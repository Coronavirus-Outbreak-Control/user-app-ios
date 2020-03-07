//
//  CoreManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 04/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation
import CoreLocation

class CoreManager{
    
    public static func pushInteractions(){
        print("checking locations to push")
        if let lastDatePush = StorageManager.shared.getLastTimePush(){
            if lastDatePush.addingTimeInterval(Costants.Setup.secondsIntervalBetweenPushes) < Date(){
                print("interval elapsed, time to push")
                let timeOfPush = Date()
                //push old interactions
                if let ibeacons = StorageManager.shared.readIBeaconsNewerThanDate(lastDatePush){
                    ApiManager.shared.uploadInteractions(ibeacons) {
                        print("updating last time push")
                        StorageManager.shared.setLastTimePush(timeOfPush)
                    }
                }
            }else{
                print("no need to push yet")
            }
        }else{
            print("no last push found, gonna push everything")
            let timeOfPush = Date()
            if let ibeacons = StorageManager.shared.readAllIBeacons(){
                ApiManager.shared.uploadInteractions(ibeacons) {
                    print("setting last time push")
                    StorageManager.shared.setLastTimePush(timeOfPush)
                }
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
            rssi: Int64(iBeacon.rssi))
        
        StorageManager.shared.saveIBeacon(ib)
        
        CoreManager.pushInteractions()
    }
}
