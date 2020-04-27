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
    
    // TODO: move this to background thread
    func getAllStationsData(_ completion: @escaping ([Station]) -> Void) {
        guard let url = api.getURLForAllStations() else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print(error ?? "Unknown error")
                return
            }
            
            let parser = XMLParser(data: data)
            parser.delegate = self.stationsParserDelegate
            if parser.parse() {
                if let result = self.stationsParserDelegate.getResult() {
                    var stations: [Station] = []
                    for stationDict in result {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: stationDict, options: .prettyPrinted)
                            let station = try JSONDecoder().decode(Station.self, from: jsonData)
                            
                            stations.append(station)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    completion(stations)
                }
            }
        }
        task.resume()
    }
}
