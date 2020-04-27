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
    
    let viewModel: MainViewModel
    let dataService: RailwayDataService
    
    required init?(coder: NSCoder) {
        self.viewModel = MainViewModel()
        self.dataService = RailwayDataService()
        
        super.init(coder: coder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dataService.getAllStationsData() { stations in
            self.viewModel.stations = stations
            self.viewModel.status = .loaded
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBidnings()
        
    }

    @IBAction func searchTap(_ sender: UIButton) {
        
    }
    
    private func setupBidnings() {
        statusSubscriber = viewModel.$status.receive(on: DispatchQueue.main).map { (status: LoadingStatus) -> String? in
            return status == LoadingStatus.loaded ? "Loaded" : "Loading"
        }.assign(to: \.text, on: statusLabel)
        
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

