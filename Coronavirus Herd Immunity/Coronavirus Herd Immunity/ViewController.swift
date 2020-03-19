//
//  ViewController.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 23/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit

class ViewController: StatusBarViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBluetoothChangeStatus), name: NSNotification.Name(Constants.Notification.bluetoothChangeStatus), object: nil)
        
    }
    
    @objc private func handleBluetoothChangeStatus(notification: NSNotification){
        if BluetoothManager.shared.isBluetoothUsable() && LocationManager.shared.getPermessionStatus() == .allowedAlways{
            IBeaconManager.shared.startAdvertiseDevice()
            IBeaconManager.shared.registerListener()
        }
    }

    @IBAction func letsGetStarted(_ sender: Any) {
        
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
        
    }
    
    @IBAction func howItWorks(_ sender: Any) {
        print("VIEW CONTROLLER")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HowItWorksViewController") as! HowItWorksViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
}

