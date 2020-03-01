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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("MAIN LOADED")
        self.run()
    }
    
    private func run(){
//        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.interactionsDaily.text = StorageManager.shared.countDailyInteractions().description
        self.interactionsTotal.text = StorageManager.shared.countTotalInteractions().description
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBluetoothChangeStatus), name: NSNotification.Name(Costants.Notification.bluetoothChangeStatus), object: nil)
        
        if BluetoothManager.shared.getPermissionStatus() != .allowed{
            self.changeToBluetoothOffViewController()
        }
    }
    
    private func changeToBluetoothOffViewController(){
        print("switching to bluetooth off controller")
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "BluetoothOffViewController")
//        UIApplication.shared.windows.first?.rootViewController = controller
//        UIApplication.shared.windows.first?.makeKeyAndVisible()
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "BluetoothOffViewController") as! BluetoothOffViewController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
        
    }
    
    @objc private func handleBluetoothChangeStatus(notification: NSNotification){
        print("new blt status notification", notification)
        if let status = notification.object as? BluetoothManager.Status{
            switch status {
            case .notAvailable, .unauthorized:
                self.changeToBluetoothOffViewController()
                break
            default:
                print("new blt status", status)
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
