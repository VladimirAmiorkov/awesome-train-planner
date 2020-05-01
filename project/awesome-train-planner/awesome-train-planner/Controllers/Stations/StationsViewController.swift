//
//  StationsViewController.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 29.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation
import UIKit
import Combine

protocol StationsViewControllerProtocol {
    var viewModel: StationsViewModel { get }
    var dataService: DataService { get }
    var router: StationsRouterProtocol { get }
    
    init(viewModel: StationsViewModel, andDataService dataService: DataService, andRouter router: StationsRouterProtocol)
}

class StationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StationsViewControllerProtocol {
    
    var router: StationsRouterProtocol
    var viewModel: StationsViewModel
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

    required init(viewModel: StationsViewModel, andDataService dataService: DataService, andRouter router: StationsRouterProtocol) {
        self.viewModel = viewModel
        self.dataService = dataService
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        reloadData()
        setupBidnings()
    }

    // MARK: IBActions
    
    @IBAction func refreshTap(_ sender: UIButton) {
        reloadData()
    }

    private func setupView() {
        resultsList.backgroundColor = listColor
        resultsList.register(StationCell.self, forCellReuseIdentifier: StationCell.reuseIdentifier)
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
        
        listSubscriber = viewModel.$stations.receive(on: DispatchQueue.main).sink { receivedValue in
            self.resultsList.reloadData()
        }
    }
    
    private func reloadData() {
        updateStatusWith(status: .loading)
        dataService.getAllStationsData() { data in
            if let stations = data.data {
                self.viewModel.stations = stations.sorted { $0.StationDesc.lowercased() < $1.StationDesc.lowercased() }
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
extension StationsViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.stations.count
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = listColor
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StationCell.reuseIdentifier, for: indexPath)
        let stationObj = viewModel.stations[indexPath.row]

        cell.textLabel?.text = "'\(stationObj.StationCode)' \(stationObj.StationDesc)"
        
        return cell
    }
    
}

// MARK: UITableViewDelegate
extension StationsViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stationObj = viewModel.stations[indexPath.row]
        router.showDetailsWith(station: stationObj)
    }
}

// MARK: Constaints
private extension StationsViewController {
    private var listColor: UIColor { .systemGreen }
}
