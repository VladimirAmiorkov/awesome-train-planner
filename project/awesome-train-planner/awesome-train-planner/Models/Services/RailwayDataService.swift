//
//  RailwayDataService.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 26.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation
import Combine

protocol DataService {
    func getAllStationsData(_ completion: @escaping ([Station]) -> Void) -> Void
}

class RailwayDataService: NSObject, DataService, XMLParserDelegate {
    
    
    private let api: IrishRailAPI = IrishRailAPI()
    private var cancellable: AnyCancellable?
    private let stationsParserDelegate = RailwaysDataXMLParserDelegate(rootKey: "objStation", dictionaryKeys: ["StationDesc", "StationAlias", "StationLatitude", "StationLongitude", "StationCode", "StationId"])
    private let stationDataParserDelegate = RailwaysDataXMLParserDelegate(rootKey: "objStationData", dictionaryKeys: ["Servertime", "Traincode", "Stationfullname", "Stationcode", "Querytime", "Traindate", "Origin", "Destination", "Origintime", "Destinationtime", "Status", "Lastlocation", "Duein", "Late", "Exparrival", "Expdepart", "Scharrival", "Schdepart", "Direction", "Traintype", "Locationtype"])
    
    // MARK: Stations data
    func getAllStationsData(_ completion: @escaping ([Station]) -> Void) {
        guard let url = api.getURLForAllStations() else { return }
        
        getStationsWith(url: url, completion: completion)
    }
    
    func getAllStationsData(withType type: IrishRailAPI.StationType, _ completion: @escaping ([Station]) -> Void) {
        guard let url = api.getURLForAllStations(withType: type) else { return }
        
        getStationsWith(url: url, completion: completion)
    }
    
    func getStationData(withName name: String, _ completion: @escaping (StationData?) -> Void) {
        guard let url = api.getStationData(withName: name) else { return }
        
        getStationDataWith(url: url, completion: completion)
    }
    
    
    // MARK: Trains data
    
    // MARK: Helper functions
    private func getStationsWith(url: URL, completion: @escaping ([Station]) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print(error ?? "Unknown error")
                return
            }
            
            let parser = XMLParser(data: data)
            parser.delegate = self.stationsParserDelegate
            var stations: [Station] = []
            if parser.parse() {
                if let result = self.stationsParserDelegate.getResult() {
                    for stationDict in result {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: stationDict, options: .prettyPrinted)
                            let station = try JSONDecoder().decode(Station.self, from: jsonData)
                            
                            stations.append(station)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    
                }
            }
            
            completion(stations)
        }
        
        task.resume()
    }
    
    private func getStationDataWith(url: URL, completion: @escaping (StationData?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print(error ?? "Unknown error")
                return
            }
            
            let parser = XMLParser(data: data)
            parser.delegate = self.stationDataParserDelegate
            var stationData: StationData? = nil
            if parser.parse() {
                if let result = self.stationDataParserDelegate.getResult() {
                    for stationDict in result {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: stationDict, options: .prettyPrinted)
                            stationData = try JSONDecoder().decode(StationData.self, from: jsonData)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    
                }
            }
            
            completion(stationData)
        }
        
        task.resume()
    }
}
