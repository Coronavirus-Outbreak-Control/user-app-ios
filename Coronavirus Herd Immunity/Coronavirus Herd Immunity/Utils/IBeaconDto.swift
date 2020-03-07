//
//  PeripheralDto.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 29/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation


class IBeaconDto: Codable {    
    public var timestamp : Date
    public var identifier : Int64
    public var rssi : Int64
    /* TODO: add lat and lng of type Double */
    
    public init(identifier : Int64, timestamp : Date, rssi: Int64){
        self.timestamp = timestamp
        self.identifier = identifier
        self.rssi = rssi
    }
    
}
