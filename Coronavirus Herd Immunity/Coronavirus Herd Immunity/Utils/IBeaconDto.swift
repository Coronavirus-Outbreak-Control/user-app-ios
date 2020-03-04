//
//  PeripheralDto.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 29/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation

class IBeaconDto{
    
    public var timestamp : Date
    public var identifier : Int64
    public var rssi : Int64
    public var counter : Int64
    
    public init(identifier : Int64, timestamp : Date, counter: Int64, rssi: Int64){
        self.timestamp = timestamp
        self.identifier = identifier
        self.rssi = rssi
        self.counter = counter
    }
    
}
