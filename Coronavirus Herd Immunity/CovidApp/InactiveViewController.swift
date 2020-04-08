//
//  InactiveViewController.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 18/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit

// https://fluffy.es/scrollview-storyboard-xcode-11/
// https://medium.com/@tingyishih/ios-scrollview-constraints-8d8140d329a0

class InactiveViewController : StatusBarViewController{
    
    @IBOutlet weak var bluetoothButton: UIButton!
    @IBOutlet weak var bluetoothLabelButton: UIButton!
    @IBOutlet weak var bluetoothSeparator: UIView!
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var LocationLabelButton: UIButton!
    @IBOutlet weak var locationSeparator: UIView!
    
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var notificationLabelButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
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
        if Thread.isMainThread{
            print("main thread")
            refresh()
        }else{
            DispatchQueue.main.sync{
                print("main no main thread")
                refresh()
                
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusChanged), name: NSNotification.Name(Constants.Notification.bluetoothChangeStatus), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(statusChanged), name: NSNotification.Name(Constants.Notification.locationChangeStatus), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(statusChanged), name: NSNotification.Name(Constants.Notification.notificationChangeStatus), object: nil)
        
//        scrollView.contentSize = CGSize(width: view.bounds.width, height: 1125)
    }
    
    @objc private func statusChanged(){
        if Thread.isMainThread{
            print("is main thread, refreshing")
            if Utils.isActive(){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "MainViewController")
                UIApplication.shared.windows.first?.rootViewController = controller
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
            refresh()
        }else{
            DispatchQueue.main.sync{
                if Utils.isActive(){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "MainViewController")
                    UIApplication.shared.windows.first?.rootViewController = controller
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }
            }
            print("not the main thread")
        }
    }
    
    @objc func refresh(){
        print("REFRESHING INACTIVE")
        var granted = true
        
        if !BluetoothManager.shared.isBluetoothUsable(){
            bluetoothLabelButton.setTitle(NSLocalizedString("Give bluetooth permission", comment: "Give bluetooth permission"), for: .normal)
            bluetoothLabelButton.setTitleColor(colorRed, for: .normal)
            bluetoothLabelButton.isEnabled = true
            bluetoothButton.isHidden = false
            granted = false
        }else{
            bluetoothLabelButton.setTitleColor(colorGreen, for: .normal)
            bluetoothLabelButton.setTitle(NSLocalizedString("Bluetooth permission", comment: "Bluetooth permission"), for: .normal)
            bluetoothLabelButton.isEnabled = false
            bluetoothButton.isHidden = true
        }
        
        if LocationManager.shared.getPermessionStatus() != .allowedAlways{
            LocationLabelButton.setTitle(NSLocalizedString("Enable location access", comment: "Enable location access"), for: .normal)
            LocationLabelButton.setTitleColor(colorRed, for: .normal)
            LocationLabelButton.isEnabled = true
            locationButton.isHidden = false
            granted = false
        }else{
            print("XXX location")
            LocationLabelButton.setTitle(NSLocalizedString("Location access", comment: "Location access"), for: .normal)
            LocationLabelButton.setTitleColor(colorGreen, for: .normal)
            LocationLabelButton.isEnabled = false
            locationButton.isHidden = true
        }
        
        var notificationAllowed = false
        if let s = NotificationManager.shared.getStatus(){
            print("FOUND NOTIFICATION STATUS", s)
            notificationAllowed = s == .allowed
        }
        
        if !notificationAllowed{
            notificationLabelButton.setTitle(NSLocalizedString("Enable notifications", comment: "Enable notifications"), for: .normal)
            notificationLabelButton.setTitleColor(colorRed, for: .normal)
            notificationLabelButton.isEnabled = true
            notificationButton.isHidden = false
            granted = false
        }else{
            print("XXX notification")
            notificationLabelButton.setTitle(NSLocalizedString("Notifications", comment: "Notifications"), for: .normal)
            notificationLabelButton.setTitleColor(colorGreen, for: .normal)
            notificationLabelButton.isEnabled = false
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
        if LocationManager.shared.getPermessionStatus() == .allowedWhenInUse{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LocationAlwaysViewController") as! LocationAlwaysViewController
            nextViewController.modalPresentationStyle = .fullScreen
            self.present(nextViewController, animated:true, completion:nil)
        }else{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
            nextViewController.modalPresentationStyle = .fullScreen
            self.present(nextViewController, animated:true, completion:nil)
        }
    }
    
    @IBAction func notificationAction(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    @IBAction func howItWorks(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HowItWorksViewController") as! HowItWorksViewController
        self.present(nextViewController, animated:true, completion: nil)
    }
    
    @IBAction func shareFacebook(_ sender: Any) {
        print("facebook inactive")
        ShareManager.shareFacebook(self)
    }
    
    @IBAction func shareTwitter(_ sender: Any) {
        print("facebook inactive inactive")
        ShareManager.shareTwitter(self)
    }
    
    @IBAction func shareWhatsapp(_ sender: Any) {
        print("whatsapp inactive")
        ShareManager.shareWhatsapp(self)
    }
    
    @IBAction func shareSMS(_ sender: Any) {
        print("SMS inactive")
        ShareManager.shareSMS(self)
    }
    
    @IBAction func shareEmail(_ sender: Any) {
        print("email inactive")
        ShareManager.shareEmail(self)
    }
    
    @IBAction func copyLink(_ sender: Any) {
        print("copylink inactive")
        ShareManager.copyLink(self)
    }
    
}
