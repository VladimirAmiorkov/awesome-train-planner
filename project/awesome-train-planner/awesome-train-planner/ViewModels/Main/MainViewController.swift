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
    
    let viewModel: MainViewModel

    required init?(coder: NSCoder) {
        self.viewModel = MainViewModel()
        
        super.init(coder: coder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // trigger API call
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func searchTap(_ sender: UIButton) {
    }
}

// MARK: UICollectionViewDataSource
extension MainViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trainCard", for: indexPath)
        
        return cell
    }
    
}

