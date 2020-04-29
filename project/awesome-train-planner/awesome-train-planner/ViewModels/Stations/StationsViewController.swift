//
//  StationsViewController.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 29.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation
import UIKit

class StationsViewController: UIViewController {
    var viewModel: StationsViewModel
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: StationsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .green
    }
}
