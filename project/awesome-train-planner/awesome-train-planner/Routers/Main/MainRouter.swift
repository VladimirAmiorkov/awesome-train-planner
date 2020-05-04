//
//  MainRouterProtocol.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 4.05.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation
import UIKit

protocol MainRouterProtocol {
    var viewControler: UINavigationController { get }
    
    func showAlertWith(stations: [Station], _ completion: @escaping (String) -> Void)
}

class MainRouter: MainRouterProtocol {

    var viewControler: UINavigationController

    required init(viewControler: UINavigationController) {
        self.viewControler = viewControler
    }

    func showAlertWith(stations: [Station], _ completion: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: "Select station", message: nil, preferredStyle: .actionSheet)

        let action = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(action)

        for station in stations {
            let action = UIAlertAction(title: "\(station.StationDesc) code: \(station.StationCode)", style: .default) { (action:UIAlertAction) in
                completion(station.StationDesc)
            }

            alertController.addAction(action)
        }

        viewControler.present(alertController, animated: true, completion: nil)
    }
}
