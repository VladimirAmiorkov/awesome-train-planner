//
//  RailwaysResponse.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 28.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation

class RailwaysResponse<T> {
    var status: ReponseStatus {
        get { error != nil ? .failure : .successs }
    }
    var error: Error?
    var data: T?
    
    init(data: T?) {
        self.data = data
    }
}

extension RailwaysResponse {
    enum ReponseStatus {
        case successs
        case failure
    }
}
