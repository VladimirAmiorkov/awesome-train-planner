//
//  MockMainRouter.swift
//  awesome-train-plannerTests
//
//  Created by Vladimir Amiorkov on 4.05.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation
import UIKit
@testable import Awesome_train_planner

class MockMainRouter: MainRouterProtocol {
    
    var viewControler: UINavigationController
    var isShowAlertCalled = false

    func showAlertWith(stations: [Station], _ completion: @escaping (String) -> Void) {
        isShowAlertCalled = true
    }

    init() {
        self.viewControler = UINavigationController()
    }
}
