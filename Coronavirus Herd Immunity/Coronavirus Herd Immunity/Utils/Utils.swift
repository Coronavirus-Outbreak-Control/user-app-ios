//
//  Utils.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 29/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

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
    
}
