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

// https://stackoverflow.com/questions/39977251/a-simple-code-to-detect-any-beacon-in-swift/46448986

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
//        self.locationManager.requestAlwaysAuthorization()
    }
    
    private func createBeaconRegion() -> CLBeaconRegion? {
        if let idDevice = StorageManager.shared.getIdentifierDevice(){
            
            let proximityUUID = UUID(uuidString: Constants.Setup.uuidCHIdevice)
            let major : CLBeaconMajorValue = CLBeaconMajorValue(Utils.getMajorFromInt(idDevice))
            let minor : CLBeaconMinorValue = CLBeaconMinorValue(Utils.getMinorFromInt(idDevice))
            let beaconID = Constants.Setup.beaconCHIidentifier
                
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

        if let region = createBeaconRegion(){
            print("started advertise")
            let peripheralData = region.peripheralData(withMeasuredPower: nil)
            self.peripheralManager!.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
        }else{
            print("COULDN'T create a region!")
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
    
    func registerListener() {
        if !BluetoothManager.shared.isBluetoothUsable(){
            print("bluetooth not usable!")
            return
        }
        print("registering region for iBeacon")
        let uuid = UUID(uuidString: Constants.Setup.uuidCHIdevice)!
        
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: Constants.Setup.beaconCHIidentifier)

        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("did enter region")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("did exit region")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
      print("Failed monitoring region: \(error.localizedDescription)")
    }
      
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("Location manager failed: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion){
        if beacons.count > 0{
            print("FOUND iBEACON!", beacons.count)
        }
        for beacon in beacons {
            print("BEACON", beacon.proximityUUID, beacon.accuracy, beacon.major, beacon.minor, beacon.accuracy, beacon.rssi)
            switch beacon.proximity {
            case .far:
                print("far")
                break
            case .immediate:
                print("immediate")
                break
            case .near:
                print("near")
                break
            case .unknown:
                print("unknown")
                break
            }
            if [CLProximity.immediate, CLProximity.near, CLProximity.far].contains(beacon.proximity){
                //TODO: good ibeacon :D
                CoreManager.addIBeacon(beacon)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    print("always authorized, starting region monitoring")
                    registerListener()
                }
            }
        }
    }
    
}
