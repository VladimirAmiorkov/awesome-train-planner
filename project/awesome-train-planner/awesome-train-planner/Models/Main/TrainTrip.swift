//
//  TrainTrip.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 30.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation

struct TrainPath {
    var code: String
    var origin: String
    var destination: String
    var movements: [TrainMovement]
}
