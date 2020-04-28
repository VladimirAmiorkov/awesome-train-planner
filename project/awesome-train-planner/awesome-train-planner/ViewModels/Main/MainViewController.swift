//
//  MainViewController.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 25.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import UIKit
import Combine

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var resultsList: UICollectionView!
    
    private var statusSubscriber: AnyCancellable?
    private var listSubscriber: AnyCancellable?
    private var fromSubscriber: AnyCancellable?
    private var toSubscriber: AnyCancellable?
    
    let viewModel: MainViewModel
    let dataService: RailwayDataService
    
    required init?(coder: NSCoder) {
        self.viewModel = MainViewModel()
        self.dataService = RailwayDataService()
        
        super.init(coder: coder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // TODO: get real data for "directions"
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
        
        dataService.getTrainMovements(byId: "E976", andDate: "26 apr 20") { data in
            switch data.status {
            case .failure:
                self.updateStatusWith(status: .error)
            case .successs:
                self.updateStatusWith(status: .loaded)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

// MARK: UICollectionViewDataSource
extension MainViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.stations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trainCard", for: indexPath)
        cell.contentView.backgroundColor = .red
        
        return cell
    }
    
}

