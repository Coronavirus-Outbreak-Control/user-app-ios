//
//  DeviceInfoManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Neil Kakkar on 07/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit

class DeviceInfoManager {
    
    static public func getModel() -> String {
        return UIDevice.current.model
    }
    
    static public func getVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    static public func getId() -> String {
        return (UIDevice.current.identifierForVendor ?? UUID()).uuidString
    }
}
