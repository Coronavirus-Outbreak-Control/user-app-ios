//
//  MainViewController.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 25/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit
import CoreBluetooth

class MainViewController: StatusBarViewController {
    
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    private var counterHidden : Int = 0
    @IBOutlet weak var debugButton: UIButton!
    @IBOutlet weak var viewBackgroundTitle: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageButton: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.updateStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.updateStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("LOADING MAIN")
        self.run()
        
//        scrollView.contentSize = CGSize(width: view.bounds.width, height: 1175)
        self.updateStatus()
        
        print("IDENTIFIER", Bundle.main.bundleIdentifier)
        if Bundle.main.bundleIdentifier!.contains("debug"){
            self.debugButton.isHidden = false
            self.debugButton.isEnabled = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.updateStatus()
    }
    
    private func run(){
        
        self.updateStatus()
        
        let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { timer in
            self.updateStatus()
        })
        
        if let identifierDevice = StorageManager.shared.getIdentifierDevice(){
            print("identifier device:", identifierDevice)
            self.qrCodeImage.image = Utils.generateQRCode(identifierDevice.description)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(statusChanged), name: NSNotification.Name(Constants.Notification.bluetoothChangeStatus), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(statusChanged), name: NSNotification.Name(Constants.Notification.locationChangeStatus), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(statusChanged), name: NSNotification.Name(Constants.Notification.notificationChangeStatus), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePatientStatus), name: NSNotification.Name(Constants.Notification.patientChangeStatus), object: nil)

    }
    
    @objc private func statusChanged(){
        if !Utils.isActive(){
            if Thread.isMainThread{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "InactiveViewController")
                UIApplication.shared.windows.first?.rootViewController = controller
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }else{
                DispatchQueue.main.sync {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "InactiveViewController")
                    UIApplication.shared.windows.first?.rootViewController = controller
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }
            }
        }
    }
    
    @objc func updatePatientStatus(){
        if Thread.isMainThread{
            self.updateStatus()
        }else{
            DispatchQueue.main.async {
                self.updateStatus()
            }
        }
    }
    
    private func updateStatus(){
        //avoid updating status

        if StorageManager.shared.getPushId() == nil{
            print("no push if, gonna register")
            if NotificationManager.shared.getStatus() == NotificationManager.PermissionStatus.allowed{
                NotificationManager.shared.requestPermission({
                    granted in
                    print("permission grant is", granted)
                })
            }
        }
        
        if let data = PushNotificationData.readNotificationDate(){
            
            if let status = data.status{
                let warningLevel = data.warningLevel ?? 0
                
                var text : String = NSLocalizedString("No risk detected", comment: "No risk detected")
                var msg : String = NSLocalizedString("Normal Status message", comment: "Normal Status message")
                var color = Constants.UI.colorStandard
                
                if warningLevel < Constants.UI.warningLevelColors.count{
                    color = Constants.UI.warningLevelColors[warningLevel]
                }
                
                var titleColor = UIColor(red: 51 / 255, green: 51 / 255, blue: 51 / 255, alpha: 1)
                
                switch status {
                case 1:
                    print("infected status")
                    text = NSLocalizedString("Infected", comment: "Infected")
                    msg = NSLocalizedString("Infected Status message", comment: "Infected Status message")
                    break
                case 2:
                    print("suspect status")
                    text = NSLocalizedString("Suspect", comment: "Suspect status")
                    break
                case 3:
                    print("healed status")
                    text = NSLocalizedString("Healed", comment: "Healed status")
                    msg = NSLocalizedString("Healed Status message", comment: "Healed Status message")
                    titleColor = .white
                    break
                case 4:
                    print("low risk")
                    text = NSLocalizedString("Low risk", comment: "Low risk")
                    msg = NSLocalizedString("Quarantine Status message", comment: "Quarantine Status message")
                    titleColor = .white
                    break
                case 5:
                    print("mid risk")
                    text = NSLocalizedString("Mid risk", comment: "Mid risk")
                    msg = NSLocalizedString("Quarantine Status message", comment: "Quarantine Status message")
                    titleColor = .white
                    break
                case 6:
                    print("high risk")
                    text = NSLocalizedString("High risk", comment: "High risk")
                    msg = NSLocalizedString("Quarantine Status message", comment: "Quarantine Status message")
                    titleColor = .white
                    break
                default:
                    text = NSLocalizedString("No risk detected", comment: "No risk detected")
                    msg = NSLocalizedString("Normal Status message", comment: "Normal Status message")
                    color = Constants.UI.colorStandard
                }
                self.titleLabel.text = text
                self.titleLabel.textColor = titleColor
                self.viewBackgroundTitle.backgroundColor = color
                if let message = data.message{
                    self.messageLabel.text = message
                }else{
                    self.messageLabel.text = msg
                }
            }
        }
    }
    
    @IBAction func howItWorks(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HowItWorksViewController") as! HowItWorksViewController
        self.present(nextViewController, animated:true, completion: nil)
    }
    
    @IBAction func shareFacebook(_ sender: Any) {
        print("facebook")
        ShareManager.shareFacebook(self)
    }
    
    @IBAction func shareTwitter(_ sender: Any) {
        print("twitter")
        ShareManager.shareTwitter(self)
    }
    
    @IBAction func shareWhatsapp(_ sender: Any) {
        print("whatsapp")
        ShareManager.shareWhatsapp(self)
    }
    
    @IBAction func shareSMS(_ sender: Any) {
        print("SMS")
        ShareManager.shareSMS(self)
    }
    
    @IBAction func shareEmail(_ sender: Any) {
        print("email")
        ShareManager.shareEmail(self)
    }
    
    @IBAction func shareCopyLink(_ sender: Any) {
        print("copylink")
        ShareManager.copyLink(self)
    }
    
    @IBAction func debugInteractions(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "BluetoothTableViewController") as! BluetoothTableViewController
        self.present(nextViewController, animated:true, completion: nil)
    }
    
    @IBAction func messageActionMoreInfo(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "VirologistInformationViewController") as! VirologistInformationViewController
        self.present(nextViewController, animated:true, completion: nil)
    }
    
    @IBAction func showID(_ sender: Any) {
        if let did = StorageManager.shared.getIdentifierDevice(){
            
            var sum = 0
            for char in did.description{
                sum += Int(char.description) ?? 0
            }
            let didChecksum = sum.description.last ?? "0"
            
            let alert : UIAlertController = AlertManager.getAlert(title: "ID", message: did.description + didChecksum.description)
            self.present(alert, animated: true)
        }
        //TODO handle no id ?
    }
}
