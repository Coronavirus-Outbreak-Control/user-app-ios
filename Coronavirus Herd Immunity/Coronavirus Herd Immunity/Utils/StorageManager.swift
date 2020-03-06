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
    
    private class IBeaconEntity{
        static let entityName = "IBeacon"
        static let identifierKey = "identifier"
        static let rssiKey = "rssi"
        static let timestampKey = "timestamp"
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
    
    private func buildIBeacon(_ object : NSManagedObject) -> IBeaconDto{
        return IBeaconDto(
            identifier: object.value(forKey: IBeaconEntity.identifierKey) as! Int64,
            timestamp: object.value(forKey: IBeaconEntity.timestampKey) as! Date,
            rssi: object.value(forKey: IBeaconEntity.rssiKey) as! Int64
        )
    }
    
    public func saveIBeacon(_ iBeaconInput : IBeaconDto){

        let entity = NSEntityDescription.entity(forEntityName: IBeaconEntity.entityName, in: self.persistentContainer.viewContext)!
        let ibeacon = NSManagedObject(entity: entity, insertInto: self.persistentContainer.viewContext)
        
        ibeacon.setValue(iBeaconInput.identifier, forKeyPath: IBeaconEntity.identifierKey)
        ibeacon.setValue(iBeaconInput.rssi, forKeyPath: IBeaconEntity.rssiKey)
        ibeacon.setValue(iBeaconInput.timestamp, forKeyPath: IBeaconEntity.timestampKey)
        
        do {
            try self.persistentContainer.viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private func fetchIBeacons(_ predicate : NSPredicate? = nil) -> [IBeaconDto]?{
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: IBeaconEntity.entityName)
        if let p = predicate{
            fetchRequest.predicate = p
        }
        
        do {
            let fetchRes : [NSManagedObject] = try self.persistentContainer.viewContext.fetch(fetchRequest)
            var ibeacons = [IBeaconDto]()
            for managedObj in fetchRes {
                ibeacons.append(self.buildIBeacon(managedObj))
            }
            return ibeacons.count > 0 ? ibeacons : nil
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    private func countInteractions(_ predicate : NSPredicate? = nil, distinctKey : String? = nil) -> Int?{
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: IBeaconEntity.entityName)
        
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
    
    public func readAllIBeacons() -> [IBeaconDto]?{
        return fetchIBeacons()
    }
    
    public func readIBeaconsByIdentifierToday(_ identifier : Int64) -> [IBeaconDto]?{
        let d : NSDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())! as NSDate
        let predicate = NSPredicate(format: "(%K = %@) and (timestamp > %@)", IBeaconEntity.identifierKey, identifier, d)
        return fetchIBeacons(predicate)
    }
    
    public func getTimeBlockUserDefatuls() -> String?{
        return defaults.string(forKey: Costants.Setup.timeBlockKeyPreference)
    }
    
    public func setTimeBlockUserDefatuls(_ timeBlock : String){
        defaults.set(timeBlock, forKey: Costants.Setup.timeBlockKeyPreference)
        defaults.synchronize()
    }
    
    public func getIdentifierDevice() -> Int?{
        let i = defaults.integer(forKey: Costants.Setup.identifierDevice)
        return i == 0 ? nil : i
    }
    
    public func setIdentifierDevice(_ identifierDevice : Int){
        defaults.set(identifierDevice, forKey: Costants.Setup.identifierDevice)
        defaults.synchronize()
    }
    
    public func countDailyInteractions() -> Int{
        let d : Date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let predicate = NSPredicate(format: "(%K >= %@)", IBeaconEntity.timestampKey, d as NSDate)
        
        if let c = countInteractions(predicate, distinctKey: IBeaconEntity.identifierKey){
            return c
        }
        return 0
    }
    
    public func countTotalInteractions() -> Int{
        if let c = self.countInteractions(nil, distinctKey: IBeaconEntity.identifierKey){
            return c
        }
        return 0
    }
    
}
