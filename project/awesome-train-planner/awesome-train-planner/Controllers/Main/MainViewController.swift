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
    @IBOutlet weak var directTripSwitch: UISwitch!
    @IBOutlet weak var statusLabel: UILabel!
    
    private var statusIndicatorSubscriber: AnyCancellable?
    private var listSubscriber: AnyCancellable?
    private var fromSubscriber: AnyCancellable?
    private var toSubscriber: AnyCancellable?
    private var directTripSubscriber: AnyCancellable?

    private var lastSearchOrigin: String = ""
    private var lastSearchDestination: String = ""
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchForDirections()

        setupView()
        setupBidnings()
    }

    // MARK: IBActions

    @IBAction func searchTap(_ sender: UIButton) {
        dismissKeyboard()
        searchForDirections()
    }

    @IBAction func directTripSwitchToggle(_ sender: UISwitch) {
        viewModel.directRoutesEnabled = sender.isOn
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

        statusLabel.isHidden = true
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
        guard let origin = viewModel.origin, let destination = viewModel.destination else {
            return
        }

        lastSearchOrigin = origin
        lastSearchDestination = destination

        updateStatusWith(status: .loading, andMessage:  "Fetching data ...")

        dataService.findDirectionsFrom(origin, andDestination: destination, forDirectRoute: viewModel.directRoutesEnabled) { data in
            switch data.status {
            case .failure:
                self.updateStatusWith(status: .failure, andMessage: data.error?.localizedDescription ?? "Error fetching data ...")
            case .successs:
                self.updateStatusWith(status: .loaded, andMessage: "Success")
                if let route = data.data {
                    if route.isDirect {
                        if let directRoute = self.getDirectDirection(fromDirections: route.directions) {
                            self.viewModel.directions = [directRoute]
                        }
                    } else {
                        self.viewModel.directions = route.directions
                        if self.viewModel.directions.count == 0 {
                            self.updateStatusLabelWith(color: .orange, andMessage: "No trips from \(origin) to \(destination) found", andIsHidden: false)
                        }
                    }
                }
            }
        }
    }

    private func getDirectDirection(fromDirections directions: [TrainRoute]) -> TrainRoute? {
        guard let firstDirection = directions.first, let lastDirection = directions.last else { return nil }

        return TrainRoute(originCode: firstDirection.originCode, destinationCode: lastDirection.destinationCode, originName: lastSearchOrigin, destinationName: lastSearchDestination, trainCode: firstDirection.trainCode, time: firstDirection.time, isDirect: true)
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
                self.statusIndicator.stopAnimating()
                self.statusIndicator.isHidden = true
                return
            }
        })
        
        fromSubscriber = viewModel.$origin.receive(on: DispatchQueue.main).assign(to: \.text, on: fromTextField)

        toSubscriber = viewModel.$destination.receive(on: DispatchQueue.main).assign(to: \.text, on: toTextField)
        
        listSubscriber = viewModel.$directions.receive(on: DispatchQueue.main).sink { receivedValue in
            self.resultsList.reloadData()
        }

        directTripSubscriber = viewModel.$directRoutesEnabled.receive(on: DispatchQueue.main).assign(to: \.isOn, on: directTripSwitch)
    }

    private func updateStatusWith(status: LoadingStatus, andMessage message: String) {
        viewModel.status = status
        if status == .failure {
            self.updateStatusLabelWith(color: .red, andMessage: message, andIsHidden: false)
        } else {
            self.updateStatusLabelWith(color: .label, andMessage: message, andIsHidden: true)
        }
    }


    /// Updates the `statis` label's text and coor and hides or shows it using an animation.
    /// - Parameters:
    ///   - color: the color of the text
    ///   - message: the text of the label
    ///   - isHidden: determines of the label is visible or not
    ///
    /// Note: Safe to be called from background threads
    @objc private func updateStatusLabelWith(color: UIColor, andMessage message: String, andIsHidden isHidden: Bool) {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.statusLabel.textColor = color
                self?.statusLabel.isHidden = isHidden
                self?.statusLabel.text = message
            }
        }
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

        let textString = "Train: \(directionObj.trainCode) at: \(directionObj.time)"
        let detailText =  "From: \(directionObj.originName) to: \(directionObj.destinationName)"
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
