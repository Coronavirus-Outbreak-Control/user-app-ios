//
//  AlamofireManager.swift
//  CovidApp - Covid Community Alert
//
//  Created by Antonio Romano on 03/04/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation
import Alamofire

class AlamofireManager{

    static public let shared = AlamofireManager()
    private let endpoint_string = "https://api.coronaviruscheck.org"
    
    private init(){
        
    }
    
    public func pushInteractions(_ interactions : [IBeaconDto], token: String){
        var params = [String: Any]()
        params["p"] = "i"
        params["v"] = Constants.Setup.version
        params["i"] = StorageManager.shared.getIdentifierDevice()!
        var its = [[String: Any]]()
        for interaction in interactions{
            var p = [String: Any]()
            var distance = "f"
            if interaction.distance == 1{
                distance = "i"
            }
            if interaction.distance == 2{
                distance = "n"
            }
            p["o"] = interaction.identifier
            p["w"] = Int64(interaction.timestamp.timeIntervalSince1970)
            p["t"] = Int(interaction.interval)
            p["r"] = abs(interaction.rssi)
            p["s"] = Utils.roundToDecimals(interaction.accuracy, digits: 1)
            p["d"] = distance
            print("LON", interaction.lon)
            if !interaction.lon.isZero{
                p["x"] = Utils.roundToDecimals(interaction.lon, digits: 3)
                p["y"] = Utils.roundToDecimals(interaction.lat, digits: 3)
            }
            its.append(p)
        }
        params["z"] = its
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token,
            "Content-type": "application/json"
        ]
        
        let endpoint = "\(endpoint_string)/interaction/report"
        
        AF.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON {
                response in
                
                print("ALAMOFIRE RESPONSE", response)
                print(Date())
                print(params)
                switch response.result{
                case .success(let j):
                    print("success", j)
                    StorageManager.shared.setLastTimePush(interactions[interactions.count-1].timestampEnd.addingTimeInterval(Constants.Setup.minimumIntervalTime))
                    print("last time pushed", interactions[interactions.count-1].timestampEnd.addingTimeInterval(Constants.Setup.minimumIntervalTime))
                    
                    if let json = j as? [String: Any]{
                        print("JSON", json)
                        if let location = json["location"] as? Bool{
                            StorageManager.shared.setLocationNeeded(location)
                        }
                        if let nextTry = json["next_try"] as? Double{
                            let nt =  nextTry + Double.random(in: -0.25 ... 0.25) * nextTry
                            print("setting next_try as", nt)
                            StorageManager.shared.setLastNextTry(nt)
                            StorageManager.shared.setPushInterval(nt)
                        }
                        if let distanceFilter = json["distance_filter"] as? Double{
                            StorageManager.shared.setDistanceFilter(distanceFilter)
                        }else{
                            StorageManager.shared.removeDistanceFilter()
                        }
                    }
                    
                    break
                case .failure(let e):
                    print("error upload", e)
                    break
                }
                
                StorageManager.shared.resetPushInProgress()
            }
    }
    
    public func downloadDataNotification(_ url : String, callback: @escaping((Any, Bool) -> Void)){

        AF.request(url)
        .responseJSON{
            response in
            print("RESPONE", response)
            
            switch response.result{
            case .success(let j):
                print("success", j)
                callback(j, true)
                break
            case .failure(let e):
                print("error upload", e)
                callback(0, false)
                break
            }
            
        }

    }
    
}
