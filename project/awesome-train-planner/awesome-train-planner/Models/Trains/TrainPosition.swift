//
//  TrainPosition.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 28.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation

struct TrainPosition: Codable {
    let TrainStatus: String
    let TrainLatitude: String
    let TrainLongitude: String
    let TrainCode: String
    let TrainDate: String
    let PublicMessage: String
    let Direction: String
}
