//
//  BluetoothManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 27/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import CoreBluetooth
import Foundation

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    enum PermissionStatus {
        case allowed, denied, notDetermined, notAvailable
    }
    
    enum Status{
        case on, off, unauthorized, resetting, notAvailable
    }
    
    static let shared = BluetoothManager()
    private var centralManager: CBCentralManager?
    
    private override init(){
        super.init()
        if self.getPrmissionStatus() == .allowed{
            self.centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }
    
    func getPrmissionStatus() -> PermissionStatus{
        if #available(iOS 13.1, *) {
            switch CBCentralManager.authorization {
            case .allowedAlways:
                return .allowed
            case .denied:
                return .denied
            case .restricted:
                return .notAvailable
            case .notDetermined:
                return .notDetermined
            }
        } else {
            //TODO Fallback on earlier versions
            return .notAvailable
        }
    }
    
    func askUserPermission(){
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOff:
                print("poweredOff")
                NotificationCenter.default.post(name: NSNotification.Name(Costants.Notification.bluetoothChangeStatus), object: Status.off)
                break
            case .poweredOn:
                print("poweredOn")
                NotificationCenter.default.post(name: NSNotification.Name(Costants.Notification.bluetoothChangeStatus), object: Status.on)
                break
            case .resetting:
                print("resetting")
                NotificationCenter.default.post(name: NSNotification.Name(Costants.Notification.bluetoothChangeStatus), object: Status.resetting)
                break
            case .unauthorized:
                print("unauthorized")
                NotificationCenter.default.post(name: NSNotification.Name(Costants.Notification.bluetoothChangeStatus), object: Status.unauthorized)
                break
            case .unknown:
                print("unknown")
                NotificationCenter.default.post(name: NSNotification.Name(Costants.Notification.bluetoothChangeStatus), object: Status.notAvailable)
                break
            case .unsupported:
                print("unsupported")
                NotificationCenter.default.post(name: NSNotification.Name(Costants.Notification.bluetoothChangeStatus), object: Status.notAvailable)
                break
        }
    }
    
    func scanForSids(){
        self.centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
            // RSSI value in dBm; 127 is not available
            print("BLUETOOTH NAME", peripheral.name, peripheral.identifier, RSSI)               
    //           centralManager?.connect(peripheral, options: nil)
    //           centralManager?.stopScan()
        }
    
}
