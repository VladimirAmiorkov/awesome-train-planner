//
//  MainViewController.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 25.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import UIKit
import Combine

protocol MainViewControllerProtocol {
    var viewModel: MainViewModel { get }
    var dataService: DataService { get }
    
    init(viewModel: MainViewModel, andDataService dataService: DataService)
    
    func setupBidnings()
    func updateStatusWith(status: LoadingStatus)
}

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MainViewControllerProtocol {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusIndicator: UIActivityIndicatorView!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var resultsList: UITableView!
    
    private var statusLabelSubscriber: AnyCancellable?
    private var statusIndicatorSubscriber: AnyCancellable?
    private var listSubscriber: AnyCancellable?
    private var fromSubscriber: AnyCancellable?
    private var toSubscriber: AnyCancellable?
    
    let viewModel: MainViewModel
    let dataService: DataService
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(viewModel: MainViewModel, andDataService dataService: DataService) {
        self.viewModel = viewModel
        self.dataService = dataService
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // TODO: get real data for "directions"
        dataService.getAllStationsData() { data in
            if let stations = data.data {
                self.viewModel.stations = stations
            }

            self.updateStatusWith(status: .loaded)
        }
//
//        dataService.getAllStationsData(withType: IrishRailAPI.StationType.mainline) { data in
//            if let stations = data.data {
//                self.viewModel.stations = stations
//            }
//
//            self.updateStatusWith(status: .loaded)
//        }
//
//        dataService.getStationData(withName: "Cobh") { data in
//            self.updateStatusWith(status: .loaded)
//        }
//
//        dataService.getStationData(withCode: "BFSTC") { data in
//            self.updateStatusWith(status: .loaded)
//        }
        
//        dataService.getStationData(withStaticString: "br") { data in
//            switch data.status {
//            case .failure:
//                self.updateStatusWith(status: .error)
//            case .successs:
//                self.updateStatusWith(status: .loaded)
//            }
//        }
        
//        dataService.getCurrentTrains() { data in
//            switch data.status {
//            case .failure:
//                self.updateStatusWith(status: .error)
//            case .successs:
//                self.updateStatusWith(status: .loaded)
//            }
//        }
        
//        dataService.getCurrentTrains(withType: IrishRailAPI.TrainType.dart) { data in
//            switch data.status {
//            case .failure:
//                self.updateStatusWith(status: .error)
//            case .successs:
//                self.updateStatusWith(status: .loaded)
//            }
//        }
        
//        dataService.getTrainMovements(byId: "E976", andDate: "26 apr 20") { data in
//            switch data.status {
//            case .failure:
//                self.updateStatusWith(status: .error)
//            case .successs:
//                self.updateStatusWith(status: .loaded)
//            }
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        resultsList.register(UINib(nibName: "ListCardCell", bundle: nil), forCellWithReuseIdentifier: "trainCard")
        resultsList.register(TrainCardCell.self, forCellReuseIdentifier: TrainCardCell.reuseIdentifier)
        setupBidnings()
    }

    @IBAction func searchTap(_ sender: UIButton) {
        
    }
    
    func updateStatusWith(status: LoadingStatus) {
        self.viewModel.status = status
    }
    
    func setupBidnings() {
        statusLabelSubscriber = viewModel.$status.receive(on: DispatchQueue.main).map { (status: LoadingStatus) -> String? in
            return status == LoadingStatus.loaded ? "Loaded" : status == LoadingStatus.loading ? "Loading" : "Failure"
        }.assign(to: \.text, on: statusLabel)
        
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
        
        fromSubscriber = viewModel.$from.receive(on: DispatchQueue.main).assign(to: \.text, on: fromTextField)
        
        toSubscriber = viewModel.$to.receive(on: DispatchQueue.main).assign(to: \.text, on: toTextField)
        
        listSubscriber = viewModel.$stations.receive(on: DispatchQueue.main).sink { receivedValue in
            self.resultsList.reloadData()
        }
    }
}

// MARK: UITableViewDataSource
extension MainViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.stations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrainCardCell.reuseIdentifier, for: indexPath)
        cell.backgroundColor = .red
        
        return cell
    }
    
}

