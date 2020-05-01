//
//  RailwayDataService.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 26.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation
import Combine
import GameKit

protocol DataService {
    func getAllStationsData(_ completion: @escaping (RailwaysResponse<[Station]>) -> Void) -> Void
    func getAllStationsData(withType type: IrishRailAPI.StationType, _ completion: @escaping (RailwaysResponse<[Station]>) -> Void)
    func getStationData(withName name: String, _ completion: @escaping (RailwaysResponse<[StationData]>) -> Void)
    func getStationData(withCode code: String, _ completion: @escaping (RailwaysResponse<[StationData]>) -> Void)
    func getStationData(withStaticString query: String, _ completion: @escaping (RailwaysResponse<[StationFilter]>) -> Void)
    
    func getCurrentTrains(_ completion: @escaping (RailwaysResponse<[TrainPosition]>) -> Void) -> Void
    func getCurrentTrains(withType type: IrishRailAPI.TrainType, _ completion: @escaping (RailwaysResponse<[TrainPosition]>) -> Void)
    func getTrainMovements(byId id: String, andDate date: String, _ completion: @escaping (RailwaysResponse<[TrainMovement]>) -> Void)

    func findTrainRoutesFrom(_ from: String, _ completion: @escaping (RailwaysResponse<[[TrainRoute]]>) -> Void)
    func findDirectionsFrom(_ origin: String, destination: String, forDirectRoute directRoute: Bool, _ completion: @escaping (RailwaysResponse<Route>) -> Void)

    func getAllTrainsMovementsFrom(_ from: String, _ completion: @escaping (RailwaysResponse<[[TrainMovement]]>) -> Void)
    
}

class RailwayDataService: NSObject, DataService, XMLParserDelegate {
    
    private let api: IrishRailAPI = IrishRailAPI()
    private var cancellable: AnyCancellable?
    private let stationsParserDelegate = RailwaysDataXMLParserDelegate(rootKey: "objStation", dictionaryKeys: ["StationDesc", "StationAlias", "StationLatitude", "StationLongitude", "StationCode", "StationId"])
    private let stationDataParserDelegate = RailwaysDataXMLParserDelegate(rootKey: "objStationData", dictionaryKeys: ["Servertime", "Traincode", "Stationfullname", "Stationcode", "Querytime", "Traindate", "Origin", "Destination", "Origintime", "Destinationtime", "Status", "Lastlocation", "Duein", "Late", "Exparrival", "Expdepart", "Scharrival", "Schdepart", "Direction", "Traintype", "Locationtype"])
    private let stationDataParserForFilteredDataDelegate = RailwaysDataXMLParserDelegate(rootKey: "objStationFilter", dictionaryKeys: ["StationDesc_sp", "StationDesc", "StationCode"])
    
    private let trainsParserDelegate = RailwaysDataXMLParserDelegate(rootKey: "objTrainPositions", dictionaryKeys: ["TrainStatus", "TrainLatitude", "TrainLongitude", "TrainCode", "TrainDate", "PublicMessage", "Direction"])
    private let trainMovementsParserDelegate = RailwaysDataXMLParserDelegate(rootKey: "objTrainMovements", dictionaryKeys: ["TrainCode", "TrainDate", "LocationCode", "LocationFullName", "LocationOrder", "LocationType", "TrainOrigin", "TrainDestination", "ScheduledArrival", "ScheduledDeparture", "ExpectedArrival", "ExpectedDeparture", "Arrival", "Departure", "AutoArrival", "AutoDepart", "StopType"])
    
    // MARK: Stations data
    
    func getAllStationsData(_ completion: @escaping (RailwaysResponse<[Station]>) -> Void) {
        guard let url = api.getURLForAllStations() else { return }
        
        getStationsWith(url: url, completion: completion)
    }
    
    func getAllStationsData(withType type: IrishRailAPI.StationType, _ completion: @escaping (RailwaysResponse<[Station]>) -> Void) {
        guard let url = api.getURLForAllStations(withType: type) else { return }
        
        getStationsWith(url: url, completion: completion)
    }
    
    func getStationData(withName name: String, _ completion: @escaping (RailwaysResponse<[StationData]>) -> Void) {
        guard let url = api.getStationData(withName: name) else { return }
        
        getDataArrayWith(url: url, andParserDelegate: self.stationDataParserDelegate, completion: completion)
    }
    
