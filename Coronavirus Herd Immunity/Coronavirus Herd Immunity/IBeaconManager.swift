//
//  IBeaconManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 01/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth

// https://developer.apple.com/documentation/corelocation/turning_an_ios_device_into_an_ibeacon_device
// https://www.hackingwithswift.com/example-code/location/how-to-detect-ibeacons
// https://www.raywenderlich.com/632-ibeacon-tutorial-with-ios-and-swift

class IBeaconManager: NSObject, CBPeripheralManagerDelegate, CLLocationManagerDelegate{
    
    public static let shared = IBeaconManager()
    var peripheralManager : CBPeripheralManager?
    var shouldAdvertise : Bool
    var locationManager: CLLocationManager
    
    private override init(){
        self.shouldAdvertise = false
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        self.locationManager.requestAlwaysAuthorization()
    }
    
    private func createBeaconRegion() -> CLBeaconRegion? {
        if let identifierDevice = StorageManager.shared.getIdentifierDevice(){
            let proximityUUID = UUID(uuidString: identifierDevice)
            print("proximity UUID", proximityUUID)
            let major : CLBeaconMajorValue = 100
            let minor : CLBeaconMinorValue = 1
            let beaconID = "com.coronaherdimmunity.myDeviceRegion"
                
            return CLBeaconRegion(proximityUUID: proximityUUID!, major: major, minor: minor, identifier: beaconID)
        }
        return nil
    }
    
    public func startAdvertiseDevice(){
        print("asked to advertise")
        self.shouldAdvertise = true
        self.advertiseDevice()
    }
    
    private func advertiseDevice() {
        print("gonna advertise")
        if !self.shouldAdvertise || self.peripheralManager!.state != .poweredOn{
            print("should not advertise")
            return
        }
        
        
        if self.peripheralManager!.isAdvertising{
            print("device is already advertising")
            return
        }

        let r = createBeaconRegion()
        if let region = r{
            print("started advertise")
            let peripheralData = region.peripheralData(withMeasuredPower: nil)
            self.peripheralManager!.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
        }else{
            print("no region provided")
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("did update status", peripheral.state)
        switch peripheral.state {
        case .poweredOff:
            print("off")
            break
        case .poweredOn:
            print("on")
            self.advertiseDevice()
            break
        case .resetting:
            print("resetting")
            break
        case .unauthorized:
            print("unauth")
            break
        case .unknown:
            print("unknown")
            break
        case .unsupported:
            print("unsupported")
            break
        }
    }
    
    func startScanning() {
        
        if let identifierDevice = StorageManager.shared.getIdentifierDevice(){
            let uuid = UUID(uuidString: identifierDevice)!
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 100, minor: 1, identifier: "com.coronaherdimmunity.myDeviceRegion")

            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startRangingBeacons(in: beaconRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
}
