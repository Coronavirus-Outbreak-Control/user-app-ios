//
//  InactiveViewController.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 18/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit

class InactiveViewController : StatusBarViewController{
    
    @IBOutlet weak var bluetoothLabel: UILabel!
    @IBOutlet weak var bluetoothButton: UIButton!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    
    
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    
    private let colorGreen : UIColor = UIColor(red: 0, green: 152 / 255, blue: 116 / 255, alpha: 1)
    private let colorRed : UIColor = UIColor(red: 1, green: 111 / 255, blue: 97 / 255, alpha: 1)
    
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear INACTIVE")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("VIEW DID DISAPPEAR INACTIVE")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("VIEW WILL DISAPPEAR INACTIVE")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("VIEW DID APPEAR LOADING INACTIVE")
        refresh()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusChanged), name: NSNotification.Name(Constants.Notification.bluetoothChangeStatus), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(statusChanged), name: NSNotification.Name(Constants.Notification.locationChangeStatus), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(statusChanged), name: NSNotification.Name(Constants.Notification.notificationChangeStatus), object: nil)
    }
    
    @objc private func statusChanged(){
        if Utils.isActive(){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "MainViewController")
            UIApplication.shared.windows.first?.rootViewController = controller
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
        if Thread.isMainThread{
            print("is main thread, refreshing")
            refresh()
        }else{
            print("not the main thread")
        }
    }
    
    @objc func refresh(){
        print("REFRESHING INACTIVE")
        var granted = true
        
        if !BluetoothManager.shared.isBluetoothUsable(){
            bluetoothLabel.text = "Give bluetooth permission"
            bluetoothButton.isHidden = false
            granted = false
        }else{
            bluetoothLabel.text = "Bluetooth permission"
            bluetoothLabel.textColor = colorGreen
            bluetoothButton.isHidden = true
        }
        
        if LocationManager.shared.getPermessionStatus() != .allowedAlways{
            locationLabel.text = "Enable location access"
            locationButton.isHidden = false
            granted = false
        }else{
            print("XXX location")
            locationLabel.text = "Location access"
            locationLabel.textColor = colorGreen
            locationButton.isHidden = true
        }
        
        var notificationAllowed = false
        if let s = NotificationManager.shared.getStatus(){
            print("FOUND NOTIFICATION STATUS", s)
            notificationAllowed = s == .allowed
        }
        
        if !notificationAllowed{
            notificationLabel.text = "Enable notifications"
            notificationButton.isHidden = false
            granted = false
        }else{
            print("XXX notification")
            notificationLabel.text = "Notifications"
            notificationLabel.textColor = colorGreen
            notificationButton.isHidden = true
        }
        
        if granted{
            openMain()
        }
    }
    
    private func openMain(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        UIApplication.shared.windows.first?.rootViewController = controller
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func bluetoothAction(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "BluetoothOffViewController") as! BluetoothOffViewController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    @IBAction func locationAction(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    @IBAction func notificationAction(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
    }
    
}
