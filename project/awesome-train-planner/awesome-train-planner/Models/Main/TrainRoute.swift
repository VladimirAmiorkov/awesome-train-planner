//
//  TrainRoute.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 26.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation

struct TrainRoute: Comparable {
    
    static func < (lhs: TrainRoute, rhs: TrainRoute) -> Bool {
        return lhs.hashcode == rhs.hashcode
    }

    let originCode: String
    let destinationCode: String
    let originName: String
    let destinationName: String
    let trainCode: String
    let time: String
    let isDirect: Bool
    var hashcode: String {
        get {
            return trainCode + originCode + destinationCode
        }
    }
}
