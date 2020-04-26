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
    var from: String?
    var to: String?
    var directions: [Direction]
    
    init() {
        self.status = .loading
        self.from = "Arklow"
        self.to = "Shankill"
        self.directions = []
    }
}
