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

    func findDirectionsFrom(_ from: String, _ completion: @escaping (RailwaysResponse<[[Direction]]>) -> Void)
    func findDirectionsFrom(_ from: String, destination: String, _ completion: @escaping (RailwaysResponse<Route>) -> Void)

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

    private func isRoute(_ route: Direction, forDestination destination: String) -> Bool {
//        return route.to == "Howth" // TODO: for testing with direct route, replace with `destination`
        return route.to == destination
    }

    private func getNotesFromRoutes(_ routes: [Direction], inDict dict: [String: GKGraphNode]) -> [GKGraphNode] {
        var routeNodes = [GKGraphNode]()
        for route in routes {
            if let routeNode = dict[route.hashcode] {
                routeNodes.append(routeNode)
            }
        }

        return routeNodes
    }

    private func getRoutesFromNodes(_ nodes: [GKGraphNode], inDict dict: [String: GKGraphNode], andRoutes routes: [Direction]) -> [Direction] {
        var routeNodes = [Direction]()
        for node in nodes {
            let nodeHashcode: String = (dict as NSDictionary).allKeys(for: node).first as! String
            let route = routes.first { $0.hashcode == nodeHashcode }
            if let route = route {
                routeNodes.append(route)
            }
        }

        return routeNodes
    }

    func findRouteWithGraphFor(directions: [[Direction]], andOrigin origin: String, andDestination destination: String) -> Route {
        let flattenDirections = directions.flatMap { $0 }

        var nodesDict: [String: GKGraphNode] = [String: GKGraphNode]()
        for direction in flattenDirections {
            nodesDict[direction.hashcode] = GKGraphNode()
        }

        for direction in flattenDirections {
            let connectionDirections = flattenDirections.filter { $0.from == direction.to }

            let connectionNodes = getNotesFromRoutes(connectionDirections, inDict: nodesDict)
            let currentNode = nodesDict[direction.hashcode]
            currentNode?.addConnections(to: connectionNodes, bidirectional: false)
            if let currentNode = currentNode {
                nodesDict.updateValue(currentNode, forKey: direction.hashcode)
            }
        }


        let nodes = nodesDict.map { $0.1 }
        let mapGraph = GKGraph()
        mapGraph.add(nodes)

        let originDirections = flattenDirections.filter { $0.from == origin }
        let detinationDirections = flattenDirections.filter { $0.to == destination }

        let origonNodes = getNotesFromRoutes(originDirections, inDict: nodesDict)
        let destinationNodes = getNotesFromRoutes(detinationDirections, inDict: nodesDict)

        let fromAndToNodesTuple = zip(origonNodes, destinationNodes).map { ($0, $1) }

        var foundPaths: [[GKGraphNode]] = [[GKGraphNode]]()
        for tuple in fromAndToNodesTuple {
            foundPaths.append(mapGraph.findPath(from: tuple.0, to: tuple.1))
        }

        var routes: [[Direction]] = [[Direction]]()
        for path in foundPaths {
            routes.append(getRoutesFromNodes(path, inDict: nodesDict, andRoutes: flattenDirections))
        }

        // TODO: extend to determine the best route from the `routes`. Currently uses the first one which is not sorted in anyway.
        var foundRoute: [Direction] = []
        if let firstRoute = routes.first {
            foundRoute = firstRoute
        }

        return Route(directions: foundRoute, isDirect: false, origin: origin, destination: destination)
    }

    private func findRouteFor(origin: String, andDestination destiantion: String, withDirections directions: [[Direction]]) -> Route {
        var foundDirection = false
        var tripRoute = Route(directions: [], isDirect: false, origin: origin, destination: destiantion)

        // Lookup in direct routes
        var currentDirections = [Direction]()
        var isDirectRoute = false
//        for innerDirection in directions {
//            for directDirection in innerDirection {
//                if directDirection.from == origin || currentDirections.count != 0 {
//                    currentDirections.append(directDirection)
//                }
//
//                if isRoute(directDirection, forDestination: destiantion) && currentDirections.count != 0 {
//                    foundDirection = true
//                    isDirectRoute = true
//                    break
//                }
//            }
//
//            if foundDirection {
//                break
//            } else {
//                currentDirections = [Direction]()
//            }
//        }

        if foundDirection {
            tripRoute.directions = currentDirections
            tripRoute.isDirect = isDirectRoute

            return tripRoute
        } else {
            tripRoute = findRouteWithGraphFor(directions: directions, andOrigin: origin, andDestination: destiantion)
        }

        // TODO: use A Start algorothum

        return tripRoute
    }

    func findDirectionsFrom(_ origin: String, destination: String, _ completion: @escaping (RailwaysResponse<Route>) -> Void) {
        getStationData(withStaticString: origin) { stationResponse in
            let tempTrainRoute: Route = Route(directions: [], isDirect: false, origin: origin, destination: destination)
            let response = RailwaysResponse<Route>(data: tempTrainRoute)

            guard let originStationCode = stationResponse.data?.first?.StationCode else {
                completion(response)
                return
            }

            self.getStationData(withStaticString: destination) { stationResponse in
                guard let destinationStationCode = stationResponse.data?.first?.StationCode else {
                    completion(response)
                    return
                }

                self.findDirectionsFrom(originStationCode) { receivedData in

                    guard let trainDirections = receivedData.data else {
                        response.data = nil
                        response.error = receivedData.error
                        completion(response)
                        return
                    }

                    let data = self.findRouteFor(origin: originStationCode, andDestination: destinationStationCode, withDirections: trainDirections)
                    let trainRoute: Route = Route(directions: data.directions, isDirect: data.isDirect, origin: origin, destination: destination)
                    response.data = trainRoute
                    response.error = nil
                    completion(response)
                }
            }
        }
    }

    func findDirectionsFrom(_ from: String, _ completion: @escaping (RailwaysResponse<[[Direction]]>) -> Void) {
        getAllTrainsMovementsFrom(from) { receivedData in
            let trainsMovements = [[Direction]]()
            let response = RailwaysResponse<[[Direction]]>(data: trainsMovements)
            guard let trains = receivedData.data else {
                response.data = nil
                response.error = receivedData.error
                completion(response)
                return
            }

            var trainDirections = [[Direction]]()
            for trainMovements in trains {
                var currentTrainDirections = [Direction]()
                for (index, movment) in trainMovements.enumerated() {
                    var nextMovement: TrainMovement? = nil
                    let nextIndex = index + 1
                    if nextIndex < trainMovements.count {
                        nextMovement = trainMovements[nextIndex]
                    }

                    let direction = Direction(from: movment.LocationCode , to: nextMovement?.LocationCode ?? movment.TrainDestination, trainCode: movment.TrainCode, time: movment.ExpectedArrival, isDirect: false)
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
