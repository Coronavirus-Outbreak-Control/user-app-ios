//
//  StorageManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 29/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation
import CoreData

// https://www.raywenderlich.com/7569-getting-started-with-core-data-tutorial
// https://developer.apple.com/documentation/coredata/using_core_data_in_the_background
// https://nshipster.com/nspredicate/
class StorageManager{
    
    private class PeripheralEntity{
        static let entityName = "Peripheral"
        static let identifierKey = "identifier"
        static let rssiKey = "rssi"
        static let timestampKey = "timestamp"
        static let dayKey = "day"
    }
    
    private class InteractionsEntity{
        static let entityName = "Interactions"
        static let keyKey = "key"
        static let countKey = "count"
    }
    
    public var shared : StorageManager = StorageManager()
    private var managedContext : NSManagedObjectContext
    
    private init(){
        self.managedContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    }
    
    private func buildPeripheral(_ object : NSManagedObject) -> PeripheralDto{
        return PeripheralDto(
            identifier: object.value(forKey: PeripheralEntity.identifierKey) as! String,
            rssi: object.value(forKey: PeripheralEntity.rssiKey) as! Float,
            timestamp: object.value(forKey: PeripheralEntity.timestampKey) as! Date,
            day: object.value(forKey: PeripheralEntity.dayKey) as! String)
    }
    
    private func buildInteraction(_ object : NSManagedObject) -> InteractionsDto{
        return InteractionsDto(
            key: object.value(forKey: InteractionsEntity.keyKey) as! String,
            count: object.value(forKey: InteractionsEntity.countKey) as! Int64
        )
    }
    
    public func savePeripheral(peripheralInput : PeripheralDto){

        let entity = NSEntityDescription.entity(forEntityName: PeripheralEntity.entityName, in: managedContext)!
        let peripheral = NSManagedObject(entity: entity, insertInto: managedContext)
        
        peripheral.setValue(peripheralInput.identifier, forKeyPath: PeripheralEntity.identifierKey)
        peripheral.setValue(peripheralInput.rssi, forKeyPath: PeripheralEntity.rssiKey)
        peripheral.setValue(peripheralInput.timestamp, forKeyPath: PeripheralEntity.timestampKey)
        peripheral.setValue(peripheralInput.day, forKeyPath: PeripheralEntity.dayKey)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    public func savePeripheral(interactionInput : InteractionsDto){

        let entity = NSEntityDescription.entity(forEntityName: InteractionsEntity.entityName, in: managedContext)!
        let interaction = NSManagedObject(entity: entity, insertInto: managedContext)
        
        interaction.setValue(interactionInput.key, forKeyPath: InteractionsEntity.keyKey)
        interaction.setValue(interactionInput.count, forKeyPath: InteractionsEntity.countKey)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private func fetchPeripherals(_ predicate : NSPredicate? = nil) -> [PeripheralDto]?{
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: PeripheralEntity.entityName)
        if let p = predicate{
            fetchRequest.predicate = p
        }
        
        do {
            let fetchRes : [NSManagedObject] = try managedContext.fetch(fetchRequest)
            var peripherals = [PeripheralDto]()
            for managedObj in fetchRes {
                peripherals.append(self.buildPeripheral(managedObj))
            }
            return peripherals.count > 0 ? peripherals : nil
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    private func fetchInteractions(_ predicate : NSPredicate? = nil) -> [InteractionsDto]?{
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: InteractionsEntity.entityName)
        if let p = predicate{
            fetchRequest.predicate = p
        }
        
        do {
            let fetchRes : [NSManagedObject] = try managedContext.fetch(fetchRequest)
            var interactions = [InteractionsDto]()
            for managedObj in fetchRes {
                interactions.append(self.buildInteraction(managedObj))
            }
            return interactions.count > 0 ? interactions : nil
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    public func getAllPeripherals() -> [PeripheralDto]?{
        return fetchPeripherals()
    }
    
    public func readByIdentifiersAndDay(_ identifier : String, day : String) -> [PeripheralDto]?{
        let predicate = NSPredicate(format: "(%K = %@) and (day = %@)", PeripheralEntity.identifierKey, identifier, day)
        return fetchPeripherals(predicate)
    }
    
    public func getInteractions(_ key : String) -> [InteractionsDto]?{
        let predicate = NSPredicate(format: "(%K = %@)", InteractionsEntity.keyKey, key)
        return fetchInteractions(predicate)
    }
    
}
