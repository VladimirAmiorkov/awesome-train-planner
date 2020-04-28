//
//  TrainMovement.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 28.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation

struct TrainMovement: Codable {
    let TrainCode: String
    let TrainDate: String
    let LocationCode: String
    let LocationFullName: String
    let LocationOrder: String
    let LocationType: String
    let TrainOrigin: String
    let TrainDestination: String
    let ScheduledArrival: String
    let ScheduledDeparture: String
    let ExpectedArrival: String
    let ExpectedDeparture: String
    let Arrival: String
    let Departure: String
    let AutoArrival: String
    let AutoDepart: String
    let StopType: String
}
