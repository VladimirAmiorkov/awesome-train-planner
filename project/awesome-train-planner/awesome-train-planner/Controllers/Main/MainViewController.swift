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

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MainViewControllerProtocol {

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

        searchForDirections()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupBidnings()
    }

    // MARK: IBActions

    @IBAction func searchTap(_ sender: UIButton) {
        dismissKeyboard()
        searchForDirections()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        fromTextField.addTarget(self, action: #selector(fromTextFieldDidChange(_:)), for: .editingChanged)
        fromTextField.delegate = self

        toTextField.addTarget(self, action: #selector(toTextFieldDidChange(_:)), for: .editingChanged)
        toTextField.delegate = self
    }

    // MARK: UI Targets

    @objc private func fromTextFieldDidChange(_ textField: UITextField) {
        viewModel.origin = textField.text
    }

    @objc private func toTextFieldDidChange(_ textField: UITextField) {
        viewModel.destination = textField.text
    }

    // MARK: Private functions

    private func searchForDirections() {
        guard let from = viewModel.origin, let to = viewModel.destination else {
            return
        }

        updateStatusWith(status: .loading)

        dataService.findDirectionsFrom(from, destination: to) { data in
            switch data.status {
            case .failure:
                self.updateStatusWith(status: .failure)
            case .successs:
                self.updateStatusWith(status: .loaded)
                if let route = data.data {
                    if route.isDirect {
                        if let directRoute = self.getDirectDirection(fromDirections: route.directions) {
                            self.viewModel.directions = [directRoute]
                        }
                    } else {
                        self.viewModel.directions = route.directions
                    }
                }
            }
        }
    }

    private func getDirectDirection(fromDirections directions: [Direction]) -> Direction? {
        guard let firstDirection = directions.first, let lastDirection = directions.last else { return nil }

        return Direction(from: firstDirection.from, to: lastDirection.to, trainCode: firstDirection.trainCode, time: firstDirection.time, isDirect: true)
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
        
        fromSubscriber = viewModel.$origin.receive(on: DispatchQueue.main).assign(to: \.text, on: fromTextField)

        toSubscriber = viewModel.$destination.receive(on: DispatchQueue.main).assign(to: \.text, on: toTextField)
        
        listSubscriber = viewModel.$directions.receive(on: DispatchQueue.main).sink { receivedValue in
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
        viewModel.directions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: TrainCardCell.reuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: TrainCardCell.reuseIdentifier)
        }

        let directionObj = viewModel.directions[indexPath.row]

        let textString = "Train: " + directionObj.trainCode + " at: " + directionObj.time
        let detailText =  "From: " + directionObj.from + " to: " + directionObj.to
        var myAttribute = [NSAttributedString.Key.foregroundColor: UIColor.systemOrange]
        if directionObj.isDirect {
            myAttribute = [NSAttributedString.Key.foregroundColor: UIColor.systemGreen]
        }

        cell!.textLabel?.attributedText =  NSAttributedString(string: textString, attributes: myAttribute)
        cell!.detailTextLabel?.attributedText = NSAttributedString(string: detailText, attributes: myAttribute)
        
        return cell!
    }
    
}

// MARK: UITextFieldDelegate
extension MainViewController {
    
    func textFieldShouldReturn( _ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchForDirections()

        return false
    }
}
