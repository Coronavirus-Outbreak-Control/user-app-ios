//
//  LocationViewController.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 02/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit

// https://forums.developer.apple.com/thread/117256

class LocationViewController : ViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("LOCATION VIEW CONTROLLER")
        NotificationCenter.default.addObserver(self, selector: #selector(changedLocationAuthorization(notification:)), name: NSNotification.Name(Constants.Notification.locationChangeStatus), object: nil)
        self.run()
    }
    
    @objc func changedLocationAuthorization(notification: NSNotification){
        print("change location status notification received")
        if let status = notification.object as? LocationManager.AuthorizationStatus{
            print(status)
            if status == .allowedAlways{
                return self.goNext()
            }
//            return handleChangeAuthorizationStatus(status)
        }else{
            print("WTF LOCATION?")
        }
    }
    
    func goNext(){
        print("dismissing view location")
        
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "ShareLocationViewController")
//        UIApplication.shared.windows.first?.rootViewController = controller
//        UIApplication.shared.windows.first?.makeKeyAndVisible()
        
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ShareLocationViewController") as! ShareLocationViewController
//        nextViewController.modalPresentationStyle = .fullScreen
//        self.present(nextViewController, animated:true, completion:nil)

        if StorageManager.shared.isFirstAccess(){
            print("gonna open notification view")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NotificationViewController")
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
    
    @IBAction func helpMoreAction(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ShareLocationViewController") as! ShareLocationViewController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
        
//        self.dismiss(animated: true, completion: nil)
    }
    
    private func handleChangeAuthorizationStatus(_ status : LocationManager.AuthorizationStatus){
        print("handleChangeAuthorizationStatus", status)
        switch status {
        case .allowedAlways:
            return self.goNext()
        case .allowedWhenInUse:
            let alert = AlertManager.getAlertConfirmation(title: NSLocalizedString("Location", comment: "location title alert"), message: NSLocalizedString("We need to access always the location, please Open Settings -> Coronavirus Herd Immunity -> Location -> Always", comment: "location open always"), confirmAction: {action in
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
        case .notAvailable:
            let alert : UIAlertController = AlertManager.getAlert(title: NSLocalizedString("Location", comment: "location title alert"), message: NSLocalizedString("The location seems to be unavailable on your device", comment: "location unavailable"))
            self.present(alert, animated: true)
            break
        case .notDetermined:
            print("GONNA ASK USER")
            LocationManager.shared.requestAlwaysPermission()
            break
        case .denied:
            if LocationManager.shared.isServiceEnabledForApp(){
                let alert = AlertManager.getAlertConfirmation(title: NSLocalizedString("Location", comment: "location title alert"), message: NSLocalizedString("We need to access the location, please Open Settings -> Coronavirus Herd Immunity -> enable location access", comment: "location open "), confirmAction: {action in
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
            }else{
                let alert = AlertManager.getAlertConfirmation(title: NSLocalizedString("Location", comment: "location title alert"), message: NSLocalizedString("You need to enable the location, please Open Settings -> Privacy -> Location services", comment: "location denied"), confirmAction: {action in
                    
                    guard let settingsUrl = URL(string: "App-Prefs:root=LOCATION_SERVICES") else {
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
            // waiting from user action
            break
        }
    }
    
    @IBAction func enableLocationAction(_ sender: Any) {
        print("asking to enable location")
        self.handleChangeAuthorizationStatus(LocationManager.shared.getPermessionStatus())
    }
    
    private func run(){
        print("location status", LocationManager.shared.getPermessionStatus())
        switch LocationManager.shared.getPermessionStatus() {
        case .allowedAlways:
            return self.goNext()
        case .notAvailable:
            break
        case .notDetermined, .denied, .allowedWhenInUse:
            print("not determined waiting for user")
            // waiting from user action
            break
        }
    }
    
    @IBAction func skipNext(_ sender: Any) {
        self.goNext()
    }
    
    
}
