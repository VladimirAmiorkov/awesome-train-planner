//
//  TrainViewController.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 30.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation
import UIKit
import Combine

protocol TrainViewControllerProtocol {
    var viewModel: TrainViewModel { get }

   init(viewModel: TrainViewModel)

   func setupBidnings()
}

class TrainViewController: UIViewController, TrainViewControllerProtocol {
    var viewModel: TrainViewModel

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    private var trainMovementSubscriber: AnyCancellable?

    // MARK: Initialization

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(viewModel: TrainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBidnings()
    }

    func setupBidnings() {
        trainMovementSubscriber = viewModel.$train.receive(on: DispatchQueue.main).sink(receiveValue: { receiveValue in
            self.nameLabel.text = receiveValue.TrainCode
            self.codeLabel.text = receiveValue.TrainCode
            self.directionLabel.text = receiveValue.Direction
            self.dateLabel.text = receiveValue.TrainDate
            self.messageLabel.text = receiveValue.PublicMessage.replacingOccurrences(of: "\\n", with: "\n")
        })
    }
}
