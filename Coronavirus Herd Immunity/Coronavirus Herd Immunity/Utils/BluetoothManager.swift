//
//  BluetoothManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 27/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import CoreBluetooth
import Foundation

// https://developer.apple.com/documentation/corelocation/turning_an_ios_device_into_an_ibeacon_device
class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    enum PermissionStatus {
        case allowed, denied, notDetermined, notAvailable
    }
    
    enum Status{
        case on, off, unauthorized, resetting, notAvailable
    }
    
    static let shared = BluetoothManager()
    private var centralManager: CBCentralManager?
    private var peripherals : [PeripheralDto]
    private var timeBlock : String?
    
    private override init(){
        self.peripherals = [PeripheralDto]()
        self.timeBlock = nil
        
        super.init()
        
        if self.getPermissionStatus() == .allowed{
            self.centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }
    
    func getPermissionStatus() -> PermissionStatus{
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
    
    func getItendifier() -> String?{
        if let manager = self.centralManager{
            
        }
        return nil
    }
    
    func askUserPermission(){
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func getBluetoothStatus() -> Status{
        if let manager = self.centralManager{
            switch(manager.state){
            case .poweredOff:
                return .off
            case .poweredOn:
                return .on
            case .resetting:
                return .resetting
            case .unauthorized:
                return .unauthorized
            default:
                return .notAvailable
            }
        }
        return .notAvailable
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("update bluetooth status")
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
        self.centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
        
        self.peripherals = [PeripheralDto]()
        self.timeBlock = Utils.getTimeBlock(Date())
        
        if let lastBlock = StorageManager.shared.getTimeBlockUserDefatuls(){
            if self.timeBlock != lastBlock{
                // TODO lastBlock need to be pushed to server!!!
            }else{
                StorageManager.shared.setTimeBlockUserDefatuls(self.timeBlock!)
            }
        }
        
        if let ps = StorageManager.shared.readPeripheralsByTimeBlock(self.timeBlock!){
            self.peripherals = ps
        }
        
        let _ = Timer.scheduledTimer(withTimeInterval: Costants.Setup.scanTime, repeats: false, block: { timer in
            print("stop scanning peripherals")
            self.timeBlock = nil
            self.peripherals = [PeripheralDto]()
            self.centralManager?.stopScan()
        })
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if self.timeBlock == nil{
            print("ERROR! no time block provided")
            return
        }
        // RSSI value in dBm; 127 is not available
        print("BLUETOOTH NAME", peripheral.name ?? "<NO-NAME>", peripheral.identifier, RSSI)

        if Costants.Setup.minRSSIPower <= RSSI.doubleValue && RSSI.doubleValue <= Costants.Setup.maxRSSIPower{
            
            if let found = self.peripherals.first(where: {$0.identifier == peripheral.identifier.uuidString}) {
               // do something with foo
                found.counter += 1
                found.rssi = min(found.rssi, RSSI.doubleValue)
                StorageManager.shared.savePeripheral(peripheralInput: found)
            } else {
               // item could not be found
                let p = PeripheralDto(
                    identifier: peripheral.identifier.uuidString,
                    rssi: RSSI.doubleValue,
                    timestamp: Date(),
                    timeBlock: self.timeBlock!,
                    counter: 1)
                StorageManager.shared.savePeripheral(peripheralInput: p)
            }
        }
    
    }
    
}
