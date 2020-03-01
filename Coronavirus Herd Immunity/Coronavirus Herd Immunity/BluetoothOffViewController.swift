//
//  BluetoothOffViewController.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 27/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit

class BluetoothOffViewController: UIViewController {
    
    @IBOutlet weak var bluetoothStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("BLUETOOTH OFF VIEW CONTROLLER")
        self.run()
    }
    
    func run(){
        NotificationCenter.default.addObserver(self, selector: #selector(changedBluetoothStatus(notification:)), name: NSNotification.Name(Costants.Notification.bluetoothChangeStatus), object: nil)
        
        switch BluetoothManager.shared.getPermissionStatus() {
        case .allowed:
            if BluetoothManager.shared.getBluetoothStatus() == .on{
                self.openMainViewController()
            }
            if BluetoothManager.shared.getBluetoothStatus() == .off{
                self.bluetoothStatus.text = NSLocalizedString("off", comment: "bluetooth switched off")
            }
            if BluetoothManager.shared.getBluetoothStatus() == .resetting{
                self.bluetoothStatus.text = NSLocalizedString("resetting", comment: "bluetooth resetting")
            }
            break
        case .denied, .notDetermined:
            // we will wait for user to click on the button
            break
        case .notAvailable:
            self.bluetoothStatus.text = NSLocalizedString("not available", comment: "bluetooth not available on the device")
            self.bluetoothNotAvailable()
            break
        }
    }
    
    @objc func changedBluetoothStatus(notification: NSNotification){
        print("change status notification received")
        if let status = notification.object as? BluetoothManager.Status{
            return handleBluetoothStatus(status)
        }else{
            print("WTF?")
        }
    }
    
    private func handleBluetoothStatus(_ status : BluetoothManager.Status){
        print("handling status: ", status)
        switch status {
        case .on:
            self.openMainViewController()
        case .off:
            self.bluetoothOff()
            break
        case .resetting:
            let alert : UIAlertController = AlertManager.getAlert(title: NSLocalizedString("Bluetooth", comment: "bluetooth title alert"), message: NSLocalizedString("The bluetooth seems to be resetting, please try later", comment: "bluetooth unavailable"))
            self.present(alert, animated: true)
            break
        case .notAvailable:
            self.bluetoothNotAvailable()
            break
        case .unauthorized:
            self.bluetoothDeniedOrUnauthorized()
        }
    }
    
    @IBAction func openBluetoothAction(_ sender: Any) {
        switch BluetoothManager.shared.getPermissionStatus() {
        case .allowed:
            self.handleBluetoothStatus(BluetoothManager.shared.getBluetoothStatus())
            break
        case .denied:
            self.bluetoothDeniedOrUnauthorized()
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
        print("dismissing view")
        self.dismiss(animated: true, completion: nil)
    }
    
    func bluetoothOff(){
        let alert = AlertManager.getAlertConfirmation(title: NSLocalizedString("Bluetooth", comment: "bluetooth title alert"), message: NSLocalizedString("You need to enable the bluetooth, please Open Settings -> Bluetooth -> enable bluetooth", comment: "bluetooth off"), confirmAction: {action in
            
            guard let settingsUrl = URL(string: "App-Prefs:root=General") else {
                print("NO SETTINGS GENERAL URL")
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings general opened: \(success)") // Prints true
                })
            }
        })
        self.present(alert, animated: true)
    }
    
    func bluetoothDeniedOrUnauthorized(){
        let alert = AlertManager.getAlertConfirmation(title: NSLocalizedString("Bluetooth", comment: "bluetooth title alert"), message: NSLocalizedString("We need to access the bluetooth, please Open Settings -> Coronavirus Herd Immunity -> enable bluetooth access", comment: "bluetooth unavailable"), confirmAction: {action in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                print("NO SETTINGS URL")
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        })
        self.present(alert, animated: true)
    }
    
    func bluetoothNotAvailable(){
        let alert : UIAlertController = AlertManager.getAlert(title: NSLocalizedString("Bluetooth", comment: "bluetooth title alert"), message: NSLocalizedString("The bluetooth seems to be unavailable on your device", comment: "bluetooth unavailable"))
        self.present(alert, animated: true)
    }
    
    @IBAction func howCanIHelpMoreAction(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HelpMoreViewController") as! HelpMoreViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
}
