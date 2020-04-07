//
//  StorageManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 29/02/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

// https://medium.com/@maddy.lucky4u/swift-4-core-data-part-3-creating-a-singleton-core-data-refactoring-insert-update-delete-9811af2fcf75

// https://www.raywenderlich.com/7569-getting-started-with-core-data-tutorial
// https://developer.apple.com/documentation/coredata/using_core_data_in_the_background
// https://nshipster.com/nspredicate/
// https://www.hackingwithswift.com/example-code/system/how-to-save-user-settings-using-userdefaults
class StorageManager{
    
    private class IBeaconEntity{
        static let entityName = "IBeacon"
        static let identifierKey = "identifier"
        static let distanceKey = "distance"
        static let accuracyKey = "accuracy"
        static let rssiKey = "rssi"
        static let timestampKey = "timestamp"
        static let latKey = "lat"
        static let lonKey = "lon"
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
            rssi: object.value(forKey: IBeaconEntity.rssiKey) as! Int64,
            distance: object.value(forKey: IBeaconEntity.distanceKey) as! Int,
            accuracy: object.value(forKey: IBeaconEntity.accuracyKey) as! Double,
            lat: object.value(forKey: IBeaconEntity.latKey) as! Double,
            lon: object.value(forKey: IBeaconEntity.lonKey) as! Double
        )
    }
    
    public func saveIBeacon(_ iBeaconInput : IBeaconDto){

        let entity = NSEntityDescription.entity(forEntityName: IBeaconEntity.entityName, in: self.persistentContainer.viewContext)!
        let ibeacon = NSManagedObject(entity: entity, insertInto: self.persistentContainer.viewContext)
        
        ibeacon.setValue(iBeaconInput.identifier, forKeyPath: IBeaconEntity.identifierKey)
        ibeacon.setValue(iBeaconInput.rssi, forKeyPath: IBeaconEntity.rssiKey)
        ibeacon.setValue(iBeaconInput.timestamp, forKeyPath: IBeaconEntity.timestampKey)
        ibeacon.setValue(iBeaconInput.distance, forKeyPath: IBeaconEntity.distanceKey)
        ibeacon.setValue(iBeaconInput.accuracy, forKey: IBeaconEntity.accuracyKey)
        ibeacon.setValue(iBeaconInput.lat, forKey: IBeaconEntity.latKey)
        ibeacon.setValue(iBeaconInput.lon, forKey: IBeaconEntity.lonKey)
        
        do {
            try self.persistentContainer.viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private func fetchIBeacons(_ predicate : NSPredicate? = nil, sort : NSSortDescriptor? = nil) -> [IBeaconDto]?{
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: IBeaconEntity.entityName)
        if let p = predicate{
            fetchRequest.predicate = p
        }
        
        if let s = sort{
            fetchRequest.sortDescriptors = [s]
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
    
    private func countDistinctInteractions(_ predicate : NSPredicate? = nil, distinctKey : String) -> Int?{

        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: IBeaconEntity.entityName)
        fetchRequest.resultType = .dictionaryResultType
        
        if let p = predicate{
            fetchRequest.predicate = p
        }
        
        let countExpressionDesc = NSExpressionDescription()
        countExpressionDesc.name = "returnValue"

        //let expression = NSExpression(forKeyPath: #keyPath(C.product)) //right here
        let expression = NSExpression(forKeyPath: distinctKey) //right here
        countExpressionDesc.expression = NSExpression(forFunction: "count:", arguments: [expression])
        countExpressionDesc.expressionResultType = .integer32AttributeType

//        fetchRequest.predicate = predicate
        fetchRequest.propertiesToGroupBy = [distinctKey]
        fetchRequest.propertiesToFetch = [distinctKey, countExpressionDesc]

        do {
            let results = try self.persistentContainer.viewContext.fetch(fetchRequest)
            print("RESULT COUNT", results)
            return results.count
        } catch {
            print(error)
            return nil
        }
    }
    
    public func readAllIBeacons(_ sortReverseTimestamp : Bool = false) -> [IBeaconDto]?{
        var sort : NSSortDescriptor? = nil
        if sortReverseTimestamp{
            sort = NSSortDescriptor(key: IBeaconEntity.timestampKey, ascending: false)
        }
        
        return fetchIBeacons(nil, sort: sort)
    }
    
    public func readIBeaconsByIdentifierToday(_ identifier : Int64) -> [IBeaconDto]?{
        let d : NSDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())! as NSDate
        let predicate = NSPredicate(format: "(%K = %@) and (timestamp > %@)", IBeaconEntity.identifierKey, identifier, d)
        return fetchIBeacons(predicate)
    }
    
    public func readIBeaconsNewerThanDate(_ date: Date) -> [IBeaconDto]?{
        print("returning newer than", date)
        let predicate = NSPredicate(format: "(%K > %@)", IBeaconEntity.timestampKey, date as NSDate)
        return fetchIBeacons(predicate)
    }
    
    public func getLastTimePush() -> Date?{
        let i = defaults.double(forKey: Constants.Setup.lastDatePushPreference)
        if i.isZero {
            return nil
        }
        return Date(timeIntervalSince1970: i)
    }
    
    public func getPushInProgress() -> Bool {
        let value = defaults.bool(forKey: Constants.Setup.pushInProgress)
        if value == false {
            print("no push found")
            return false
        }
    
        let time = defaults.double(forKey: Constants.Setup.pushInProgressSince)
        if time.isZero {
            print("time is zero")
            return false
        }
        let date = Date(timeIntervalSince1970: time)
        if date.addingTimeInterval(Constants.Setup.secondsIntervalBetweenConcurrentPushes) < Date() {
            return false
        }
        print("last date push", date)
        return true
    }
    
    public func setPushInProgress() {
        print("setting push in progress")
        defaults.set(true, forKey: Constants.Setup.pushInProgress)
        defaults.set(Date().timeIntervalSince1970 , forKey: Constants.Setup.pushInProgressSince)
    }
    
    public func resetPushInProgress() {
        print("resetting push in progress")
        defaults.set(false, forKey: Constants.Setup.pushInProgress)
        defaults.removeObject(forKey: Constants.Setup.pushInProgressSince)
    }
    
    public func setLastTimePush(_ date : Date){
        defaults.set(date.timeIntervalSince1970, forKey: Constants.Setup.lastDatePushPreference)
    }
    
    public func setPushInterval(_ time: TimeInterval) {
        print("Setting push interval to: \(time)")
        defaults.set(time, forKey: Constants.Setup.pushDelay)
    }
    
    public func getPushInterval() -> TimeInterval {
        let interval = defaults.double(forKey: Constants.Setup.pushDelay)
        
        if interval.isZero {
            return Constants.Setup.defaultSecondsIntervalBetweenPushes
        }
        return interval
    }
    
    public func getIdentifierDevice() -> Int?{
        let i = defaults.integer(forKey: Constants.Setup.identifierDevice)
        return i == 0 ? nil : i
    }
    
    public func setIdentifierDevice(_ identifierDevice : Int){
        defaults.set(identifierDevice, forKey: Constants.Setup.identifierDevice)
    }
    
    public func setPushId(_ id : String){
        defaults.set(id, forKey: Constants.Setup.pushIdentifier)
    }
    
    public func getPushId() -> String?{
        return defaults.string(forKey: Constants.Setup.pushIdentifier)
    }
    
    public func setTokenJWT(_ id : String){
        defaults.set(id, forKey: Constants.Setup.tokenJWT)
    }
    
    public func getTokenJWT() -> String?{
        return defaults.string(forKey: Constants.Setup.tokenJWT)
    }
    
    public func setStatusUser(_ status : Int){
        defaults.set(status, forKey: Constants.Setup.statusDevice)
    }
    
    public func getStatusUser() -> Int{
        return defaults.integer(forKey: Constants.Setup.statusDevice)
    }
    
    
    public func setLastNextTry(_ nextTry : Double){
        defaults.set(nextTry, forKey: Constants.Setup.lastNextTry)
    }
    
    public func getLastNextTry() -> Double{
        let nt = defaults.double(forKey: Constants.Setup.lastNextTry)
        if nt.isZero{
            return Constants.Setup.defaultSecondsIntervalBetweenPushes
        }
        return nt
    }
    
    
    public func setWarningLevel(_ status : Int){
        defaults.set(status, forKey: Constants.Setup.warningLevel)
    }
    
    public func getWarningLevel() -> Int{
        return defaults.integer(forKey: Constants.Setup.warningLevel)
    }
    
    public func isFirstAccess() -> Bool{
        return !defaults.bool(forKey: Constants.Setup.alreadyAccessed)
    }
    
    public func setFirstAccess(_ status : Bool){
        defaults.set(!status, forKey: Constants.Setup.alreadyAccessed)
    }
    
    public func setLocationNeeded(_ locationNeeded : Bool){
        defaults.set(locationNeeded, forKey: Constants.Setup.locationNeeded)
    }
    
    public func getLocationNeeded() -> Bool{
        return defaults.bool(forKey: Constants.Setup.locationNeeded)
    }
    
    public func setDistanceFilter(_ distanceFilter : Double){
        defaults.set(distanceFilter, forKey: Constants.Setup.distanceFilter)
    }
    
    public func getDistanceFilter() -> Double?{
        let d = defaults.double(forKey: Constants.Setup.distanceFilter)
        if d.isZero{
            return nil
        }
        return nil
    }
    
    public func removeDistanceFilter(){
        defaults.removeObject(forKey: Constants.Setup.distanceFilter)
    }
    
    public func setShareLocation(_ share : Bool){
        defaults.set(share, forKey: Constants.Setup.shareLocation)
    }
    
    public func getShareLocation() -> Bool{
        return defaults.bool(forKey: Constants.Setup.shareLocation)
    }
    
    public func setLastTimeLocationAccessed(_ date : Date){
        defaults.set(date.timeIntervalSince1970, forKey: Constants.Setup.lastTimeLocationAccessed)
    }
    
    public func getLastTimeLocationAccessed() -> Date?{
        let timestamp = defaults.double(forKey: Constants.Setup.lastTimeLocationAccessed)
        if timestamp == .zero{
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }
    
    public func setLastLocationAccessed(_ location : CLLocation){
        defaults.set(location.coordinate.longitude, forKey: Constants.Setup.locLongitudeKey)
        defaults.set(location.coordinate.latitude, forKey: Constants.Setup.locLatitudeKey)
        defaults.set(location.timestamp.timeIntervalSince1970, forKey: Constants.Setup.locDateKey)
    }
    
    public func getLastLocationAccessed() -> CLLocation?{
        let lon = defaults.double(forKey: Constants.Setup.locLongitudeKey)
        let lat = defaults.double(forKey: Constants.Setup.locLatitudeKey)
        let timestamp = defaults.double(forKey: Constants.Setup.locDateKey)
        if lon == .zero || lat == .zero || timestamp == .zero{
            return nil
        }
        return CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date(timeIntervalSince1970: timestamp))
    }
    
    /*
     let i = defaults.double(forKey: Constants.Setup.lastDatePushPreference)
     if i.isZero {
         return nil
     }
     return Date(timeIntervalSince1970: i)
     */
    
    public func countDailyInteractions() -> Int{
        let d : Date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let predicate = NSPredicate(format: "(%K >= %@)", IBeaconEntity.timestampKey, d as NSDate)
        
        if let c = countDistinctInteractions(predicate, distinctKey: IBeaconEntity.identifierKey){
            return c
        }
        return 0
    }
    
    public func countTotalInteractions() -> Int{
        if let c = self.countDistinctInteractions(nil, distinctKey: IBeaconEntity.identifierKey){
            return c
        }
        return 0
    }
    
}
