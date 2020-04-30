//
//  TrainViewModel.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 30.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation

protocol TrainViewModelProtocol {
    var train: TrainPosition { get }
}

class TrainViewModel: TrainViewModelProtocol {
    @Published var train: TrainPosition

    init(train: TrainPosition) {
        self.train = train
    }
}
