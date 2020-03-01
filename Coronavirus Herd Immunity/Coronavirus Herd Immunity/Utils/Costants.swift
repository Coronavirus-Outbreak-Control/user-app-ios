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
        
        public static let bluetoothPoweredOnPermissionStatus = "bluetooth.on"
        public static let bluetoothPoweredOffPermissionStatus = "bluetooth.off"
        public static let bluetoothResettingPermissionStatus = "bluetooth.resetting"
        public static let bluetoothUnauthorizedPermissionStatus = "bluetooth.unauthorized"
        public static let bluetoothUnknownPermissionStatus = "bluetooth.unknown"
        public static let bluetoothUnsupportedPermissionStatus = "bluetooth.unsuppoertd"
        
    }
    
    class Setup{
        public static let identifierDevice = "chi.identifier.device"
        public static let totalInteractionsKey = "chi.interactions.total"
        public static let timeBlockKeyPreference = "chi.preference.timeBlock"
        public static let scanTime : Double = 10
        public static let minRSSIPower : Double = -60
        public static let maxRSSIPower : Double = 100
        public static let minCounterIdentifierToPush = 1
    }
    
}