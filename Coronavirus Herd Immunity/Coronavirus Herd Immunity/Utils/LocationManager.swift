//
//  LocationManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 02/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager : NSObject, CLLocationManagerDelegate{

    enum AuthorizationStatus {
        case allowedAlways, allowedWhenInUse, denied, notDetermined, notAvailable
    }
    
    public static var shared = LocationManager()
    let locationManager : CLLocationManager
    
    private override init(){
        self.locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        self.requestAlwaysPermission()
    }
    
    public func getPermessionStatus() -> AuthorizationStatus{
        print("asking for location authorization status")
        switch (CLLocationManager.authorizationStatus()){
            case .authorizedAlways:
                return .allowedAlways
            case .authorizedWhenInUse:
                return .allowedWhenInUse
            case .denied:
                return .denied
            case .notDetermined:
                return .denied
            case .restricted:
                return .notAvailable
            }
    }
    
    public func isServiceEnabledForApp() -> Bool{
        // if true and denied the location is disabled for app only
        return CLLocationManager.locationServicesEnabled()
    }
    
    public func requestAlwaysPermission(){
        print("requesting always permission auth")
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location suthorizaion changed")
        switch status {
        case .authorizedAlways:
            NotificationCenter.default.post(name: NSNotification.Name(Costants.Notification.locationChangeStatus), object: AuthorizationStatus.allowedAlways)
            break
        case .authorizedWhenInUse:
            print("authorized in use :O")
            NotificationCenter.default.post(name: NSNotification.Name(Costants.Notification.locationChangeStatus), object: AuthorizationStatus.allowedWhenInUse)
            break
        case .denied:
            NotificationCenter.default.post(name: NSNotification.Name(Costants.Notification.locationChangeStatus), object: AuthorizationStatus.denied)
            break
        case .notDetermined, .restricted:
            NotificationCenter.default.post(name: NSNotification.Name(Costants.Notification.locationChangeStatus), object: AuthorizationStatus.notDetermined)
            break
        }
    }
    
}
