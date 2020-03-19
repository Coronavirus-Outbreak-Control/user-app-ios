//
//  StatusBarViewController.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 14/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit

class StatusBarViewController : UIViewController{
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            // Fallback on earlier versions
            return .lightContent
        }
    }
    
}
