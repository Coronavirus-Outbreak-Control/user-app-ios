//
//  NotificationManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 16/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit
import Foundation

// https://medium.com/flawless-app-stories/local-notifications-in-swift-5-and-ios-13-with-unusernotificationcenter-190e654a5615
// https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/pushing_background_updates_to_your_app
// https://medium.com/@dkw5877/local-notifications-in-ios-156a03b81ceb

class NotificationManager : NSObject, UNUserNotificationCenterDelegate{
    
    enum PermissionStatus {
        case allowed, denied, notDetermined
    }
    
    public static let shared = NotificationManager()
    
    private var status : PermissionStatus? = nil
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        self.getAuthorizationStatus({
            permissionStatus in
            
            self.status = permissionStatus
        })
    }
    
    private func isStatusChanged(_ newStatus : UNAuthorizationStatus) -> Bool{
        if let s = self.status{
            switch s {
            case PermissionStatus.allowed:
                return newStatus != .authorized
            case PermissionStatus.denied:
                return newStatus != .denied && newStatus != .provisional
            case PermissionStatus.notDetermined:
                return newStatus != .notDetermined
            }
        }else{
            return true
        }
        
    }
    
    public func getAuthorizationStatus(_ completion : ((PermissionStatus) -> Void)?){
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {
            settings in
            if self.isStatusChanged(settings.authorizationStatus){
                print("new notification status", self.status, settings.authorizationStatus.rawValue)
                NotificationCenter.default.post(name: NSNotification.Name(Constants.Notification.notificationChangeStatus), object: true)
            }else{
                print("same notification status")
            }
            print("asked notification")
//            DispatchQueue.main.sync {
                switch settings.authorizationStatus{
                case .authorized:
                    print("authorized")
                    self.status = .allowed
                    if let c = completion{
                        return c(PermissionStatus.allowed)
                    }
                    break
                case .denied:
                    print("denied")
                    self.status = .denied
                    if let c = completion{
                        return c(PermissionStatus.denied)
                    }
                    break
                case .notDetermined:
                    print("notDetermined")
                    self.status = .notDetermined
                    if let c = completion{
                        return c(PermissionStatus.notDetermined)
                    }
                    break
                case .provisional:
                    print("provisional")
                    self.status = .denied
                    if let c = completion{
                        return c(PermissionStatus.denied)
                    }
                    break
                }
//            }
        })
    }
    
    public func requestPermission(_ completion : @escaping (Bool) -> Void){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .alert]) { granted, error in
            NotificationCenter.default.post(name: NSNotification.Name(Constants.Notification.notificationChangeStatus), object: true)
            print("granted", granted)
            print("error", error)
            if granted == true && error == nil {
                self.status = .allowed
                print("GONNA REGISTER DEVICE FOR NOTIFICATION")
                DispatchQueue.main.sync {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                print("we have push notification permission!!!")
                // We have permission!
                return completion(true)
            }
            return completion(false)
        }
    }
    
    public func showLocalNotification(_ title : String, subtitle : String?, message : String){
        
        let content = UNMutableNotificationContent()
        content.title = title
        if let s = subtitle{
            content.subtitle = s
        }
        content.body = message
        content.sound = UNNotificationSound.default
        
        let center =  UNUserNotificationCenter.current()
        let request = UNNotificationRequest(identifier: "CoronavirusOutbreakControl", content: content, trigger: nil)

        //add request to notification center
        center.add(request) { (error) in
            if error != nil {
                print("error \(String(describing: error))")
            }
        }
    }
    
    public func getStatus() -> PermissionStatus?{
        print("AAA")
        self.getAuthorizationStatus(nil)
        return self.status
    }
}
