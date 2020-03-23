//
//  BluetoothOffViewController.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 27/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit

class BluetoothOffViewController: StatusBarViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("BLUETOOTH OFF VIEW CONTROLLER")
        
        self.run()
    }
    
    func run(){
        NotificationCenter.default.addObserver(self, selector: #selector(changedBluetoothStatus(notification:)), name: NSNotification.Name(Constants.Notification.bluetoothChangeStatus), object: nil)
        print("RECEIVED STATUS", BluetoothManager.shared.getPermissionStatus(), BluetoothManager.shared.getBluetoothStatus())
        switch BluetoothManager.shared.getPermissionStatus() {
        case .allowed:
            #if targetEnvironment(simulator)
            // your code
            print("is simulator")
            self.goNext()
            #endif
            if BluetoothManager.shared.getBluetoothStatus() == .on{
                self.goNext()
            }
            if BluetoothManager.shared.getBluetoothStatus() == .off{
            }
            if BluetoothManager.shared.getBluetoothStatus() == .resetting{
            }
            break
        case .denied, .notDetermined:
            // we will wait for user to click on the button
            break
        case .notAvailable:
            self.goNext()
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
            self.goNext()
        case .off:
            self.bluetoothOff()
            break
        case .resetting:
            let alert : UIAlertController = AlertManager.getAlert(title: NSLocalizedString("Bluetooth", comment: "bluetooth title alert"), message: NSLocalizedString("The bluetooth seems to be resetting, please try later", comment: "bluetooth unavailable"))
            self.present(alert, animated: true)
            break
        case .notAvailable:
            self.goNext()
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
            print("bluetooth off view asking permission")
            // we will wait for user to click on the button
            BluetoothManager.shared.askUserPermission()
            break
        case .notAvailable:
            self.goNext()
            break
        }
    }
    
    func goNext(){
        print("dismissing view bluetooth")
        
        if StorageManager.shared.isFirstAccess(){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LocationViewController")
            UIApplication.shared.windows.first?.rootViewController = controller
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }else{
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
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func bluetoothOff(){
        let alert = AlertManager.getAlertConfirmation(title: NSLocalizedString("Bluetooth", comment: "bluetooth title alert"), message: NSLocalizedString("You need to enable the bluetooth, please Open Settings -> Bluetooth -> enable bluetooth", comment: "bluetooth off"), confirmAction: {action in
            
            guard let settingsUrl = URL(string: "App-Prefs:root=General&path=Bluetooth") else {
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
        let alert = AlertManager.getAlertConfirmation(title: NSLocalizedString("Bluetooth", comment: "bluetooth title alert"), message: NSLocalizedString("We need to access the bluetooth, please Open Settings -> CovidApp -> enable bluetooth access", comment: "bluetooth open app settings"), confirmAction: {action in
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
    
    @IBAction func skipNext(_ sender: Any) {
        self.goNext()
    }
    
}
