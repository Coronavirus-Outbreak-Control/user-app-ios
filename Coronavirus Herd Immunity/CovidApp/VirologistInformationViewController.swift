//
//  VirologistInformationViewController.swift
//  CovidApp - Covid Community Alert
//
//  Created by Antonio Romano on 06/04/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit

class VirologistInformationViewController : StatusBarViewController{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let data = PushNotificationData.readNotificationDate(){
//            if let title = data.title{
//                self.titleLabel.text = title
//            }
            
            if let message = data.message{
                self.shortDescriptionLabel.text = message
            }
            
            // TODO: handle language
            if var link = data.link{
                var otherLink : String? = nil
                if link.contains("{language}"){
                    if Locale.preferredLanguages.count > 0 {
                        link = link.replacingOccurrences(of: "", with: Locale.preferredLanguages[0])
                    }
                    if let localizedLanguage = data.language{
                        link = link.replacingOccurrences(of: "", with: localizedLanguage)
                    }
                }
                self.loadNotificatonData(data: data, link: link, otherLink: otherLink)
            }else{
                print("no link found")
                self.rollbackStatusNoLink()
            }
        }else{
            print("no notification found")
            self.rollbackStatusNoLink()
        }
    }
    
    private func loadNotificatonData(data: PushNotificationData, link: String, otherLink: String?){
        print("gonna load from", link)
        AlamofireManager.shared.downloadDataNotification(link, callback: {
            response, success in
            
            print("LOADED VIROLOGISTS INFORMATIONS")
            
            if success{
                
                self.spinner.isHidden = true
                
                if let res = response as? [String: Any]{
                    if let filters = res["filters"] as? [[String: Any]]{
                        if let filterId = data.filterId{
                            for filter in filters{
                                if let fid = filter["filter_id"] as? Int{
                                    if fid == filterId{
                                        if let language = filter["language"] as? String{
                                            if let content = filter["content"] as? [String: Any]{
                                                //TODO: search local language
                                                if let localizedContent = content[language] as? [String: Any]{
                                                    
                                                    if let short = localizedContent["shortDescription"] as? String{
                                                        self.shortDescriptionLabel.text = short
                                                    }
                                                    
                                                    if let long = localizedContent["description"] as? String{
                                                        self.contentLabel.text = long
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }else{
                        if let shortDescription = res["shortDescription"] as? String{
                            self.shortDescriptionLabel.text = shortDescription
                        }
                        
                        if let description = res["description"] as? String{
                            self.contentLabel.text = description
                        }
                    }
                }
            }else{
                print("NO DATA FOUND IN LINK", otherLink)
                if let otherL = otherLink{
                    self.loadNotificatonData(data: data, link: otherL, otherLink: nil)
                }else{
                    self.rollbackStatusNoLink()
                }
            }
        })
    }
    
    private func rollbackStatusNoLink(){
        print("rollback status")
        self.spinner.isHidden = true
        if let data = PushNotificationData.readNotificationDate(){
            if data.status != nil && data.status! == 1{
                //infected case
                self.shortDescriptionLabel.text = NSLocalizedString("Short description infected", comment: "Short description infected virologist panel")
                self.contentLabel.text = NSLocalizedString("Content description infected", comment: "Content description infected virologist panel")
            }else{
                self.shortDescriptionLabel.text = NSLocalizedString("Short description normal", comment: "Short description normal virologist panel")
                self.contentLabel.text = NSLocalizedString("Content description normal", comment: "Content description normal virologist panel")
            }
        }else{
            self.shortDescriptionLabel.text = NSLocalizedString("Short description normal", comment: "Short description normal virologist panel")
            self.contentLabel.text = NSLocalizedString("Content description normal", comment: "Content description normal virologist panel")
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
