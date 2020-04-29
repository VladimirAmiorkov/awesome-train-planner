//
//  StationsViewController.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 29.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation
import UIKit

protocol StationsViewControllerProtocol {
    var viewModel: StationsViewModel { get }
    var dataService: DataService { get }
}

class StationsViewController: UIViewController, StationsViewControllerProtocol {
    var viewModel: StationsViewModel
    var dataService: DataService
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: StationsViewModel, andDataService dataService: DataService) {
        self.viewModel = viewModel
        self.dataService = dataService
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .green
    }
}
