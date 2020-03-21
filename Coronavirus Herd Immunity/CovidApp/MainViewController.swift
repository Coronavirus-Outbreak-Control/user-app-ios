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
    
    @IBOutlet weak var statusApp: UILabel!
    @IBOutlet weak var interactionsTotal: UILabel!
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var activeButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    private var counterHidden : Int = 0
    
    
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
        
        scrollView.contentSize = CGSize(width: view.bounds.width, height: 800)
        self.updateStatus()
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
            self.qrCodeImage.image = Utils.generateQRCode(from: identifierDevice.description)
        }
        let countInteractions = StorageManager.shared.countTotalInteractions().description
        self.interactionsTotal.text = countInteractions
        print("TOTAL INTERACTIONS", countInteractions)

        NotificationCenter.default.addObserver(self, selector: #selector(statusChanged), name: NSNotification.Name(Constants.Notification.bluetoothChangeStatus), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(statusChanged), name: NSNotification.Name(Constants.Notification.locationChangeStatus), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(statusChanged), name: NSNotification.Name(Constants.Notification.notificationChangeStatus), object: nil)

    }
    
    @objc private func statusChanged(){
        if !Utils.isActive(){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "InactiveViewController")
            UIApplication.shared.windows.first?.rootViewController = controller
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
    
    private func updateStatus(){
        
        let statusUser = StorageManager.shared.getStatusUser()
        if statusUser == 1{
            print("INFECTED")
            // infected
            self.statusApp.text = NSLocalizedString("Infected", comment: "Infected status")
            self.activeButton.titleLabel?.text = NSLocalizedString("Infected", comment: "Infected status")
            self.statusApp.textColor = UIColor(red: 255/255, green: 111/255, blue: 97/255, alpha: 1)
            self.activeButton.setTitleColor(UIColor(red: 255/255, green: 111/255, blue: 97/255, alpha: 1), for: .normal)
        }else if statusUser == 4{
            print("SUPECT")
            self.statusApp.text = NSLocalizedString("Suspect", comment: "Suspect status")
            self.activeButton.titleLabel?.text = NSLocalizedString("Suspect", comment: "Suspect status")
            self.statusApp.textColor = UIColor(red: 255/255, green: 111/255, blue: 97/255, alpha: 1)
            self.activeButton.setTitleColor(UIColor(red: 255/255, green: 111/255, blue: 97/255, alpha: 1), for: .normal)
        }
        
    }
    
    @IBAction func showHowCanIHelpMore(_ sender: Any) {
        print("GONNA PRESENT HELP MORE FROM MAIN")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HelpMoreViewController") as! HelpMoreViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    @IBAction func howItWorks(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HowItWorksViewController") as! HowItWorksViewController
        self.present(nextViewController, animated:true, completion: nil)
    }
    
    @IBAction func counterTotalInteractions(_ sender: Any) {
        self.counterHidden += 1
        print("counter is now at:", self.counterHidden)
        if(self.counterHidden > 10){
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "BluetoothTableViewController") as! BluetoothTableViewController
            self.present(nextViewController, animated:true, completion:nil)
        }
    }
}
