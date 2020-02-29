//
//  BluetoothOffViewController.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 27/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit

class BluetoothOffViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("BLUETOOTH OFF VIEW CONTROLLER")
    }
    
    func run(){
        NotificationCenter.default.addObserver(self, selector: #selector(changedBluetoothStatus(notification:)), name: NSNotification.Name(Costants.Notification.bluetoothChangeStatus), object: nil)
        
        switch BluetoothManager.shared.getPrmissionStatus() {
        case .allowed:
            self.openMainViewController()
            break
        case .denied, .notDetermined:
            // we will wait for user to click on the button
            break
        case .notAvailable:
            self.bluetoothNotAvailable()
            break
        }
    }
    
    @objc func changedBluetoothStatus(notification: NSNotification){
        if let status = notification.object as? BluetoothManager.Status{
            switch status {
            case .on, .off:
                self.openMainViewController()
                break
            case .notAvailable:
                break
            case .resetting:
                break
            case .unauthorized:
                break
            }
        }else{
            print("WTF?")
        }
    }
    
    @IBAction func openBluetoothAction(_ sender: Any) {
        switch BluetoothManager.shared.getPrmissionStatus() {
        case .allowed:
            self.openMainViewController()
            break
        case .denied:
            let alert : UIAlertController = AlertManager.getAlert(title: NSLocalizedString("Bluetooth", comment: "bluetooth title alert"), message: NSLocalizedString("We need to access the bluetooth, please Open Settings -> Coronavirus Herd Immunity -> enable bluetooth access", comment: "bluetooth unavailable"))
            self.present(alert, animated: true)
            break
        case .notDetermined:
            // we will wait for user to click on the button
            BluetoothManager.shared.askUserPermission()
            break
        case .notAvailable:
            self.bluetoothNotAvailable()
            break
        }
    }
    
    func openMainViewController(){
        print("we shouldn't be here! XD")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        UIApplication.shared.windows.first?.rootViewController = controller
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    func bluetoothNotAvailable(){
        let alert : UIAlertController = AlertManager.getAlert(title: NSLocalizedString("Bluetooth", comment: "bluetooth title alert"), message: NSLocalizedString("The bluetooth seems to be unavailable on your devide", comment: "bluetooth unavailable"))
        self.present(alert, animated: true)
    }
    
    
    @IBAction func howCanIHelpMoreAction(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HelpMoreViewController") as! HelpMoreViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
}
