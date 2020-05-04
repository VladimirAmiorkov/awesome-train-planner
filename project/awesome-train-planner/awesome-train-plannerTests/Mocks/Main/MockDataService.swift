//
//  MockDataService.swift
//  awesome-train-plannerTests
//
//  Created by Vladimir Amiorkov on 4.05.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation
@testable import Awesome_train_planner

class MockDataService: DataService {
    
    func getAllStationsData(_ completion: @escaping (RailwaysResponse<[Station]>) -> Void) {

    }

    func getAllStationsData(withType type: IrishRailAPI.StationType, _ completion: @escaping (RailwaysResponse<[Station]>) -> Void) {

    }

    func getStationData(withName name: String, _ completion: @escaping (RailwaysResponse<[StationData]>) -> Void) {

    }

    func getStationData(withCode code: String, _ completion: @escaping (RailwaysResponse<[StationData]>) -> Void) {

    }

    func getStationData(withStaticString query: String, _ completion: @escaping (RailwaysResponse<[StationFilter]>) -> Void) {

    }

    func getCurrentTrains(_ completion: @escaping (RailwaysResponse<[TrainPosition]>) -> Void) {

    }

    func getCurrentTrains(withType type: IrishRailAPI.TrainType, _ completion: @escaping (RailwaysResponse<[TrainPosition]>) -> Void) {

    }

    func getTrainMovements(byId id: String, andDate date: String, _ completion: @escaping (RailwaysResponse<[TrainMovement]>) -> Void) {

    }

    func findTrainRoutesFrom(_ from: String, _ completion: @escaping (RailwaysResponse<[[TrainRoute]]>) -> Void) {

    }

    func findDirectionsFrom(_ origin: String, andDestination: String, _ completion: @escaping (RailwaysResponse<Route>) -> Void) {

    }

    func getAllTrainsMovementsFrom(_ from: String, _ completion: @escaping (RailwaysResponse<[[TrainMovement]]>) -> Void) {

    }

    func mockFindDirectionsFrom(_ origin: String, andDestination: String, _ completion: @escaping (RailwaysResponse<Route>) -> Void) {

    }
}
