//
//  ViewController.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 23/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit
import ReCaptcha
import RxSwift

class ViewController: StatusBarViewController {

    let recaptcha = try? ReCaptcha(
        apiKey: "6Ldiu-QUAAAAAE8oOqLZizOnEq42Ar9tNMIj8WXQ",
        baseURL: URL(string: "http://recaptcha.covidapp-alert.com/index.html")!
    )
    
    var canContinue : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBluetoothChangeStatus), name: NSNotification.Name(Constants.Notification.bluetoothChangeStatus), object: nil)
        
        
        if let _ = StorageManager.shared.getIdentifierDevice(){
            canContinue = true
        }else{
            recaptcha?.configureWebView { [weak self] webview in
                webview.frame = self?.view.bounds ?? CGRect.zero
            }
            
            recaptcha?.validate(on: view) { [weak self] (result: ReCaptchaResult) in
                print("VALIDATION")
                
                do{
                    let googleToken = try result.dematerialize()
                    print("GOOGLE TOKEN", googleToken)
                    ApiManager.shared.handshakeNewDevice(googleToken: googleToken) { deviceID, token in
                            StorageManager.shared.setIdentifierDevice(Int(deviceID))
                    }
                }catch let error{
                    print("ERROR ON REGISTRATION", error)
                }
            }
        }
        
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

