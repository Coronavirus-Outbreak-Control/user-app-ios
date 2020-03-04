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
    
    @IBOutlet weak var locationStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("LOCATION VIEW CONTROLLER")
        NotificationCenter.default.addObserver(self, selector: #selector(changedLocationAuthorization(notification:)), name: NSNotification.Name(Costants.Notification.locationChangeStatus), object: nil)
        self.run()
    }
    
    @objc func changedLocationAuthorization(notification: NSNotification){
        print("change location status notification received")
        if let status = notification.object as? LocationManager.AuthorizationStatus{
            print(status)
            return handleChangeAuthorizationStatus(status)
        }else{
            print("WTF LOCATION?")
        }
    }
    
    func openMainViewController(){
        print("dismissing view")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func helpMoreAction(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HelpMoreViewController") as! HelpMoreViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    private func handleChangeAuthorizationStatus(_ status : LocationManager.AuthorizationStatus){
        print("handleChangeAuthorizationStatus", status)
        switch status {
        case .allowedAlways:
            return self.openMainViewController()
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
        switch LocationManager.shared.getPermessionStatus() {
        case .allowedAlways:
            return self.openMainViewController()
        case .notAvailable:
            self.locationStatusLabel.text = NSLocalizedString("not available", comment: "location hardware not available")
            break
        case .notDetermined, .denied, .allowedWhenInUse:
            print("not determined waiting for user")
            // waiting from user action
            break
        }
    }
    
}
