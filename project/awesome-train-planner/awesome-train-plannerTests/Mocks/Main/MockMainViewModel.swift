//
//  MockMainViewModel.swift
//  awesome-train-plannerTests
//
//  Created by Vladimir Amiorkov on 4.05.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation
@testable import Awesome_train_planner

class MockMainViewModel: MainViewModel {

    override init() {
        super.init()
        self.status = .loading
        self.origin = "A"
        self.destination = "B"
        self.directions = []
        self.stations = []
    }
}
