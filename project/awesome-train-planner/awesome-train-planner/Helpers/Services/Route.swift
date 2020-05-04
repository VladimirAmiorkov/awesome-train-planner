//
//  Route.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 1.05.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation

protocol RouteProtocol {
    var directions: [TrainRoute] { get set }
    var origin: String { get set }
    var destination: String { get set }
}

struct Route: RouteProtocol {

    var directions: [TrainRoute]
    var origin: String
    var destination: String
}
