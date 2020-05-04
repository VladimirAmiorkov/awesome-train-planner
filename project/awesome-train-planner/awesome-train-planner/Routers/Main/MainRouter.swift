//
//  MainRouterProtocol.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 4.05.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation
import UIKit

protocol MainRouterProtocol {
    var viewControler: UINavigationController { get }
    
    func showAlertWith(stations: [Station])

    init(viewControler: UINavigationController)
}

class MainRouter: MainRouterProtocol {

    var viewControler: UINavigationController

    required init(viewControler: UINavigationController) {
        self.viewControler = viewControler
    }

    func showAlertWith(stations: [Station]) {
        
    }
}
