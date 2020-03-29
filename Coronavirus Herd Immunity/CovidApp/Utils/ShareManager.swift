//
//  ShareManager.swift
//  CovidApp - Covid Community Alert
//
//  Created by Antonio Romano on 29/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit
import MessageUI
import Foundation

class ShareManager{
    
    public static func showToast(message : String, viewController : UIViewController) {

        let toastLabel = UILabel(frame: CGRect(x: viewController.view.frame.size.width/2 - 75, y: viewController.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        viewController.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 2, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    public static func copyLink(_ viewController : UIViewController){
        UIPasteboard.general.string = NSLocalizedString("Website URL", comment: "website url")
        ShareManager.showToast(message: NSLocalizedString("Link copied", comment: "Link copied"), viewController: viewController)
    }
    
    public static func shareSMS(_ viewController: StatusBarViewController){
        let bodySMS = NSLocalizedString("Body SMS", comment: "Body SMS")

        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = viewController
        
        composeVC.body = bodySMS
        
        if MFMessageComposeViewController.canSendText() {
            viewController.present(composeVC, animated: true, completion: nil)
        } else {
            ShareManager.showToast(message: NSLocalizedString("SMS not enabled", comment: "SMS not enabled"), viewController: viewController)
        }
    }
    
    public static func shareEmail(_ viewController : StatusBarViewController){
        if MFMailComposeViewController.canSendMail() {
            let bodyEmail = NSLocalizedString("Body Email", comment: "Body Email")
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = viewController
            mail.setMessageBody(bodyEmail, isHTML: true)

            viewController.present(mail, animated: true)
        } else {
            ShareManager.showToast(message: NSLocalizedString("Email not enabled", comment: "Email not enabled"), viewController: viewController)
        }
    }
    
    public static func shareFacebook(_ viewController : StatusBarViewController){
        let items : [Any] = [NSLocalizedString("Share Text Social", comment: "Share Text Social"), URL(string: NSLocalizedString("Website URL", comment: "website"))!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        viewController.present(ac, animated: true)
        
    }
    
    public static func shareTwitter(_ viewController : StatusBarViewController){
        let items : [Any] = [NSLocalizedString("Share Text Social", comment: "Share Text Social"), URL(string: NSLocalizedString("Website URL", comment: "website url"))!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        viewController.present(ac, animated: true)
    }
    
    public static func shareWhatsapp(_ viewController : StatusBarViewController){
        let items : [Any] = [NSLocalizedString("Share Text Social", comment: "website"), URL(string: NSLocalizedString("Website URL", comment: "website url"))!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        viewController.present(ac, animated: true)
    }
    
}
