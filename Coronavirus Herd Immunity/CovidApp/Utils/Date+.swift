//
//  Date+strings.swift
//  Coronavirus Herd Immunity
//
//  Created by Neil Kakkar on 11/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func dateByAddingTimeInterval(_ value: TimeInterval) -> Date {
        return Date(timeInterval: value, since: self)
    }
    
    func dateByAddingDays(_ days: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.day = days
        return Calendar.current.date(byAdding: dateComponents, to: self) ?? self
    }

    func dateByRemovingDays(_ days: Int) -> Date {
        return self.dateByAddingDays(-days)
    }

}

