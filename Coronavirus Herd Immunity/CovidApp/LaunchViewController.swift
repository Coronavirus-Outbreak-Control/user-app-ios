//
//  LaunchViewController.swift
//  CovidApp - Covid Community Alert
//
//  Created by Antonio Romano on 31/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit
import Foundation

class LaunchViewController : StatusBarViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.dismiss(animated: true, completion: nil)
        if let did = StorageManager.shared.getIdentifierDevice(){
            print("LAUNCH VIEW CONTROLLER FOUND DID", did)
            
            self.dismiss(animated: true, completion: nil)
            
            print("FIRST ACCESS")
            
            if StorageManager.shared.isFirstAccess(){
                print("FIRST ACCESS")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "BluetoothOffViewController")
                UIApplication.shared.windows.first?.rootViewController = controller
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }else{
                print("LATER ACCESS")
                if Utils.isActive(){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "MainViewController")
                    UIApplication.shared.windows.first?.rootViewController = controller
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }else{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "InactiveViewController")
                    UIApplication.shared.windows.first?.rootViewController = controller
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }
            }
            
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ViewController")
            UIApplication.shared.windows.first?.rootViewController = controller
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
    
}
