//
//  LocationViewController.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 02/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit

class ShareLocationViewController : ViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("LOCATION SHARE CONTROLLER")
        StorageManager.shared.setShareLocation(false)
    }
    
    @IBAction func shareLocation(_ sender: Any) {
        StorageManager.shared.setShareLocation(true)
        self.goNext()
    }
    
    @IBAction func skipStep(_ sender: Any) {
        self.goNext()
    }
    
    private func goNext(){
        self.dismiss(animated: true, completion: nil)
        if StorageManager.shared.isFirstAccess(){
            print("gonna open notification view")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "NotificationViewController")
            UIApplication.shared.windows.first?.rootViewController = controller
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }else{
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
    
}
