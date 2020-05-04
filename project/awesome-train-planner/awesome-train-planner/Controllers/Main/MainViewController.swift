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
    var router: MainRouterProtocol { get }
    
    init(viewModel: MainViewModel, andDataService dataService: DataService, andRouter router: MainRouterProtocol)
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

    private var lastSearchOrigin: String = ""
    private var lastSearchDestination: String = ""
    
    let viewModel: MainViewModel
    let dataService: DataService
    var router: MainRouterProtocol

    // MARK: Initialization
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(viewModel: MainViewModel, andDataService dataService: DataService, andRouter router: MainRouterProtocol) {
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
        setupBidnings()
        searchForDirections()
        getStationsData()
    }

    // MARK: IBActions

    @IBAction func searchTap(_ sender: UIButton) {
        dismissKeyboard()
        searchForDirections()
    }

    @IBAction func switchOriginAndDestination(_ sender: UIButton) {
        let originValue = viewModel.origin
        viewModel.origin = viewModel.destination
        viewModel.destination = originValue
    }

    @IBAction func pickOriginTap(_ sender: UIButton) {
        guard let data = viewModel.stations else { return }

        router.showAlertWith(stations: data) { stationName in
            self.viewModel.origin = stationName
        }
    }

    @IBAction func pickDestionationTap(_ sender: UIButton) {
        guard let data = viewModel.stations else { return }

        router.showAlertWith(stations: data) { stationName in
            self.viewModel.destination = stationName
        }
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

    private func getStationsData() {
        dataService.getAllStationsData() { receivedData in
            self.viewModel.stations = receivedData.data
            if let stations = self.viewModel.stations {
                self.viewModel.stations = stations.sorted { $0.stationDescCaseInsensitive < $1.StationDesc.lowercased() }
            }
        }
    }

    private func searchForDirections() {
        guard let origin = viewModel.origin, let destination = viewModel.destination else {
            return
        }

        lastSearchOrigin = origin
        lastSearchDestination = destination

        updateStatusWith(status: .loading, andMessage:  "Fetching data ...")

        // Mock stations: A, B, C, Z
        // A to Z uses two different trains that fit into the a time frame. Remove this
        //  To use simply replace `findDirectionsFrom(origin, andDestination: destination)` with `dataService.mockFindDirectionsFrom("A", andDestination: "Z")`
//        dataService.mockFindDirectionsFrom("A", andDestination: "Z") { data in
        dataService.findDirectionsFrom(origin, andDestination: destination) { data in
            switch data.status {
            case .failure:
                self.updateStatusWith(status: .failure, andMessage: data.error?.localizedDescription ?? "Error fetching data ...")
            case .successs:
                self.updateStatusWith(status: .loaded, andMessage: "Success")
                if let route = data.data {
                    self.viewModel.directions = route.directions
                    if self.viewModel.directions.count == 0 {
                        self.updateStatusLabelWith(color: .orange, andMessage: "No trips from \(origin) to \(destination) found", andIsHidden: false)
                    }
                }
            }
        }
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

        let boldFont = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
        let startString = NSMutableAttributedString(string: "Train: ", attributes: nil)
        let trainStringAttributes: [NSAttributedString.Key: Any] = boldFont
        let trainString = NSMutableAttributedString(string: "\(directionObj.trainCode) ", attributes: trainStringAttributes)

        let fromString = NSMutableAttributedString(string: "from: ", attributes: nil)
        let fromStringAttributes: [NSAttributedString.Key: Any] = boldFont
        let originString = NSMutableAttributedString(string: "\(directionObj.originName) ", attributes: fromStringAttributes)

        let toString = NSMutableAttributedString(string: "to: ", attributes: nil)
        let toStringAttributes: [NSAttributedString.Key: Any] = boldFont
        let destinationString = NSMutableAttributedString(string: "\(directionObj.destinationName) ", attributes: toStringAttributes)

        startString.append(trainString)
        startString.append(fromString)
        startString.append(originString)
        startString.append(toString)
        startString.append(destinationString)

        let atString = NSMutableAttributedString(string: "At: ", attributes: nil)
        let timeString = NSMutableAttributedString(string: "\(directionObj.time) ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13)])
        atString.append(timeString)

        cell!.textLabel?.attributedText =  startString
        cell!.detailTextLabel?.attributedText = atString
        
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
