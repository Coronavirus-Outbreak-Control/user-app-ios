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

class ApiManager: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {

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
    
    private struct pushResponse: Codable {
        let data: String
        let next_try: TimeInterval
        let location: Bool?
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Data upload in background completed")
        if let error = error {
            // error handling
            print(error)
            return
        }
        else {
            StorageManager.shared.setLastTimePush(Date())
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        DispatchQueue.main.async {
            do{
                let response = try JSONDecoder().decode(pushResponse.self, from: data)
                print(response)
                StorageManager.shared.setPushInterval(response.next_try)
                if let b = response.location{
                    StorageManager.shared.setLocationNeeded(b)
                }
              } catch let parsingError {
                 print("Error", parsingError)
            }
        }
    }
    
    
    public func uploadInteractionsInBackground(_ devices: [IBeaconDto]) -> Void {
        // https://medium.com/livefront/uploading-data-in-the-background-in-ios-f93722013c6a
        // We need to write to tempDir to make things work here
        //

        if devices.isEmpty {
            print("Ending task. No interactions.")
            return
        }
        
        let endpoint = URL(string: "\(endpoint_string)/interaction/report")
        var request = URLRequest(url: endpoint!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let uploadData = generatePayload(devices) {
        
            let tempDir = FileManager.default.temporaryDirectory
            let localURL = tempDir.appendingPathComponent("throwaway")
            try? uploadData.write(to: localURL)

            let backgroundTask = urlSession.uploadTask(with: request, fromFile: localURL)
            //backgroundTask.earliestBeginDate = Date().addingTimeInterval(60 * 60)
            //backgroundTask.countOfBytesClientExpectsToSend = 200
            //backgroundTask.countOfBytesClientExpectsToReceive = 500 * 1024
            backgroundTask.resume()
        }
    }
    
    public func uploadInteractions(_ devices: [IBeaconDto], handler: @escaping (TimeInterval) -> Void) -> Void {
        print("Upload called")

        if devices.isEmpty {
            print("Ending task. No interactions.")
            handler(Constants.Setup.secondsIntervalBetweenPushes)
            return
        }
        
        let endpoint = URL(string: "\(endpoint_string)/interaction/report")
        var request = URLRequest(url: endpoint!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let uploadData = generatePayload(devices) {
            let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
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
                            let response = try JSONDecoder().decode(pushResponse.self, from: data)
                            print(response)
                            handler(response.next_try)
                            if let b = response.location{
                                StorageManager.shared.setLocationNeeded(b)
                            }
                          } catch let parsingError {
                             print("Error", parsingError)
                        }
                    }
                }
            }
            //backgroundTask.earliestBeginDate = Date().addingTimeInterval(60 * 60)
            //backgroundTask.countOfBytesClientExpectsToSend = 200
            //backgroundTask.countOfBytesClientExpectsToReceive = 500 * 1024
            task.resume()
        }
    }
    
    private func generatePayload(_ devices: [IBeaconDto]) -> Data? {
        struct Interaction: Codable {
            let i: Int64  // id of this device
            let o: Int64  // id of the interacted device
            let w: Int64  //unix time expressed in seconds
            let t: Int    // time of interaction, default is 10
            let x: Double // longitude
            let y: Double // latitude
            let r: Int64 // rssi value
            let p: String
            let d: String
        }
        
        var payload: [Interaction] = []
        let deviceID = StorageManager.shared.getIdentifierDevice()!
        
        for device in devices {
            var distance = "f"
            if device.distance == 1{
                distance = "i"
            }
            if device.distance == 2{
                distance = "n"
            }
            
            let interaction = Interaction(
                i: Int64(deviceID),
                o: device.identifier,
                w: Int64(device.timestamp.timeIntervalSince1970),
                t: Int(device.interval),
                x: device.lon,
                y: device.lat,
                r: device.rssi,
                p: device.platform,
                d: distance)
            payload.append(interaction)
        }
        
        guard let uploadData = try? JSONEncoder().encode(payload) else {
            print("Failed to encode interactions")
            return nil
        }
        
        return uploadData
        
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
    
    public func setPushNotificationId(deviceId: Int64, notificationId: String) {
        let url = URL(string: "\(endpoint_string)/device")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        struct ApiRequest: Codable {
            let id: Int64
            let push_id: String
            let platform: String
        }
        
        let apiRequest = ApiRequest(id: deviceId, push_id: notificationId, platform: "iOS")
        
        guard let uploadData = try? JSONEncoder().encode(apiRequest) else {
            print("Failed to encode request")
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
            print("set push notification ID for device")
        }
        task.resume()
        
    }
    // Shouldn't have to call this more than once, ever.
    public func getNewDeviceId(id: String, model: String, version: String, handler: @escaping (Int64) -> Void) -> Void {
        let url = URL(string: "\(endpoint_string)/device/handshake")!
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
        
        struct ApiResponse: Codable {
            let id: Int64
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
            if let dataResponse = data {
                DispatchQueue.main.async {
                    do{
                        let response = try JSONDecoder().decode(ApiResponse.self, from: dataResponse)
                        print(response)
                        handler(response.id)
                      } catch let parsingError {
                         print("Error", parsingError)
                    }
                    
                }
            }
        }
        task.resume()
    }
    
    
}