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

    private let endpoint_string = "https://corona19/api"
    
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "coronavirus-app")
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    public static let shared = ApiManager()
    
    private override init(){
        super.init()
    }
    
    public func uploadInteractions(_ devices: [IBeaconDto]) -> Void {
        // will need to schedule this using the task scheduler
        // https://developer.apple.com/documentation/backgroundtasks/bgtaskscheduler
        
        struct interaction: Codable {
            let deviceID: String
            let beacons: [IBeaconDto]
        }

        let endpoint = URL(string: "\(endpoint_string)/upload/")
        var request = URLRequest(url: endpoint!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // TODO: create interaction object from devices
        guard let uploadData = try? JSONEncoder().encode(devices) else {
            print("Failed to encode interactions")
            return
        }
        
        let backgroundTask = urlSession.uploadTask(with: request, from: uploadData)
        // revisit if crashes because need to write data to a tempdir
        // https://medium.com/livefront/uploading-data-in-the-background-in-ios-f93722013c6a
        
        backgroundTask.earliestBeginDate = Date().addingTimeInterval(60 * 60)
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
    
    
}
