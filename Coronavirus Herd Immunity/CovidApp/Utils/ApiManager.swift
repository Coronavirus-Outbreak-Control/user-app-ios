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

    private let endpoint_string = "https://api.coronaviruscheck.org"
    
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
        let data: String?
        let next_try: TimeInterval
        let location: Bool?
        let exclude_far: Bool?
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
        // response background push interaction
        DispatchQueue.main.async {
            do{
                let response = try JSONDecoder().decode(pushResponse.self, from: data)
                print(response)
                let next_try = response.next_try + Double.random(in: -0.25 ... 0.25) * response.next_try
                StorageManager.shared.setLastNextTry(response.next_try)
                StorageManager.shared.setPushInterval(next_try)
                
                if let b = response.location{
                    StorageManager.shared.setLocationNeeded(b)
                }
                if let ex = response.exclude_far{
                    StorageManager.shared.setExcludeFar(ex)
                }
                
                StorageManager.shared.resetPushInProgress()
              } catch let parsingError {
                 print("Error", parsingError)
            }
        }
    }
    
    
    public func uploadInteractionsInBackground(_ devices: [IBeaconDto], token: String) -> Void {
        // https://medium.com/livefront/uploading-data-in-the-background-in-ios-f93722013c6a
        // We need to write to tempDir to make things work here
        //

        if devices.isEmpty {
            print("Ending task. No interactions.")
            return
        }
        
        if devices.count == 0{
            StorageManager.shared.resetPushInProgress()
        }
        
        let endpoint = URL(string: "\(endpoint_string)/interaction/report")
        var request = URLRequest(url: endpoint!)
        request.httpMethod = "POST"
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
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
    
    public func uploadInteractions(_ devices: [IBeaconDto], token: String, handler: @escaping (TimeInterval) -> Void) -> Void {
        print("Upload called")

        if devices.count == 0{
            handler(Constants.Setup.defaultSecondsIntervalBetweenPushes)
        }
        
        if devices.isEmpty {
            print("Ending task. No interactions.")
            handler(Constants.Setup.defaultSecondsIntervalBetweenPushes)
            return
        }
        
        print("gonna PUSH intereactions")
        
        let endpoint = URL(string: "\(endpoint_string)/interaction/report")
        var request = URLRequest(url: endpoint!)
        request.httpMethod = "POST"
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
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
                    do{
                        let response = try JSONDecoder().decode(pushResponse.self, from: data)
                        print(response)
                        let next_try = response.next_try + Double.random(in: -0.25 ... 0.25) * response.next_try
                        StorageManager.shared.setLastNextTry(response.next_try)
                        if let b = response.location{
                            StorageManager.shared.setLocationNeeded(b)
                        }
                        if let ex = response.exclude_far{
                            StorageManager.shared.setExcludeFar(ex)
                        }
                        handler(next_try)
                      } catch let parsingError {
                         print("Error", parsingError)
                    }
                }
            }
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
            let s: Double
            let v : Int
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
                d: distance,
                s: device.accuracy,
                v: Constants.Setup.version)
            payload.append(interaction)
        }
        
        print("PAYLOAD", payload)
        
        guard let uploadData = try? JSONEncoder().encode(payload) else {
            print("Failed to encode interactions")
            return nil
        }
        print("GONNA UPLOAD", uploadData)
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
    
    public func setPushNotificationId(deviceId: Int64, notificationId: String, token: String) {
        let url = URL(string: "\(endpoint_string)/device")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
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
            print("set push notification ID for device correctly")
        }
        task.resume()
        
    }
    // Shouldn't have to call this more than once, ever.
    public func handshakeNewDevice(googleToken: String?, handler: @escaping (Int64?, String?, String?) -> Void) -> Void {
        let id = DeviceInfoManager.getId()
        let model = DeviceInfoManager.getModel()
        let version = DeviceInfoManager.getVersion()
        
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
            let challenge: String?
        }
        
        struct ApiResponse: Codable {
            let id: Int64
            let token: String
        }
        
        let deviceModel = DeviceModel(manufacturer: "Apple", model: model)
        let deviceOS = DeviceOS(name: "iOS", version: version)
        let deviceInfo = DeviceInfo(id: id, device: deviceModel, os: deviceOS, challenge: googleToken)
        
        guard let uploadData = try? JSONEncoder().encode(deviceInfo) else {
            print("Failed to encode deviceInfo")
            handler(nil, nil, "Failed to encode deviceInfo")
            return
        }
        
        request.httpBody = uploadData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // error handling
                print(error)
                handler(nil, nil, error.localizedDescription)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    // error handling
                    print(response ?? "Unknown server error")
                    handler(nil, nil, "Unknown server error")
                    return
            }
            if let dataResponse = data {
                do{
                    let response = try JSONDecoder().decode(ApiResponse.self, from: dataResponse)
                    print("HANDSHAKE", response)
                    StorageManager.shared.setTokenJWT(response.token)
                    handler(response.id, response.token, nil)
                  }
                catch let parsingError {
                    print("Error", parsingError)
                    handler(nil, nil, "parsing error")
                }
            }
        }
        task.resume()
    }
    
    
}