    func getStationData(withCode code: String, _ completion: @escaping (RailwaysResponse<[StationData]>) -> Void) {
        guard let url = api.getStationData(withCode: code) else { return }
        
        getDataArrayWith(url: url, andParserDelegate: self.stationDataParserDelegate, completion: completion)
    }
    
    func getStationData(withStaticString query: String, _ completion: @escaping (RailwaysResponse<[StationFilter]>) -> Void) {
        guard let url = api.getStationData(withStaticString: query) else { return }
        
        getDataArrayWith(url: url, andParserDelegate: self.stationDataParserForFilteredDataDelegate, completion: completion)
    }
    
    // MARK: Trains data
    
    func getCurrentTrains(_ completion: @escaping (RailwaysResponse<[TrainPosition]>) -> Void) {
        guard let url = api.getCurrentTrains() else { return }
        
        getDataArrayWith(url: url, andParserDelegate: trainsParserDelegate, completion: completion)
    }
    
    func getCurrentTrains(withType type: IrishRailAPI.TrainType, _ completion: @escaping (RailwaysResponse<[TrainPosition]>) -> Void) {
        guard let url = api.getCurrentTrains(withType: type) else { return }
        
        getDataArrayWith(url: url, andParserDelegate: trainsParserDelegate, completion: completion)
    }
    
    func getTrainMovements(byId id: String, andDate date: String, _ completion: @escaping (RailwaysResponse<[TrainMovement]>) -> Void) {
        guard let url = api.getTrainMovements(byId: id, andDate: date) else { return }
        
        getDataArrayWith(url: url, andParserDelegate: trainMovementsParserDelegate, completion: completion)
    }

    // MARK: Directions

    // TODO: rename all Direction to Route

    private func isRoute(_ route: TrainRoute, forDestination destination: String) -> Bool {
//        return route.to == "Howth" // TODO: for testing with direct route, replace with `destination`
        return route.destinationCode == destination
    }

    private func getNotesFromRoutes(_ routes: [TrainRoute], inDict dict: [StationGraphNode]) -> [StationGraphNode] {
        var routeNodes = [StationGraphNode]()
        for route in routes {
            if let routeNode = dict.first(where: { $0.code == route.destinationCode }) {
                routeNodes.append(routeNode)
            }
        }

        return routeNodes
    }

    private func getRoutesFromNodes(_ nodes: [StationGraphNode], inSourceNodes sourceNodes: [StationGraphNode], andRoutes routes: [TrainRoute]) -> [TrainRoute] {
        var routeNodes = [TrainRoute]()
        for node in nodes {
            if let currentNode: StationGraphNode = sourceNodes.first(where: { $0 == node }) {
                let route = routes.first { $0.originCode == currentNode.code }
                if let route = route {
                    routeNodes.append(route)
                }
            }
        }

        return routeNodes
    }

    func findRouteWithGraphFor(routes: [[TrainRoute]], andOrigin originCode: String, andDestination destinationCode: String) -> Route {
        let flattenRoutes = routes.flatMap { $0 }
        var allStationCodes = [String]()
        for direction in flattenRoutes {
            allStationCodes.append(direction.destinationCode)
            allStationCodes.append(direction.originCode)
        }

        var allNodes = [StationGraphNode]()
        let uniqueStationCodes = Array(Set(allStationCodes))
        for stationCode in uniqueStationCodes {
            allNodes.append(StationGraphNode(code: stationCode))
        }

        for stationCode in uniqueStationCodes {
            let currentNode = allNodes.first { $0.code == stationCode }
            if let currentNode = currentNode {
                let connectionRoutes = flattenRoutes.filter { $0.originCode == stationCode }
                let connectionNodes = getNotesFromRoutes(connectionRoutes, inDict: allNodes)
                currentNode.addConnections(to: connectionNodes, bidirectional: false)

                let currentNodeIndex = allNodes.firstIndex(of: currentNode)
                if let currentNodeIndex = currentNodeIndex {
                    allNodes[currentNodeIndex] = currentNode
                }
            }
        }

        let mapGraph = GKGraph()
        mapGraph.add(allNodes)

        let originNode = allNodes.first { $0.code == originCode }
        let destinationNode = allNodes.first { $0.code == destinationCode }
        var foundRoute: [TrainRoute] = []
        if let originNode = originNode, let destinationNode = destinationNode {
            let path = mapGraph.findPath(from: originNode, to: destinationNode)
            let pathStationNodes =  path.map { $0 as! StationGraphNode }
            foundRoute = getRoutesFromNodes(pathStationNodes, inSourceNodes: allNodes, andRoutes: flattenRoutes)
        }

        return Route(directions: foundRoute, isDirect: false, origin: originCode, destination: destinationCode)
    }

