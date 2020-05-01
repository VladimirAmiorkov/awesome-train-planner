//
//  StationGraphNode.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 2.05.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation
import GameKit

class StationGraphNode: GKGraphNode {
    let code: String

    init(code: String) {
        self.code = code
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
