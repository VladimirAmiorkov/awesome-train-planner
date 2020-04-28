//
//  MainViewController.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 25.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import UIKit
import Combine

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var resultsList: UITableView!
    
    private var statusSubscriber: AnyCancellable?
    private var listSubscriber: AnyCancellable?
    private var fromSubscriber: AnyCancellable?
    private var toSubscriber: AnyCancellable?
    
    let viewModel: MainViewModel
    let dataService: RailwayDataService
    
//    required init?(coder: NSCoder) {
//        self.viewModel = MainViewModel()
//        self.dataService = RailwayDataService()
//
//        super.init(coder: coder)
//    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        self.dataService = RailwayDataService()
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
        resultsList.register(TrainCardCell.self, forCellReuseIdentifier: "trainCard")
        setupBidnings()
    }

    @IBAction func searchTap(_ sender: UIButton) {
        
    }
    
    private func updateStatusWith(status: LoadingStatus) {
        self.viewModel.status = status
    }
    
    private func setupBidnings() {
        statusSubscriber = viewModel.$status.receive(on: DispatchQueue.main).map { (status: LoadingStatus) -> String? in
            return status == LoadingStatus.loaded ? "Loaded" : "Loading"
        }.assign(to: \.text, on: statusLabel)
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "trainCard", for: indexPath)
        cell.backgroundColor = .red
        
        return cell
    }
    
}