    private func findRouteFor(origin: String, andDestination destiantion: String, withTrainRoutes trainRoutes: [[TrainRoute]], andDirectRoute directRoute: Bool) -> Route {
        var tripRoute = Route(directions: [], isDirect: false, origin: origin, destination: destiantion)

        // Lookup in direct routes
        var currentTrainRoutes = [TrainRoute]()
        var foundTrainRoute = false
        var isDirectRoute = false
        for innerTrainRoute in trainRoutes {
            for directDirection in innerTrainRoute {
                if directDirection.originCode == origin || currentTrainRoutes.count != 0 {
                    currentTrainRoutes.append(directDirection)
                }

                if isRoute(directDirection, forDestination: destiantion) && currentTrainRoutes.count != 0 {
                    foundTrainRoute = true
                    isDirectRoute = true
                    break
                }
            }

            if foundTrainRoute {
                break
            } else {
                currentTrainRoutes = [TrainRoute]()
            }
        }

        if foundTrainRoute && directRoute {
            tripRoute.directions = currentTrainRoutes
            tripRoute.isDirect = isDirectRoute

            return tripRoute
        } else {
            tripRoute = findRouteWithGraphFor(routes: trainRoutes, andOrigin: origin, andDestination: destiantion)
        }

        return tripRoute
    }

    func findDirectionsFrom(_ origin: String, destination: String, forDirectRoute directRoute: Bool, _ completion: @escaping (RailwaysResponse<Route>) -> Void) {
        getStationData(withName: origin) { stationResponse in
            let tempTrainRoute: Route = Route(directions: [], isDirect: false, origin: origin, destination: destination)
            let response = RailwaysResponse<Route>(data: tempTrainRoute)

            guard let originStationCode = stationResponse.data?.first?.Stationcode else {
                let error = RaiwayResponseError(title: "Error getting station data", description: "Station data for \(origin) cannot be found.", code: 1)
                response.error = error
                completion(response)
                return
            }

            self.getStationData(withName: destination) { stationResponse in
                guard let destinationStationCode = stationResponse.data?.first?.Stationcode else {
                    let error = RaiwayResponseError(title: "Error getting station data", description: "Station data for \(destination) cannot be found.", code: 1)
                    response.error = error
                    completion(response)
                    return
                }

                self.findTrainRoutesFrom(originStationCode) { receivedData in

                    guard let trainRoutes = receivedData.data else {
                        response.data = nil
                        response.error = receivedData.error
                        completion(response)
                        return
                    }

                    let data = self.findRouteFor(origin: originStationCode, andDestination: destinationStationCode, withTrainRoutes: trainRoutes, andDirectRoute: directRoute)
                    let trainRoute: Route = Route(directions: data.directions, isDirect: data.isDirect, origin: origin, destination: destination)
                    response.data = trainRoute
                    response.error = nil
                    completion(response)
                }
            }
        }
    }

    func findTrainRoutesFrom(_ from: String, _ completion: @escaping (RailwaysResponse<[[TrainRoute]]>) -> Void) {
        getAllTrainsMovementsFrom(from) { receivedData in
            let trainsMovements = [[TrainRoute]]()
            let response = RailwaysResponse<[[TrainRoute]]>(data: trainsMovements)
            guard let trains = receivedData.data else {
                response.data = nil
                response.error = receivedData.error
                completion(response)
                return
            }

            var trainDirections = [[TrainRoute]]()
            for trainMovements in trains {
                var currentTrainDirections = [TrainRoute]()
                for (index, movment) in trainMovements.enumerated() {
                    var nextMovement: TrainMovement? = nil
                    let nextIndex = index + 1
                    if nextIndex < trainMovements.count {
                        nextMovement = trainMovements[nextIndex]
                    }

                    let direction = TrainRoute(originCode: movment.LocationCode , destinationCode: nextMovement?.LocationCode ?? movment.TrainDestination, originName: movment.LocationFullName, destinationName: nextMovement?.LocationFullName ?? movment.TrainDestination, trainCode: movment.TrainCode, time: movment.ExpectedArrival, isDirect: false)
                    currentTrainDirections.append(direction)
                }

                trainDirections.append(currentTrainDirections)
            }

            response.data = trainDirections
            response.error = nil
            completion(response)
        }
    }

