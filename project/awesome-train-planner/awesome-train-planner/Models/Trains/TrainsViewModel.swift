//
//  TrainsViewModel.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 29.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation

protocol TrainsViewModelProtocol {
    var status: LoadingStatus { get set }
    var trainMovements: [TrainPosition] { get set }
}

class TrainsViewModel: TrainsViewModelProtocol {
    
    @Published var status: LoadingStatus
    @Published var trainMovements: [TrainPosition]
    
    init() {
        self.status = .loading
        self.trainMovements = []
    }
}
