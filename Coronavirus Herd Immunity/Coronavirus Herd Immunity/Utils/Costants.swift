//
//  Costants.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 27/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation

class Costants {
    
    class Notification{
        
        public static let bluetoothChangeStatus = "bluetooth.changeStatus"
        public static let locationChangeStatus = "location.changeStatus"
        
        public static let bluetoothPoweredOnPermissionStatus = "bluetooth.on"
        public static let bluetoothPoweredOffPermissionStatus = "bluetooth.off"
        public static let bluetoothResettingPermissionStatus = "bluetooth.resetting"
        public static let bluetoothUnauthorizedPermissionStatus = "bluetooth.unauthorized"
        public static let bluetoothUnknownPermissionStatus = "bluetooth.unknown"
        public static let bluetoothUnsupportedPermissionStatus = "bluetooth.unsuppoertd"
        
    }
    
    class Setup{
        
        public static let uuidCHIdevice = "451720ea-5e62-11ea-bc55-0242ac130003"
        public static let beaconCHIidentifier = "com.coronaherdimmunity.myDeviceRegion"
        
        public static let identifierDevice = "chi.identifier.device"
        public static let totalInteractionsKey = "chi.interactions.total"
        public static let lastDatePushPreference = "chi.preference.lastDatePush"
        
        public static let secondsIntervalBetweenPushes : TimeInterval = 3600 * 24
        
        public static let scanTime : Double = 10
        public static let minRSSIPower : Double = -60
        public static let maxRSSIPower : Double = 100
        public static let minCounterIdentifierToPush = 1
        public static let timeAggregationIBeacons : TimeInterval = 300
        public static let minimumIntervalTime : Double = 10
        
        public static let moduleMinorMajorVersion : Int = 65536
    }
    
}
