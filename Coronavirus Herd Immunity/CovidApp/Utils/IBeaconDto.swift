//
//  PeripheralDto.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 29/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation


class IBeaconDto: Codable, CustomDebugStringConvertible {
    public var timestamp : Date
    public var identifier : Int64
    public var rssi : Int64
    public var interval : Double
    public var platform : String
    public var distance : Int
    /* TODO: add lat and lng of type Double */
    
    public init(identifier : Int64, timestamp : Date, rssi: Int64, distance : Int, interval : Double = Constants.Setup.minimumIntervalTime){
        self.timestamp = timestamp
        self.identifier = identifier
        self.rssi = rssi
        self.interval = interval
        self.platform = "i"
        self.distance = distance
    }
    
    
    var debugDescription: String{
        var d = "f"
        if self.distance == 1{
            d = "i"
        }
        if self.distance == 2{
            d = "n"
        }
        
        return "id: \(self.identifier), timestamp: \(self.timestamp), rssi: \(self.rssi), distance: \(d), interval: \(self.interval)"
    }
    
}
