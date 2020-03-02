//
//  LocationManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 02/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation
import CoreLocation



//        var locationManager = CLLocationManager()
////        locationManager.requestAlwaysAuthorization()
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()

class LocationManager : NSObject, CLLocationManagerDelegate{

    enum PermissionStatus {
        case allowed, denied, notDetermined, notAvailable
    }
    
    public var shared = LocationManager()
    let locationManager : CLLocationManager
    
    private override init(){
        self.locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
    }
    
    public func getPermessionStatus() -> PermissionStatus{
        switch (CLLocationManager.authorizationStatus()){
            case .authorizedAlways, .authorizedWhenInUse:
                return .allowed
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
        self.locationManager.requestWhenInUseAuthorization()
    }
    
}
