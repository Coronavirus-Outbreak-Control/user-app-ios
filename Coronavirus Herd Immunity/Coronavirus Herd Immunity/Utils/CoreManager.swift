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
    
//    if let found = self.peripherals.first(where: {$0.identifier == peripheral.identifier.uuidString}) {
//       // do something with foo
//        found.counter += 1
//        found.rssi = min(found.rssi, RSSI.doubleValue)
//        StorageManager.shared.savePeripheral(peripheralInput: found)
//    } else {
//       // item could not be found
//        let p = PeripheralDto(
//            identifier: peripheral.identifier.uuidString,
//            rssi: RSSI.doubleValue,
//            timestamp: Date(),
//            timeBlock: self.timeBlock!,
//            counter: 1)
//        StorageManager.shared.savePeripheral(peripheralInput: p)
//    }
    
    public static func addIBeacon(_ iBeacon : CLBeacon){
        print("addIbeacon", iBeacon)
        let uuid = Utils.buildIdentifierBy(minor: iBeacon.minor.intValue, major: iBeacon.major.intValue)
        let ib : IBeaconDto = IBeaconDto(
            identifier: uuid,
            timestamp: Date(),
            counter: 1,
            rssi: Int64(iBeacon.rssi))
        
        if let ibs = StorageManager.shared.readIBeaconsByIdentifierToday(uuid){
            //TODO: should it be a list?
            ibs[0].counter += 1
            print("gonna save", ibs[0])
            StorageManager.shared.saveIBeacon(ibs[0])
        }else{
            print("gonna save", ib)
            StorageManager.shared.saveIBeacon(ib)
        }
        
    }
    
}
