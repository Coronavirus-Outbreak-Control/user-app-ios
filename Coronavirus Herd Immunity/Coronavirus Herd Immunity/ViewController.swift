//
//  ViewController.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 23/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("loaded view")
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
//        self.navigationController?.pushViewController(nextViewController, animated: true)
//        self.present(nextViewController, animated:true, completion:nil)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0, repeats: false, block: { timer in
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "MainViewController")
            UIApplication.shared.windows.first?.rootViewController = controller
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            
        })
        
        
        
    }


}

