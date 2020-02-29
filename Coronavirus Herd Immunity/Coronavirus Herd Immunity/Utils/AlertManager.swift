//
//  AlertManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 27/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit
import Foundation

class AlertManager{
    
    // https://learnappmaking.com/uialertcontroller-alerts-swift-how-to/
    
    public static func getActionSheet(title: String, message: String ) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        return alert
    }

    public static func getAlert(title: String, message: String ) -> UIAlertController{
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    //        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
    //        self.present(alert, animated: true)
            return alert
        }
    
}
