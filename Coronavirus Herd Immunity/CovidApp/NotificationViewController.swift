//
//  NotificationViewController.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 16/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit

class NotificationViewController : StatusBarViewController{
    
    override func viewDidLoad() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        StorageManager.shared.setFirstAccess(false)
        print("NOTIFICATION VIEW CONTROLLER")
    }
    
    private func run(){
        print("running")
        NotificationManager.shared.getAuthorizationStatus({
        status in
            print("STATUS", status)
            if status == .allowed{
                DispatchQueue.main.sync {
                    self.goNext()
                    NotificationCenter.default.post(name: NSNotification.Name(Constants.Notification.notificationChangeStatus), object: true)
                }
            }
        })
    }
    
    private func manageStatus(_ status : NotificationManager.PermissionStatus){
        switch(status){
        case .allowed:
            self.goNext()
            NotificationCenter.default.post(name: NSNotification.Name(Constants.Notification.notificationChangeStatus), object: true)
            break
        case .denied:
            let alert = AlertManager.getAlertConfirmation(title: NSLocalizedString("Notification", comment: "notification title alert"), message: NSLocalizedString("If you’ve been close to an infected person in the past two weeks we will notify you. That’s it, just one notification.", comment: "notification open"), confirmAction: {action in
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
            break
        case .notDetermined:
            NotificationManager.shared.requestPermission({
                granted in
                if granted{
                    DispatchQueue.main.sync {
                        self.goNext()
                        NotificationCenter.default.post(name: NSNotification.Name(Constants.Notification.notificationChangeStatus), object: true)
                    }
                }
            })
            break
        }
    }
    
    private func handleStatus(){
        print("handling status")
        
        if let status = NotificationManager.shared.getStatus(){
            print("cached status", status)
            return manageStatus(status)
        }
        
        NotificationManager.shared.getAuthorizationStatus({
            status in
            print("requested status", status)
            DispatchQueue.main.sync {
                return self.manageStatus(status)
            }
            
        })
    }
    
    private func goNext(){
        print("going next notification")
        self.dismiss(animated: true, completion: nil)
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

    @IBAction func giveNotification(_ sender: Any) {
        print("give notification")
        self.handleStatus()
    }
    
    @IBAction func skipNext(_ sender: Any) {
        self.goNext()
    }
    
    
}
