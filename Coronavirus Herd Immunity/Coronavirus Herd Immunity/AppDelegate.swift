//
//  AppDelegate.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 23/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit

//background fetch: https://www.hackingwithswift.com/example-code/system/how-to-run-code-when-your-app-is-terminated
// scrollview: https://fluffy.es/scrollview-storyboard-xcode-11/

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
//    var backgroundCompletionHandler: (()->Void)?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.startup()
        
        return true
    }
    
    private func startup(){
        if StorageManager.shared.getIdentifierDevice() == nil{
            print("generating new ID from server")
            ApiManager.shared.getNewDeviceId(id: DeviceInfoManager.getId(), model: DeviceInfoManager.getModel(), version: DeviceInfoManager.getVersion()) { deviceID in
                    StorageManager.shared.setIdentifierDevice(Int(deviceID))
            }
//            StorageManager.shared.setIdentifierDevice(Utils.randomInt())
        }
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
    }
    
//    func application(_ application: UIApplication,
//                     handleEventsForBackgroundURLSession identifier: String,
//                     completionHandler: @escaping () -> Void) {
//        backgroundCompletionHandler = completionHandler
//    }
//
//    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
//        DispatchQueue.main.async {
//            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
//                let backgroundCompletionHandler =
//                appDelegate.backgroundCompletionHandler else {
//                    return
//            }
//            backgroundCompletionHandler()
//        }
//    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("background fetchs")
        BackgroundManager.backroundOperations()
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("will finish launch with options")
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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
        if BluetoothManager.shared.isBluetoothUsable() && LocationManager.shared.getPermessionStatus() == .allowedAlways{
            print("restarting ibeacon")
            IBeaconManager.shared.startAdvertiseDevice()
            IBeaconManager.shared.registerListener()
            LocationManager.shared.startMonitoring()
        }
        CoreManager.pushInteractions()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // TODO:
        StorageManager.shared.saveContext()
    }
}

