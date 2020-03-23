//
//  AppDelegate.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 23/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit
import Sentry

//background fetch: https://www.hackingwithswift.com/example-code/system/how-to-run-code-when-your-app-is-terminated
// scrollview: https://fluffy.es/scrollview-storyboard-xcode-11/

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
//    var backgroundCompletionHandler: (()->Void)?

    private func registerListeners(){
        if BluetoothManager.shared.isBluetoothUsable() && LocationManager.shared.getPermessionStatus() == .allowedAlways{
            print("restarting ibeacon will resign")
            IBeaconManager.shared.registerListener()
            LocationManager.shared.startMonitoring()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.startup()
        
        do {
            Client.shared = try Client(dsn: "https://2d08d421fc5e40f1ba4a04ee468b5898@sentry.io/4506990")
            try Client.shared?.startCrashHandler()
        } catch let error {
            print("\(error)")
        }
        // Test send event sentry
        /*
        let event = Event(level: .debug)
        event.message = "Test event"
        Client.shared?.send(event: event)
        */
        
        self.registerListeners()
        
        return true
    }
    
    private func startup(){
        NotificationManager.shared.getStatus()
        if StorageManager.shared.getIdentifierDevice() == nil{
            print("generating new ID from server")
            ApiManager.shared.handshakeNewDevice(id: DeviceInfoManager.getId(), model: DeviceInfoManager.getModel(), version: DeviceInfoManager.getVersion()) { deviceID, token in
                    StorageManager.shared.setIdentifierDevice(Int(deviceID))
            }
            
        }else{
            print("MY ID:", StorageManager.shared.getIdentifierDevice())
            print("TOKN JWT:", StorageManager.shared.getTokenJWT())
            print("Token ID", StorageManager.shared.getPushId())
        }
        
        NotificationManager.shared.getAuthorizationStatus({
            status in
            if status == .allowed && StorageManager.shared.getPushId() == nil{
                NotificationManager.shared.requestPermission({
                    granted in
                    print("REGISTERING FROM APPDELEGATE")
                })
            }
            
        })
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
    }
    
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("background fetchs")
        BackgroundManager.backgroundOperations()
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("will finish launch with options")
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        self.registerListeners()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("did become active")
        NotificationManager.shared.getStatus()
        if BluetoothManager.shared.isBluetoothUsable() && LocationManager.shared.getPermessionStatus() == .allowedAlways{
            print("restarting ibeacon")
            IBeaconManager.shared.startAdvertiseDevice()
            IBeaconManager.shared.registerListener()
            LocationManager.shared.startMonitoring()
        }
        CoreManager.pushInteractions(isBackground: false)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // TODO:
        print("WILL TERMINATE")
        StorageManager.shared.saveContext()
        self.registerListeners()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("XXXXXXXXXXXXXXXXXX")
        // 1. Convert device token to string
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        // 2. Print device token to use for PNs payloads
        print("Device Token: \(token)")
        let bundleID = Bundle.main.bundleIdentifier;
        print("Bundle ID: \(token) \(bundleID)");
        if let idDevice = StorageManager.shared.getIdentifierDevice(){
            
            ApiManager.shared.handshakeNewDevice(id: DeviceInfoManager.getId(), model: DeviceInfoManager.getModel(), version: DeviceInfoManager.getVersion()) {
                deviceID, tokenJWT in

                ApiManager.shared.setPushNotificationId(deviceId: Int64(idDevice), notificationId: token, token: tokenJWT)
            }
            
        }
        StorageManager.shared.setPushId(token)
        // 3. Save the token to local storeage and post to app server to generate Push Notification. ...
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Received push notification: \(userInfo)")
        return
        //avoid updating status
        if let status = userInfo["status"] as? Int{
            StorageManager.shared.setStatusUser(status)
        }
        
        if let title = userInfo["status"] as? String{
            
            let subtitle = userInfo["subtitle"] as? String
            
            if let message = userInfo["message"] as? String{
                NotificationManager.shared.showLocalNotification(title, subtitle: subtitle, message: message)
            }
        }
    }
    
}

