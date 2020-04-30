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
}

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MainViewControllerProtocol {

    @IBOutlet weak var statusIndicator: UIActivityIndicatorView!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var resultsList: UITableView!

    private var statusIndicatorSubscriber: AnyCancellable?
    private var listSubscriber: AnyCancellable?
    private var fromSubscriber: AnyCancellable?
    private var toSubscriber: AnyCancellable?
    
    let viewModel: MainViewModel
    let dataService: DataService

    // MARK: Initialization
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(viewModel: MainViewModel, andDataService dataService: DataService) {
        self.viewModel = viewModel
        self.dataService = dataService
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let from = viewModel.from, let to = viewModel.to else {
            return
        }
        
        dataService.getAllTrainsMovementsFrom(from) { data in

        }

        
//        dataService.getAllStationsData() { data in
//            if let stations = data.data {
//                self.viewModel.stations = stations
//            }
//
//            self.updateStatusWith(status: .loaded)
//        }
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

        setupView()
        setupBidnings()
    }

    // MARK: IBActions

    @IBAction func searchTap(_ sender: UIButton) {
        // TODO: get new directions from `dataService`
    }

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    private func setupView() {
        resultsList.register(TrainCardCell.self, forCellReuseIdentifier: TrainCardCell.reuseIdentifier)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
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
        
        fromSubscriber = viewModel.$from.receive(on: DispatchQueue.main).assign(to: \.text, on: fromTextField)
        
        toSubscriber = viewModel.$to.receive(on: DispatchQueue.main).assign(to: \.text, on: toTextField)
        
        listSubscriber = viewModel.$stations.receive(on: DispatchQueue.main).sink { receivedValue in
            self.resultsList.reloadData()
        }
    }

    private func updateStatusWith(status: LoadingStatus) {
        self.viewModel.status = status
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

