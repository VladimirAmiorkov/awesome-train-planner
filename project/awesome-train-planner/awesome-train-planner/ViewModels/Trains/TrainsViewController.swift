//
//  TrainsViewController.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 29.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation
import UIKit

protocol TrainsViewControllerProtocol {
    var viewModel: TrainsViewModel { get }
    var dataService: DataService { get }
    
    init(viewModel: TrainsViewModel, andDataService dataService: DataService)
}

class TrainsViewController: UIViewController, TrainsViewControllerProtocol {
    var viewModel: TrainsViewModel
    var dataService: DataService
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(viewModel: TrainsViewModel, andDataService dataService: DataService) {
        self.viewModel = viewModel
        self.dataService = dataService
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .blue
    }
}
