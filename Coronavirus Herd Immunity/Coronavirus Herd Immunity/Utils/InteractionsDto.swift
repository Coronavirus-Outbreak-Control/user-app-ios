//
//  InteractionsDto.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 29/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation

class InteractionsDto{
    
    public var count : Int64
    public var key : String
    
    public init(key: String, count: Int64){
        self.key = key
        self.count = count
    }
    
}
