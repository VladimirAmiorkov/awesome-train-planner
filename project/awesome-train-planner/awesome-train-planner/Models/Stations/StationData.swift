//
//  StationData.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 27.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation

struct StationData: Codable {
    
    let Servertime: String
    let Traincode: String
    let Stationfullname: String
    let Stationcode: String
    let Querytime: String
    let Traindate: String
    let Origin: String
    let Destination: String
    let Origintime: String
    let Destinationtime: String
    let Status: String
    let Lastlocation: String
    let Duein: String
    let Late: String
    let Exparrival: String
    let Expdepart: String
    let Scharrival: String
    let Schdepart: String
    let Direction: String
    let Traintype: String
    let Locationtype: String
}
