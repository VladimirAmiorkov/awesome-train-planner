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
    var origin: String? { get set }
    var destination: String? { get set }
    var directions: [TrainRoute] { get set }
    var stations: [Station]? { get set }
}

class MainViewModel: MainViewModelProtocol {

    @Published var status: LoadingStatus
    @Published var origin: String?
    @Published var destination: String?
    @Published var directions: [TrainRoute]
    var stations: [Station]?
    
    init() {
        self.status = .loading
        self.origin = "Cork"
        self.destination = "Dublin Heuston"
        self.directions = []
    }
}
