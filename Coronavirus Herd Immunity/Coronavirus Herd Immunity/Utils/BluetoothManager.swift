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
    private var peripherals : [PeripheralDto]
    private var timeBlock : String?
    private var interactionsDaily : InteractionsDto?
    private var interactionsTotal : InteractionsDto?
    
    private override init(){
        self.peripherals = [PeripheralDto]()
        self.timeBlock = nil
        
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
        
        self.peripherals = [PeripheralDto]()
        self.timeBlock = Utils.getTimeBlock(Date())
        
        if let daily = StorageManager.shared.readInteractions(self.timeBlock!){
            self.interactionsDaily = daily
        }else{
            self.interactionsDaily = InteractionsDto(key: self.timeBlock!, count: 0)
        }
        if let total = StorageManager.shared.readInteractions(Costants.Setup.totalInteractionsKey){
            self.interactionsTotal = total
        }else{
            self.interactionsTotal = InteractionsDto(key: Costants.Setup.totalInteractionsKey, count: 0)
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
    
    private func incrementInteractions(){
        self.interactionsDaily!.count += 1
        self.interactionsTotal!.count += 1
        StorageManager.shared.saveInteractions(interactionInput: self.interactionsDaily!)
        StorageManager.shared.saveInteractions(interactionInput: self.interactionsTotal!)
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
            self.incrementInteractions()
        }
    
    }
    
}
