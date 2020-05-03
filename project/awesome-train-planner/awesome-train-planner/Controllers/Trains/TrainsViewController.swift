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
    var router: TrainsRouterProtocol { get }
    
    init(viewModel: TrainsViewModel, andDataService dataService: DataService, andRouter router: TrainsRouterProtocol)
}

class TrainsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TrainsViewControllerProtocol {

    var router: TrainsRouterProtocol
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

    required init(viewModel: TrainsViewModel, andDataService dataService: DataService, andRouter router: TrainsRouterProtocol) {
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
        reloadStations()

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
        
        listSubscriber = viewModel.$trainPosition.receive(on: DispatchQueue.main).sink { receivedValue in
            self.resultsList.reloadData()
        }
    }
    
    private func reloadStations() {
        updateStatusWith(status: .loading)
        dataService.getCurrentTrains() { data in
            if let trainMovements = data.data {
                self.viewModel.trainPosition = trainMovements.sorted { $0.TrainCode.lowercased() < $1.TrainCode.lowercased() }
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
        viewModel.trainPosition.count
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = listColor
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: TrainCardCell.reuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: TrainCardCell.reuseIdentifier)
        }
        let trainMovement = viewModel.trainPosition[indexPath.row]

        cell!.textLabel?.text = "Code: \(trainMovement.TrainCode)"
        cell!.detailTextLabel?.text = "Direction: \(trainMovement.Direction)"
        
        return cell!
    }
    
}

// MARK: UITableViewDelegate
extension TrainsViewController {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trainObj = viewModel.trainPosition[indexPath.row]
        router.showDetailsWith(train: trainObj)
    }
}

// MARK: Constaints
private extension TrainsViewController {
    private var listColor: UIColor { .tertiarySystemBackground }
}
