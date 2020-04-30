//
//  StationsRouter.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 29.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation
import UIKit

protocol StationsRouterProtocol {
    var viewControler: UINavigationController { get }
    
    func showDetailsWith(station: Station)
}

class StationsRouter: StationsRouterProtocol {
    let viewControler: UINavigationController
    
    init(viewControler: UINavigationController) {
        self.viewControler = viewControler
    }
    
    func showDetailsWith(station: Station) {
        let stationViewController = StationViewController(viewModel: StationViewModel(station: station))
        viewControler.present(stationViewController, animated: true)
    }
}
