//
//  StationsViewModel.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 29.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation

protocol StationsViewModelProtocol {
    var status: LoadingStatus { get set }
    var stations: [Station] { get set }
}

class StationsViewModel: StationsViewModelProtocol {
    
    @Published var status: LoadingStatus
    @Published var stations: [Station]
    
    init() {
        self.status = .loading
        self.stations = []
    }
}
