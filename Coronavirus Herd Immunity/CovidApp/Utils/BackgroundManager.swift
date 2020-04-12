//
//  BackgroundManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 11/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit
import Foundation

class BackgroundManager{
    
    public static func backgroundOperations(){
        CoreManager.pushInteractions(isBackground: UIApplication.shared.applicationState == .background)
        dailyDeleteOlderBeacons()
        if BluetoothManager.shared.isBluetoothUsable() && LocationManager.shared.getPermessionStatus() == .allowedAlways{
            print("background operations")
            IBeaconManager.shared.registerListener()
            LocationManager.shared.startMonitoring()
            IBeaconManager.shared.startAdvertiseDevice()
        }
        
    }
    
    fileprivate static func dailyDeleteOlderBeacons(daysPassed: Int = 7) {
        if  let lastDelete = Utils.dateForUserDefaults(key: Constants.StoreManager.beaconDeleteOlderTimestamp),
            !lastDelete.dateByAddingDays(1).isPassed { // rule to delete older beacons once per day
            return // STOP!
        }
        
        StorageManager.shared.deleteIBeaconsOlderThan(date: Date().dateByRemovingDays(daysPassed))
        Utils.storeDateForUserDefaults(key: Constants.StoreManager.beaconDeleteOlderTimestamp)
    }
    
}