    func getAllTrainsMovementsFrom(_ from: String, _ completion: @escaping (RailwaysResponse<[[TrainMovement]]>) -> Void) {
        getStationData(withCode: from) { receivedData in
            let trainsMovements = [[TrainMovement]]()
            let response = RailwaysResponse<[[TrainMovement]]>(data: trainsMovements)
            guard let data = receivedData.data, data.count > 0 else {
                response.data = nil
                response.error = receivedData.error
                completion(response)
                return
            }

            let firstSrtation = data[0]
            self.getTrainMovementsRecursive(byId: firstSrtation.Traincode, andDate: firstSrtation.Traindate, andResultData: [[TrainMovement]](), andSourceData: data) { trainMovemenetsData in
                response.data = trainMovemenetsData
                response.error = nil
                completion(response)
            }
        }
    }

    private func getTrainMovementsRecursive(byId id: String, andDate date: String, andResultData resultData: [[TrainMovement]], andSourceData sourceData: [StationData],_ completion: @escaping ([[TrainMovement]]) -> Void) {
        self.getTrainMovements(byId: id, andDate: date) { trainData in
            guard let currentTrainData = trainData.data else { return }
            var newResult = resultData
            newResult.append(currentTrainData)

            let nextIndex = resultData.count
            if nextIndex < sourceData.count {
                let direction = sourceData[nextIndex]
                self.getTrainMovementsRecursive(byId: direction.Traincode, andDate: direction.Traindate, andResultData: newResult, andSourceData: sourceData, completion)
            } else {
                completion(resultData)
            }
        }
    }
    
    // MARK: Helper functions
    
    // TODO: rmeove
    private func getStationsWith(url: URL, completion: @escaping (RailwaysResponse<[Station]>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            let response = RailwaysResponse<[Station]>(data: nil)
            
            guard let data = data, error == nil else {
                response.error = error
                return
            }
            
            let parser = XMLParser(data: data)
            parser.delegate = self.stationsParserDelegate
            var stations: [Station] = []
            if parser.parse() {
                if let result = self.stationsParserDelegate.getResult() {
                    for stationDict in result {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: stationDict, options: .prettyPrinted)
                            let station = try JSONDecoder().decode(Station.self, from: jsonData)
                            
                            stations.append(station)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    
                }
            }
 
            response.data = stations
            
            completion(response)
        }
        
        task.resume()
    }
 
    private func getDataObjectWith<T: Codable>(url: URL, andParserDelegate parserDelegate: RailwaysDataXMLParserDelegate , completion: @escaping (RailwaysResponse<T>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            let response = RailwaysResponse<T>(data: nil)
            
            guard let data = data, error == nil else {
                response.error = error
                return
            }
            
            let parser = XMLParser(data: data)
            parser.delegate = parserDelegate
            var stationData: T? = nil
            if parser.parse() {
                if let result = parserDelegate.getResult() {
                    for stationDict in result {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: stationDict, options: .prettyPrinted)
                            stationData = try JSONDecoder().decode(T.self, from: jsonData)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    
                }
            }
            
            response.data = stationData
            
            completion(response)
        }
        
        task.resume()
    }
    
    private func getDataArrayWith<T: Codable>(url: URL, andParserDelegate parserDelegate: RailwaysDataXMLParserDelegate , completion: @escaping (RailwaysResponse<[T]>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            let response = RailwaysResponse<[T]>(data: nil)
            
            guard let data = data, error == nil else {
                response.error = error
                return
            }
            
            let parser = XMLParser(data: data)
            parser.delegate = parserDelegate
            var stationsData: [T]? = []
            if parser.parse() {
                if let result = parserDelegate.getResult() {
                    for stationDict in result {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: stationDict, options: .prettyPrinted)
                            let stationData = try JSONDecoder().decode(T.self, from: jsonData)
                            
                            stationsData?.append(stationData)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    
                }
            }
            
            response.data = stationsData
            
            completion(response)
        }
        
        task.resume()
    }
}
