//
//  ApiManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Neil Kakkar on 02/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

// Adapted from https://developer.apple.com/documentation/foundation/url_loading_system/downloading_files_in_the_background
// https://developer.apple.com/documentation/foundation/url_loading_system/uploading_data_to_a_website
// https://developer.apple.com/documentation/foundation/urlsession
//
// stagger requests to API to ease load

import Foundation

class ApiManager: NSObject, URLSessionDelegate {

    private let endpoint_string = "http://api.coronaviruscheck.org"
    
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "coronavirus-app")
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = false
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    public static let shared = ApiManager()
    
    private override init(){
        super.init()
    }
    
    public func uploadInteractions(_ devices: [IBeaconDto], handler: @escaping () -> Void) -> Void {
        // will need to schedule this using the task scheduler
        // https://developer.apple.com/documentation/backgroundtasks/bgtaskscheduler
    
        struct Interaction: Codable {
            let i: Int64  // id of this device
            let o: Int64  // id of the interacted device
            let w: Int64  //unix time expressed in seconds
            let y: Double? //latitude of the position at interaction time: avoid if not available
            let x: Double? //longitude of the position at interaction time: avoid if not available
            let t: Int    // time of interaction, default is 10
            let r: Int64 // rssi value
        }
        
        var payload: [Interaction] = []
        let deviceID = StorageManager.shared.getIdentifierDevice()!
        
        for device in devices {
            let interaction = Interaction(
                i: Int64(deviceID),
                o: device.identifier,
                w: Int64(device.timestamp.timeIntervalSince1970),
                y: nil,
                x: nil,
                t: 10,
                r: device.rssi)
            payload.append(interaction)
        }
        
        let endpoint = URL(string: "\(endpoint_string)/interaction/report")
        var request = URLRequest(url: endpoint!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let uploadData = try? JSONEncoder().encode(payload) else {
            print("Failed to encode interactions")
            return
        }
        
        // revisit if crashes because need to write data to a tempdir
        // https://medium.com/livefront/uploading-data-in-the-background-in-ios-f93722013c6a
        let backgroundTask = urlSession.uploadTask(with: request, from: uploadData) { data, response, error in
            if let error = error {
                // error handling
                print(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    // error handling
                    print(response ?? "Unknown server error")
                    return
            }
            handler()
        }
        //backgroundTask.earliestBeginDate = Date().addingTimeInterval(60 * 60)
        //backgroundTask.countOfBytesClientExpectsToSend = 200
        //backgroundTask.countOfBytesClientExpectsToReceive = 500 * 1024
        backgroundTask.resume()
    }
    
    public func getActiveInteractions(handler: @escaping (Int) -> Void) -> Void {
        let url = URL(string: "\(endpoint_string)/count/")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                // error handling
                print(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    // error handling
                    print(response ?? "Unknown server error")
                    return
            }
            if let data = data {
                DispatchQueue.main.async {
                    do{
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        print(jsonResponse)
                        // will probably need some pre processing first
                        handler(jsonResponse as? Int ?? 0)
                      } catch let parsingError {
                         print("Error", parsingError)
                    }
                }
            }
        }
        task.resume()
    }
    
    public func getIsInfected(handler: @escaping (Bool) -> Void) -> Void {
        let url = URL(string: "\(endpoint_string)/infected/")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                // error handling
                print(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    // error handling
                    print(response ?? "Unknown server error")
                    return
            }
            if let data = data {
                DispatchQueue.main.async {
                    do{
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        print(jsonResponse)
                        // will probably need some pre processing first
                        handler(jsonResponse as? Bool ?? false)
                      } catch let parsingError {
                         print("Error", parsingError)
                    }
                }
            }
        }
        task.resume()
    }
    
    // Shouldn't have to call this more than once, ever.
    public func getNewDeviceId(id: String, model: String, version: String, handler: @escaping (Int64) -> Void) -> Void {
        let url = URL(string: "\(endpoint_string)/device/handshake/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        struct DeviceModel: Codable {
            let manufacturer: String
            let model: String
        }
        
        struct DeviceOS: Codable {
            let name: String
            let version: String
        }
        struct DeviceInfo: Codable {
            let id: String // unique generated ID
            let device: DeviceModel
            let os: DeviceOS
        }
        
        let deviceModel = DeviceModel(manufacturer: "Apple", model: model)
        let deviceOS = DeviceOS(name: "iOS", version: version)
        let deviceInfo = DeviceInfo(id: id, device: deviceModel, os: deviceOS)
        
        guard let uploadData = try? JSONEncoder().encode(deviceInfo) else {
            print("Failed to encode deviceInfo")
            return
        }
        
        request.httpBody = uploadData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // error handling
                print(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    // error handling
                    print(response ?? "Unknown server error")
                    return
            }
            if let data = data {
                DispatchQueue.main.async {
                    do{
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        print(jsonResponse)
                        // will probably need some pre processing first
                        handler(jsonResponse as! Int64)
                      } catch let parsingError {
                         print("Error", parsingError)
                    }
                }
            }
        }
        task.resume()
    }
    
    
}
