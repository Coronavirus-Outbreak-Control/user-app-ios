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
    /* TODO: add lat and lng of type Double */
    
    public init(identifier : Int64, timestamp : Date, rssi: Int64, interval : Double = Constants.Setup.minimumIntervalTime){
        self.timestamp = timestamp
        self.identifier = identifier
        self.rssi = rssi
        self.interval = interval
    }
    
    
    var debugDescription: String{
        return "id: \(self.identifier), timestamp: \(self.timestamp), rssi: \(self.rssi), interval: \(self.interval)"
    }
    
}
