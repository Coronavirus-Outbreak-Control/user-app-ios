//
//  AppDelegate.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 23/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit
import Sentry
import BackgroundTasks

// background fetch: https://www.hackingwithswift.com/example-code/system/how-to-run-code-when-your-app-is-terminated
// https://medium.com/snowdog-labs/managing-background-tasks-with-new-task-scheduler-in-ios-13-aaabdac0d95b
// scrollview: https://fluffy.es/scrollview-storyboard-xcode-11/

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private func registerListeners(){
        BackgroundManager.backgroundOperations()
        if BluetoothManager.shared.isBluetoothUsable() && LocationManager.shared.getPermessionStatus() == .allowedAlways{
            print("restarting ibeacon will resign")
            IBeaconManager.shared.registerListener()
            LocationManager.shared.startMonitoring()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.startup()
        
        // MARK: Registering Launch Handlers for Tasks
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Constants.Setup.backgroundPushIdentifier,
            using: DispatchQueue.global()) {
                task in
                // Downcast the parameter to an app refresh task as this identifier is used for a refresh request.
                print("HANDLE PUSH scheduled called")
                self.handlePushInteractions(task)
            }
        } else {
            // Fallback on earlier versions
        }
        
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
    
    @available(iOS 13.0, *)
    func schedulePushInteractions() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
        let request = BGAppRefreshTaskRequest(identifier: Constants.Setup.backgroundPushIdentifier)
        // Push again no earlier than 15 minutes from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 10 * 60)
        do {
           try BGTaskScheduler.shared.submit(request)
            print("Push scheduled!")
        } catch {
           print("Could not schedule push: \(error)")
        }
    }
    
    @available(iOS 13.0, *)
    func handlePushInteractions(_ task: BGTask) {
        print("Processing scheduled push!")
        // Schedule a new refresh task
        
        BackgroundManager.backgroundOperations()
        task.expirationHandler = {}
        
        let _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) {
            timer in
            print("Timer fired!")
            task.setTaskCompleted(success: true)
            self.schedulePushInteractions()
        }
        
        self.schedulePushInteractions()
    }
    
    private func startup(){
        
        NotificationManager.shared.getStatus()
        if StorageManager.shared.getIdentifierDevice() == nil{
            print("Device not yet registered")
        }else{
            print("MY ID:", StorageManager.shared.getIdentifierDevice())
            print("TOKN JWT:", StorageManager.shared.getTokenJWT())
            print("Token ID", StorageManager.shared.getPushId())
        }
        
        NotificationManager.shared.getAuthorizationStatus({
            status in
            if status == .allowed{
                DispatchQueue.main.async{
                    print("FORCE REGISTER PUSH")
                    UIApplication.shared.registerForRemoteNotifications()
                }
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
        BackgroundManager.backgroundOperations()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        self.registerListeners()
        BackgroundManager.backgroundOperations()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        BackgroundManager.backgroundOperations()
        if #available(iOS 13.0, *) {
            self.schedulePushInteractions()
        } else {
            // Fallback on earlier versions
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("did become active")
        NotificationManager.shared.getStatus()
        BackgroundManager.backgroundOperations()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // TODO:
        print("WILL TERMINATE")
        BackgroundManager.backgroundOperations()
        StorageManager.shared.saveContext()
        self.registerListeners()
    }
    
    private func updatePushId(token : String){
        if let idDevice = StorageManager.shared.getIdentifierDevice(){
            ApiManager.shared.handshakeNewDevice(googleToken: nil) {
                deviceID, tokenJWT, error in
                if let jwt = tokenJWT{
                    ApiManager.shared.setPushNotificationId(deviceId: Int64(idDevice), notificationId: token, token: jwt)
                }
            }
        }
        StorageManager.shared.setPushId(token)
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
        if let oldPushId = StorageManager.shared.getPushId(){
            if oldPushId != token{
                updatePushId(token: token)
            }
        }else{
            updatePushId(token: token)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("REMOTE NOTIFICATION - normal")
        self.handleRemoteContent(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        BackgroundManager.backgroundOperations()
        print("REMOTE NOTIFICATION - fetch")
        self.handleRemoteContent(userInfo)
        completionHandler(.newData)
    }
    
    private func handleRemoteContent(_ userInfo: [AnyHashable : Any]){
        registerListeners()
        
        print("Received push notification: \(userInfo)")
        
        if let d = userInfo["data"] as? [String: Any]{
            print("DATA FOUND", d)
            //avoid updating status
            
            PushNotificationData.saveNotificationData(d)
            
            if let status = d["status"] as? Int{
                StorageManager.shared.setStatusUser(status)
            }
            
            if let warningLevel = d["warning_level"] as? Int{
                StorageManager.shared.setWarningLevel(warningLevel)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(Constants.Notification.patientChangeStatus), object: nil)
            
            if let title = d["title"] as? String{
                print("title", title)
                let subtitle = d["subtitle"] as? String
                if let message = d["message"] as? String{
                    print("message", message)
                    NotificationManager.shared.showLocalNotification(title, subtitle: subtitle, message: message)
                }
            }
        }
    }
    
}

