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
        if BluetoothManager.shared.isBluetoothUsable() && LocationManager.shared.getPermessionStatus() == .allowedAlways{
            print("background operations")
            IBeaconManager.shared.registerListener()
            LocationManager.shared.startMonitoring()
            IBeaconManager.shared.startAdvertiseDevice()
        }
    }
    
}
