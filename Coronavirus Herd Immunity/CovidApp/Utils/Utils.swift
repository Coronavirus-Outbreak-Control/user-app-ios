//
//  Utils.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 29/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit
import CoreImage
import Foundation

class Utils{
    
    public static func getTimeBlock(_ date : Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-"
        let s = dateFormatter.string(from: date)
        let hour = Calendar.current.component(.hour, from: date)
        let moduleHour : Int = hour / 4
        return s + String(moduleHour)
    }
    
    public static func getDayBlock(_ date : Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    public static func generateQRCode(_ deviceId: String) -> UIImage? {
        let formatted = "covid-outbreak-control:" + deviceId
        let data = formatted.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    public static func randomUUID() -> String {
        return UUID().uuidString
    }
    
    public static func randomInt() -> Int{
        return Int(arc4random_uniform(1000)) + 1
    }
    
    public static func getMinorFromInt(_ value : Int) -> Int{
        return Int(value / Constants.Setup.moduleMinorMajorVersion)
    }
    
    public static func getMajorFromInt(_ value : Int) -> Int{
        return Int(value % Constants.Setup.moduleMinorMajorVersion)
    }
    
    public static func buildIdentifierBy(minor: Int, major: Int) -> Int64{
        return Int64(minor * Constants.Setup.moduleMinorMajorVersion + major)
    }
    
    public static func isActive() -> Bool{
        var notification = false
        if let n = NotificationManager.shared.getStatus(){
            notification = n == .allowed
        }
        return BluetoothManager.shared.isBluetoothUsable() &&
        LocationManager.shared.getPermessionStatus() == .allowedAlways && notification
    }
    
}
