//
//  MainViewController.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 25/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit
import CoreBluetooth

class MainViewController: UIViewController {
    
    @IBOutlet weak var statusApp: UILabel!
    @IBOutlet weak var statusBluetooth: UILabel!
    @IBOutlet weak var interactionsDaily: UILabel!
    @IBOutlet weak var interactionsTotal: UILabel!
    @IBOutlet weak var qrCodeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("MAIN LOADED")
        self.run()
    }
    
    private func run(){
        if let identifierDevice = StorageManager.shared.getIdentifierDevice(){
            print("identifier device:", identifierDevice)
            self.qrCodeButton.setImage(Utils.generateQRCode(from: identifierDevice), for: .normal)
        }
        
        self.interactionsDaily.text = StorageManager.shared.countDailyInteractions().description
        self.interactionsTotal.text = StorageManager.shared.countTotalInteractions().description
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBluetoothChangeStatus), name: NSNotification.Name(Costants.Notification.bluetoothChangeStatus), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLocationChangeStatus(notification:)), name: NSNotification.Name(Costants.Notification.locationChangeStatus), object: nil)
        
        if BluetoothManager.shared.getPermissionStatus() != .allowed{
            print("permission not allowed")
            self.changeToBluetoothOffViewController()
        }else{
            print("blt status main", BluetoothManager.shared.getBluetoothStatus())
            if BluetoothManager.shared.getBluetoothStatus() == .on{
                return bluetoothAccessible()
            }else{
                if BluetoothManager.shared.getBluetoothStatus() != .notAvailable {
                    self.changeToBluetoothOffViewController()
                }
            }
        }
    }
    
    private func bluetoothAccessible(){
        // start device as IBeacon
        if BluetoothManager.shared.isBluetoothUsable(){
            // TODO:
            IBeaconManager.shared.startAdvertiseDevice()
            
            if LocationManager.shared.getPermessionStatus() == .allowedAlways{
                //TODO: we are good
                LocationManager.shared.requestAlwaysPermission()
            }else{
                self.changeToLocationViewController()
            }
            
        }else{
            print("ERROR")
        }
    }
    
    private func changeToLocationViewController(){
        print("switching to location view controller")

        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
        
    }
    
    private func changeToBluetoothOffViewController(){
        print("switching to bluetooth off controller")
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "BluetoothOffViewController") as! BluetoothOffViewController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
        
    }
    
    @objc private func handleLocationChangeStatus(notification: NSNotification){
        print("new location status notification", notification)
        if let status = notification.object as? LocationManager.AuthorizationStatus{
            if status != .allowedAlways{
                self.changeToLocationViewController()
            }else{
                self.bluetoothAccessible()
            }
        }else{
            print("WTF?")
        }
    }
    
    @objc private func handleBluetoothChangeStatus(notification: NSNotification){
        print("new blt status notification", notification)
        if let status = notification.object as? BluetoothManager.Status{
            if status != .on{
                self.changeToBluetoothOffViewController()
            }else{
                self.bluetoothAccessible()
            }
        }else{
            print("WTF?")
        }
    }
    
    @IBAction func showHowCanIHelpMore(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HelpMoreViewController") as! HelpMoreViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
}
