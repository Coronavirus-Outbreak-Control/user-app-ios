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
    }
    
    @IBAction func showInfoInteractionsDaily(_ sender: Any) {
    }
    
    @IBAction func showHowCanIHelpMore(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HelpMoreViewController") as! HelpMoreViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    @IBAction func showAccount(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "AccountViewController") as! AccountViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    /* BLUETOOTH */
    
}
