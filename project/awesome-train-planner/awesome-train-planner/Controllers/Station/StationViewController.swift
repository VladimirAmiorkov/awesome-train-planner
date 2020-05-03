//
//  StationViewController.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 30.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation
import UIKit
import Combine

protocol StationViewControllerProtocol {
    var viewModel: StationViewModel { get }

    init(viewModel: StationViewModel)

    func setupBidnings()
}

class StationViewController: UIViewController, StationViewControllerProtocol {

    var viewModel: StationViewModel
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longtitudeLabel: UILabel!

    private var stationSubscriber: AnyCancellable?

    // MARK: Initialization
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(viewModel: StationViewModel) {
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

    // MARK: - IBAction

    @IBAction func copyNameTap(_ sender: Any) {
        UIPasteboard.general.string = viewModel.station.StationDesc
    }

    func setupBidnings() {
        stationSubscriber = viewModel.$station.receive(on: DispatchQueue.main).sink(receiveValue: { receiveValue in
            self.nameLabel.text = receiveValue.StationDesc
            self.codeLabel.text = receiveValue.StationCode
            self.idLabel.text = receiveValue.StationId
            self.latitudeLabel.text = receiveValue.StationLatitude
            self.longtitudeLabel.text = receiveValue.StationLongitude
        })
    }
}
