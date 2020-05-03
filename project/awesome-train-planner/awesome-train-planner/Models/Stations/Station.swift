//
//  Station.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 26.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation

struct Station: Codable {
    
    let StationDesc: String
    var stationDescCaseInsensitive: String {
        get {
            return StationDesc.lowercased()
        }
    }
    let StationAlias: String
    let StationLatitude: String
    let StationLongitude: String
    let StationCode: String
    let StationId: String
}
