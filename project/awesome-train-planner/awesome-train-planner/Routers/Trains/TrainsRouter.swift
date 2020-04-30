//
//  TrainsRouter.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 30.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation
import UIKit

protocol TrainsRouterProtocol {
    var viewControler: UINavigationController { get }

    func showDetailsWith(train: TrainPosition)
}

class TrainsRouter: TrainsRouterProtocol {
    let viewControler: UINavigationController

    init(viewControler: UINavigationController) {
        self.viewControler = viewControler
    }

    func showDetailsWith(train: TrainPosition) {
        let stationViewController = TrainViewController(viewModel: TrainViewModel(train: train))
        viewControler.present(stationViewController, animated: true)
    }
}
