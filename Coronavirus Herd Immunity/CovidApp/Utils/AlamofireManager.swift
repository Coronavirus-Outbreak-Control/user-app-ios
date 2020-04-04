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
            p["t"] = interaction.interval
            p["r"] = abs(interaction.rssi)
            p["s"] = interaction.accuracy
            p["d"] = distance
            if !interaction.lon.isZero{
                p["x"] = interaction.lon
                p["y"] = interaction.lat
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
                    StorageManager.shared.setLastTimePush(interactions[interactions.count-1].timestampEnd.addingTimeInterval(0))
                    print("last time pushed", interactions[interactions.count-1].timestampEnd.addingTimeInterval(1))
                    print("UNIX", interactions[interactions.count-1].timestampEnd.addingTimeInterval(1).timeIntervalSince1970)
                    
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
    
}
