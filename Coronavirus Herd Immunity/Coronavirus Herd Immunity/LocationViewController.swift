//
//  LocationViewController.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 02/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit

class LocationViewController : ViewController{
    
    @IBOutlet weak var locationStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("LOCATION VIEW CONTROLLER")
        self.run()
    }
    
    func openMainViewController(){
        print("dismissing view")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func helpMoreAction(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HelpMoreViewController") as! HelpMoreViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    @IBAction func enableLocationAction(_ sender: Any) {
    }
    
    private func run(){
        
    }
    
}
