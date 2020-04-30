//
//  TrainsViewController.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 29.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation
import UIKit
import Combine

protocol TrainsViewControllerProtocol {
    var viewModel: TrainsViewModel { get }
    var dataService: DataService { get }
    
    init(viewModel: TrainsViewModel, andDataService dataService: DataService)
}

class TrainsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TrainsViewControllerProtocol {
    var viewModel: TrainsViewModel
    var dataService: DataService

    @IBOutlet weak var statusIndicator: UIActivityIndicatorView!
    @IBOutlet weak var resultsList: UITableView!

    private var statusIndicatorSubscriber: AnyCancellable?
    private var listSubscriber: AnyCancellable?

    // MARK: Initialization

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(viewModel: TrainsViewModel, andDataService dataService: DataService) {
        self.viewModel = viewModel
        self.dataService = dataService
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        reloadStations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsList.register(StationCell.self, forCellReuseIdentifier: StationCell.reuseIdentifier)
        setupBidnings()
    }

    // MARK: IBActions
    
    @IBAction func refreshTap(_ sender: UIButton) {
        reloadStations()
    }

    private func setupView() {
        resultsList.backgroundColor = listColor
    }
    
    private func updateStatusWith(status: LoadingStatus) {
        self.viewModel.status = status
    }
    
    private func setupBidnings() {
        statusIndicatorSubscriber = viewModel.$status.receive(on: DispatchQueue.main).sink(receiveValue: { completition in
            switch completition {
            case .loaded:
                self.statusIndicator.stopAnimating()
                self.statusIndicator.isHidden = true
                return
            case .loading:
                self.statusIndicator.startAnimating()
                self.statusIndicator.isHidden = false
                return
            case .failure:
                // TODO: user router to show an alert
                return
            }
        })
        
        listSubscriber = viewModel.$trainMovements.receive(on: DispatchQueue.main).sink { receivedValue in
            self.resultsList.reloadData()
        }
    }
    
    private func reloadStations() {
        updateStatusWith(status: .loading)
        dataService.getCurrentTrains() { data in
            if let trainMovements = data.data {
                self.viewModel.trainMovements = trainMovements
            }
            
            if data.status != .failure {
                self.updateStatusWith(status: .loaded)
            } else {
                self.updateStatusWith(status: .failure)
            }
        }
    }
}

// MARK: UITableViewDataSource
extension TrainsViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.trainMovements.count
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = listColor
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StationCell.reuseIdentifier, for: indexPath)
        let trainMovement = viewModel.trainMovements[indexPath.row]

        cell.textLabel?.text = trainMovement.TrainCode
        
        return cell
    }
    
}

// MARK: UITableViewDelegate
extension TrainsViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: go to StationViewControler via router
    }
}

// MARK: Constaints
private extension TrainsViewController {
    private var listColor: UIColor { .systemOrange }
}
