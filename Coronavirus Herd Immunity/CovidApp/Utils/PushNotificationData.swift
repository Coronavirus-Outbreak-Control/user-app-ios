//
//  PushNotificationData.swift
//  CovidApp - Covid Community Alert
//
//  Created by Antonio Romano on 06/04/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation
class PushNotificationData{
    
    private(set) var title : String?
    private(set) var message : String?
    private(set) var filterId : Int?
    private(set) var link : String?
    private(set) var language : String?
    private(set) var contentLanguage : String?
    private(set) var status : Int?
    private(set) var warningLevel : Int?
    
    private init(){
        
    }
    
    public static func saveNotificationData(_ value : Any){
        StorageManager.shared.setNotificationData(value)
    }
    
    public static func readNotificationDate() -> PushNotificationData?{
        
        var p : PushNotificationData? = nil
        
        if let v = StorageManager.shared.getNotificationData(){
            print("PUSH FOUND", v)
            if let data = v as? [String: AnyObject]{
                p = PushNotificationData()
                
                if let fid = data["filter_id"] as? Int{
                    p!.filterId = fid
                }
                
                if let status = data["status"] as? Int{
                    p!.status = status
                }
                
                if let warning = data["warning_level"] as? Int{
                    p!.warningLevel = warning
                }
                
                if let title = data["title"] as? String{
                    p!.title = title
                }
                
                if let message = data["message"] as? String{
                    p!.message = message
                }
                
                if let link = data["link"] as? String{
                    p!.link = link
                }
                
                if let language = data["language"] as? String{
                    p!.language = language
                }
                
                if let content = data["content"] as? [String: AnyObject]{
                    if let contentLanguage = content["language"] as? String{
                        p!.contentLanguage = contentLanguage
                    }
                }
            }
        }
        print("TITLE", p?.title, p?.contentLanguage)
        return p
    }
    
}
