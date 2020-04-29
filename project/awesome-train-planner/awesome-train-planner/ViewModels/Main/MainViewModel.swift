//
//  MainViewModel.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 26.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation

protocol MainViewModelProtocol {
    var status: LoadingStatus { get set }
    var from: String? { get set }
    var to: String? { get set }
    var directions: [Direction] { get set }
}

class MainViewModel: MainViewModelProtocol {
    @Published var status: LoadingStatus
    @Published var from: String?
    @Published var to: String?
    @Published var directions: [Direction]
    
    // TODO: move this to its own view controller
    @Published var stations: [Station]
    
    init() {
        self.status = .loading
        self.from = "Arklow"
        self.to = "Shankill"
        self.directions = []
        self.stations = []
    }
}
