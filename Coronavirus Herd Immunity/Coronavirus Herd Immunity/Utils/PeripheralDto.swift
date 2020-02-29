//
//  PeripheralDto.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 29/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation

class PeripheralDto{
    
    public var timestamp : Date
    public var day : String
    public var identifier : String
    public var rssi : Float
    
    public init(identifier : String, rssi : Float, timestamp : Date, day : String){
        self.timestamp = timestamp
        self.identifier = identifier
        self.rssi = rssi
        self.day = day
    }
    
}
