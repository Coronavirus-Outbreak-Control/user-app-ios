//
//  Constants.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 27/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit
import Foundation

class Constants {
    
    class Notification{
        
        public static let bluetoothChangeStatus = "bluetooth.changeStatus"
        public static let locationChangeStatus = "location.changeStatus"
        public static let notificationChangeStatus = "notification.changeStatus"
        
        public static let patientChangeStatus = "notification.patient.changeStatus"
        
        public static let bluetoothPoweredOnPermissionStatus = "bluetooth.on"
        public static let bluetoothPoweredOffPermissionStatus = "bluetooth.off"
        public static let bluetoothResettingPermissionStatus = "bluetooth.resetting"
        public static let bluetoothUnauthorizedPermissionStatus = "bluetooth.unauthorized"
        public static let bluetoothUnknownPermissionStatus = "bluetooth.unknown"
        public static let bluetoothUnsupportedPermissionStatus = "bluetooth.unsupported"

    }
    
    class Setup{
        
        public static let uuidCHIdevice = "451720ea-5e62-11ea-bc55-0242ac130003"
        public static let beaconCHIidentifier = "com.coronaherdimmunity.myDeviceRegion"
        
        public static let alreadyAccessed = "chi.identifier.access"

        public static let backgroundPushIdentifier = "org.covidapp-coronavirus-outbreak-control.ios.backgroundInteractionPush"
        
        public static let statusDevice = "chi.identifier.status"
        public static let warningLevel = "chi.identifier.warning_level"
        public static let identifierDevice = "chi.identifier.device"
        public static let tokenJWT = "chi.identifier.tokenJWT"
        public static let pushIdentifier = "chi.identifier.push-notification"
        public static let totalInteractionsKey = "chi.interactions.total"
        public static let lastDatePushPreference = "chi.preference.lastDatePush"
        public static let pushDelay = "chi.preference.pushDelay"
        public static let locationNeeded = "chi.preference.locationNeeded"
        public static let shareLocation = "chi.preference.shareLocation"
        public static let pushInProgress = "chi.push.inProgress"
        public static let pushInProgressSince = "chi.push.inProgressSince"
        public static let distanceFilter = "chi.push.distanceFilter"
        public static let lastNextTry = "chi.push.lastNextTry"
        
        public static let defaultSecondsIntervalBetweenPushes : TimeInterval = 3600 * 1 // 1 day
        public static let secondsIntervalBetweenConcurrentPushes: TimeInterval = 5 // 5 seconds
        
        public static let version : Int = 5
        
        public static let scanTime : Double = 10
        public static let minRSSIPower : Double = -60
        public static let maxRSSIPower : Double = 100
        public static let minCounterIdentifierToPush = 1
        public static let timeAggregationIBeacons : TimeInterval = 180
        public static let minTimeSecondAggregation : TimeInterval = 30
        public static let minimumIntervalTime : Double = 10
        
        public static let moduleMinorMajorVersion : Int = 65536
    }
    
    class UI {
        public static let colorStandard : UIColor = UIColor(red: 51 / 255, green: 51 / 255, blue: 51 / 255, alpha: 1)
        public static let colorGreen : UIColor = UIColor(red: 0 / 255, green: 152 / 255, blue: 116 / 255, alpha: 1)
        public static let colorYellow : UIColor = UIColor(red: 236 / 255, green: 183 / 255, blue: 48 / 255, alpha: 1)
        public static let colorOrange : UIColor = UIColor(red: 238 / 255, green: 143 / 255, blue: 48 / 255, alpha: 1)
        public static let colorRed : UIColor = UIColor(red: 255 / 255, green: 111 / 255, blue: 97 / 255, alpha: 1)
        
        public static let warningLevelColors : [UIColor] = [colorStandard, colorGreen, colorYellow, colorOrange, colorRed]
    }
    
}
