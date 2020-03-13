//
//  BackgroundManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 11/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation

class BackgroundManager{
    
    public static func backroundOperations(){
        if BluetoothManager.shared.isBluetoothUsable() && LocationManager.shared.getPermessionStatus() == .allowedAlways{
            print("background operations")
            IBeaconManager.shared.startAdvertiseDevice()
            IBeaconManager.shared.registerListener()
            LocationManager.shared.startMonitoring()
        }
        CoreManager.pushInteractions(isBackground: true)
    }
    
}
