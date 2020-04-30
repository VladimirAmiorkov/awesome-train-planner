//
//  StationViewModel.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 30.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation

protocol StationViewModelProtocol {
    
    var station: Station { get }
}

class StationViewModel: StationViewModelProtocol {

    @Published var station: Station

    init(station: Station) {
        self.station = station
    }
}
