//
//  StatusBarViewController.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 14/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit
import Social
import MessageUI

class StatusBarViewController : UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate{
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            // Fallback on earlier versions
            return .default
//            return .lightContent
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        print("Result SMS", result.rawValue)
        controller.dismiss(animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print("Result Email", result.rawValue)
        controller.dismiss(animated: true, completion: nil)
    }
    
}
