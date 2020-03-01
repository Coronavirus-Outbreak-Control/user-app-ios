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
    public var timeBlock : String
    public var identifier : String
    public var rssi : Double
    public var counter : Int64
    
    public init(identifier : String, rssi : Double, timestamp : Date, timeBlock : String, counter: Int64){
        self.timestamp = timestamp
        self.identifier = identifier
        self.rssi = rssi
        self.timeBlock = timeBlock
        self.counter = counter
    }
    
}
