//
//  HelpMoreViewController.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 26/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit

class HelpMoreViewController: StatusBarViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("HELP MORE VIEW CONTROLLER")
    }
    @IBAction func backToDashboard(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
