//
//  StorageManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 29/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation
import CoreData

// https://medium.com/@maddy.lucky4u/swift-4-core-data-part-3-creating-a-singleton-core-data-refactoring-insert-update-delete-9811af2fcf75

// https://www.raywenderlich.com/7569-getting-started-with-core-data-tutorial
// https://developer.apple.com/documentation/coredata/using_core_data_in_the_background
// https://nshipster.com/nspredicate/
// https://www.hackingwithswift.com/example-code/system/how-to-save-user-settings-using-userdefaults
class StorageManager{
    
    private class PeripheralEntity{
        static let entityName = "Peripheral"
        static let identifierKey = "identifier"
        static let rssiKey = "rssi"
        static let timestampKey = "timestamp"
        static let timeBlockKey = "timeBlock"
        static let counterKey = "counter"
    }
    
    private class InteractionsEntity{
        static let entityName = "Interactions"
        static let keyKey = "key"
        static let countKey = "count"
    }
    
    public static var shared : StorageManager = StorageManager()
    private let defaults = UserDefaults.standard
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Models")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
      return container
    }()
    
    func saveContext () {
        print("SAVING CONTEXT")
        let context = StorageManager.shared.persistentContainer.viewContext
        if context.hasChanges {
            print("HAS CHANGES")
            do {
                try context.save()
            } catch {
          // Replace this implementation with code to handle the error appropriately.
          // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private init(){
    }
    
    private func buildPeripheral(_ object : NSManagedObject) -> PeripheralDto{
        return PeripheralDto(
            identifier: object.value(forKey: PeripheralEntity.identifierKey) as! String,
            rssi: object.value(forKey: PeripheralEntity.rssiKey) as! Double,
            timestamp: object.value(forKey: PeripheralEntity.timestampKey) as! Date,
            timeBlock: object.value(forKey: PeripheralEntity.timeBlockKey) as! String,
            counter: object.value(forKey: PeripheralEntity.counterKey) as! Int64
        )
    }
    
    private func buildInteraction(_ object : NSManagedObject) -> InteractionsDto{
        return InteractionsDto(
            key: object.value(forKey: InteractionsEntity.keyKey) as! String,
            count: object.value(forKey: InteractionsEntity.countKey) as! Int64
        )
    }
    
    public func savePeripheral(peripheralInput : PeripheralDto){

        let entity = NSEntityDescription.entity(forEntityName: PeripheralEntity.entityName, in: self.persistentContainer.viewContext)!
        let peripheral = NSManagedObject(entity: entity, insertInto: self.persistentContainer.viewContext)
        
        peripheral.setValue(peripheralInput.identifier, forKeyPath: PeripheralEntity.identifierKey)
        peripheral.setValue(peripheralInput.rssi, forKeyPath: PeripheralEntity.rssiKey)
        peripheral.setValue(peripheralInput.timestamp, forKeyPath: PeripheralEntity.timestampKey)
        peripheral.setValue(peripheralInput.timeBlock, forKeyPath: PeripheralEntity.timeBlockKey)
        peripheral.setValue(peripheralInput.counter, forKeyPath: PeripheralEntity.counterKey)
        
        do {
            try self.persistentContainer.viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    public func saveInteractions(interactionInput : InteractionsDto){

        let entity = NSEntityDescription.entity(forEntityName: InteractionsEntity.entityName, in: self.persistentContainer.viewContext)!
        let interaction = NSManagedObject(entity: entity, insertInto: self.persistentContainer.viewContext)
        
        interaction.setValue(interactionInput.key, forKeyPath: InteractionsEntity.keyKey)
        interaction.setValue(interactionInput.count, forKeyPath: InteractionsEntity.countKey)
        
        do {
            try self.persistentContainer.viewContext.save()
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
            let fetchRes : [NSManagedObject] = try self.persistentContainer.viewContext.fetch(fetchRequest)
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
            let fetchRes : [NSManagedObject] = try self.persistentContainer.viewContext.fetch(fetchRequest)
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
    
    private func countInteractions(_ predicate : NSPredicate? = nil, distinctKey : String? = nil) -> Int?{
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: PeripheralEntity.entityName)
        
        if let p = predicate{
            fetchRequest.predicate = p
        }
        
        if let distinctKey = distinctKey{
            fetchRequest.returnsDistinctResults = true
            fetchRequest.propertiesToFetch = [distinctKey]
        }
        
        do {
            return try self.persistentContainer.viewContext.count(for: fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    public func readAllPeripherals() -> [PeripheralDto]?{
        return fetchPeripherals()
    }
    
    public func readPeripheralsByIdentifiersAndTimeBlock(_ identifier : String, timeBlock : String) -> [PeripheralDto]?{
        let predicate = NSPredicate(format: "(%K = %@) and (day = %@)", PeripheralEntity.identifierKey, identifier, timeBlock)
        return fetchPeripherals(predicate)
    }
    
    public func readPeripheralsByTimeBlock(_ timeBlock : String) -> [PeripheralDto]?{
        let predicate = NSPredicate(format: "(%K = %@)", PeripheralEntity.identifierKey, timeBlock)
        return fetchPeripherals(predicate)
    }
    
    public func readInteractions(_ key : String) -> InteractionsDto?{
        let predicate = NSPredicate(format: "(%K = %@)", InteractionsEntity.keyKey, key)
        if let res = fetchInteractions(predicate){
            return res[0]
        }
        return nil
    }
    
    public func getTimeBlockUserDefatuls() -> String?{
        return defaults.string(forKey: Costants.Setup.timeBlockKeyPreference)
    }
    
    public func setTimeBlockUserDefatuls(_ timeBlock : String){
        defaults.set(timeBlock, forKey: Costants.Setup.timeBlockKeyPreference)
        defaults.synchronize()
    }
    
    public func getIdentifierDevice() -> String?{
        return defaults.string(forKey: Costants.Setup.identifierDevice)
    }
    
    public func setIdentifierDevice(_ identifierDevice : String){
        defaults.set(identifierDevice, forKey: Costants.Setup.identifierDevice)
        defaults.synchronize()
    }
    
    public func countDailyInteractions() -> Int{
        let d : Date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let predicate = NSPredicate(format: "(%K >= %@)", PeripheralEntity.timestampKey, d as NSDate)
        
        if let c = countInteractions(predicate, distinctKey: PeripheralEntity.identifierKey){
            return c
        }
        return 0
    }
    
    public func countTotalInteractions() -> Int{
        if let c = self.countInteractions(nil, distinctKey: PeripheralEntity.identifierKey){
            return c
        }
        return 0
    }
    
}
