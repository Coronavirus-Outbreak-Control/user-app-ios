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

    @IBOutlet weak var getStartedButton: RoundButton!
    @IBOutlet weak var spinnerLoadingIndicator: UIActivityIndicatorView!
    let recaptcha = try? ReCaptcha(
        apiKey: "6Ldiu-QUAAAAAE8oOqLZizOnEq42Ar9tNMIj8WXQ",
        baseURL: URL(string: "http://recaptcha.covidapp-alert.com/index.html")!
    )
    
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
        
        if let _ = StorageManager.shared.getIdentifierDevice(){
            self.continueNavigation()
        }else{
            self.getStartedButton.isEnabled = false
            self.spinnerLoadingIndicator.isHidden = false
            recaptcha?.configureWebView { [weak self] webview in
                webview.frame = self?.view.bounds ?? CGRect.zero
            }
            
            recaptcha?.validate(on: view) { [weak self] (result: ReCaptchaResult) in
                print("VALIDATION")
                
                do{
                    let googleToken = try result.dematerialize()
                    print("GOOGLE TOKEN", googleToken)
                    ApiManager.shared.handshakeNewDevice(googleToken: googleToken) {
                        deviceID, token, error in
                        print("REGISTERED")
                        if let did = deviceID{
                            DispatchQueue.main.sync {
                                self?.getStartedButton.isEnabled = true
                                StorageManager.shared.setIdentifierDevice(Int(did))
                                self?.continueNavigation()
                            }
                        }else{
                            DispatchQueue.main.sync {
                                self?.getStartedButton.isEnabled = true
                                let title = NSLocalizedString("Alert", comment: "Generic alert")
                                let message = NSLocalizedString("We couldn't verify your identity, please check your internet connection and try again later.", comment: "Error response code from api")
                                let alert = AlertManager.getAlert(title: title, message: message)
                                self?.present(alert, animated: true)
                            }
                        }
                    }
                }catch let error{
                    print("ERROR ON REGISTRATION", error)
                    DispatchQueue.main.sync {
                        self?.getStartedButton.isEnabled = true
                        let title = NSLocalizedString("Alert", comment: "Generic alert")
                        let message = NSLocalizedString("We couldn't verify your identity, please check your internet connection and try again later.", comment: "Google validation not passed")
                        let alert = AlertManager.getAlert(title: title, message: message)
                        self?.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    private func continueNavigation(){
        self.dismiss(animated: true, completion: nil)
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

