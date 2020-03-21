//
//  LocationManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 02/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation
import CoreLocation

// https://www.raywenderlich.com/5247-core-location-tutorial-for-ios-tracking-visited-locations

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
                return .notDetermined
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
    
    public func startMonitoring(){
        LocationManager.shared.locationManager.allowsBackgroundLocationUpdates = true
        LocationManager.shared.locationManager.startMonitoringSignificantLocationChanges()
        LocationManager.shared.locationManager.startMonitoringVisits()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location suthorizaion changed")
        switch status {
        case .authorizedAlways:
            self.startMonitoring()
            NotificationCenter.default.post(name: NSNotification.Name(Constants.Notification.locationChangeStatus), object: AuthorizationStatus.allowedAlways)
            break
        case .authorizedWhenInUse:
            print("authorized in use :O")
            NotificationCenter.default.post(name: NSNotification.Name(Constants.Notification.locationChangeStatus), object: AuthorizationStatus.allowedWhenInUse)
            break
        case .denied:
            NotificationCenter.default.post(name: NSNotification.Name(Constants.Notification.locationChangeStatus), object: AuthorizationStatus.denied)
            break
        case .notDetermined, .restricted:
            NotificationCenter.default.post(name: NSNotification.Name(Constants.Notification.locationChangeStatus), object: AuthorizationStatus.notDetermined)
            break
        }
    }
    
    public func getLocationAndUpdate() -> CLLocation?{
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.requestLocation()
        return self.locationManager.location
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
      // create CLLocation from the coordinates of CLVisit
        BackgroundManager.backgroundOperations()
        print("new visit received")
        IBeaconManager.shared.registerListener()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        BackgroundManager.backgroundOperations()
        print("new location received")
        IBeaconManager.shared.registerListener()
    }
    
}
