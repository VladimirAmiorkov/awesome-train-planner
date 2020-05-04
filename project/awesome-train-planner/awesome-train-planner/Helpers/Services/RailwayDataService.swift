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

    // TODO: Consider removing the `forDirectRoute directRoute: Bool` param as it is should not be needed. Only here for testing poath finding.
    func findDirectionsFrom(_ origin: String, andDestination: String, forDirectRoute directRoute: Bool, _ completion: @escaping (RailwaysResponse<Route>) -> Void)

    func getAllTrainsMovementsFrom(_ from: String, _ completion: @escaping (RailwaysResponse<[[TrainMovement]]>) -> Void)

    // MARK: Mocks, remove this ASAP, only here for testing uding times when there are no enough trains in live data
    func mockFindDirectionsFrom(_ origin: String, andDestination: String, forDirectRoute directRoute: Bool, _ completion: @escaping (RailwaysResponse<Route>) -> Void)
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
        for (index, node) in nodes.enumerated() {
            if let currentNode: StationGraphNode = sourceNodes.first(where: { $0 == node }) {
                // TODO: check which train goes from currentNode.code to next node
                let nextIndex = index + 1
                if nextIndex < nodes.count {
                    let nextNote = nodes[index + 1]
                    let route = routes.first { $0.originCode == currentNode.code && $0.destinationCode == nextNote.code }
                    if let route = route {
                        routeNodes.append(route)
                    }
                }
            }
        }

        return routeNodes
    }

    func findRouteWithGraphFor(routes: [TrainRoute], andOrigin originCode: String, andDestination destinationCode: String) -> Route {
        let originCaseInsensitive = originCode.uppercased()
        let destinationCaseInsensitive = destinationCode.uppercased()
        var allStationCodes = [String]()
        for direction in routes {
            allStationCodes.append(direction.destinationCode.uppercased())
            allStationCodes.append(direction.originCode.uppercased())
        }

        let mapGraph = GKGraph()
        var allNodes = [StationGraphNode]()
        let uniqueStationCodes = Array(Set(allStationCodes))
        for stationCode in uniqueStationCodes {
            allNodes.append(StationGraphNode(code: stationCode))
        }

        mapGraph.add(allNodes)

        // TODO: Maybe this is not correct
        for stationCode in uniqueStationCodes {
            let currentNode = allNodes.first { $0.code == stationCode }
            if let currentNode = currentNode {
                var connectionRoutes = routes.filter { $0.originCode == stationCode }

                // Remove redundant connection (the destination is represented as note from X to X)
                connectionRoutes = connectionRoutes.filter { $0.originCode != $0.destinationCode }

                let connectionNodes = getNotesFromRoutes(connectionRoutes, inDict: allNodes)

                // Note, we limit the connections to only 1 train.
                // TODO: Create multiple `GKGraph` to handle multiple trains case
                let uniqueconnectionNodes = Array(Set(connectionNodes))
                currentNode.addConnections(to: uniqueconnectionNodes, bidirectional: false)

                let currentNodeIndex = allNodes.firstIndex(of: currentNode)
                if let currentNodeIndex = currentNodeIndex {
                    allNodes[currentNodeIndex] = currentNode
                }
            }
        }

        let originNode = allNodes.first { $0.code == originCaseInsensitive }
        let destinationNode = allNodes.first { $0.code == destinationCaseInsensitive }

        var foundRoute: [TrainRoute] = []
        if let originNode = originNode, let destinationNode = destinationNode {
            foundRoute = getRouteFromGraph(mapGraph, fromOriginNode: originNode, toDestinationNode: destinationNode, inNodes: allNodes, andRoutes: routes)

            var lastRouteDate: Date? = nil
            var overdueRoute: TrainRoute? = nil
            for route in foundRoute {
                // TODO: (refactor) See if we cant retrive the "date" value from the APis, currently uses today as the `yyyy-MM-dd` part of the date, which is correect
                // because here all of the train movements are already for the cyrrent day
                let dateString = Date().string(format: "yyyy-MM-dd")
                let dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = dateFormat

                let routeDate = dateFormatter.date(from: "\(dateString) \(route.time)")

                if let routeDate = routeDate {
                    if let lastRouteDate = lastRouteDate {
                        if routeDate < lastRouteDate {
                            overdueRoute = route
                            break
                        }
                    }

                    lastRouteDate = routeDate
                }
            }

            if let overdueRoute = overdueRoute {
                let newRoutes = routes.filter { $0 != overdueRoute }

                return findRouteWithGraphFor(routes: newRoutes, andOrigin: originCode, andDestination: destinationCode)
            }
        }

        return Route(directions: foundRoute, isDirect: false, origin: originCode, destination: destinationCode)
    }

    private func getRouteFromGraph(_ graph: GKGraph, fromOriginNode originNode: StationGraphNode, toDestinationNode destinationNode: StationGraphNode, inNodes nodes: [StationGraphNode], andRoutes routes: [TrainRoute]) -> [TrainRoute]{
        var foundRoute: [TrainRoute] = []
        let path = graph.findPath(from: originNode, to: destinationNode)
        let pathStationNodes =  path.map { $0 as! StationGraphNode }
        foundRoute = getRoutesFromNodes(pathStationNodes, inSourceNodes: nodes, andRoutes: routes)

        return foundRoute
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
            let flattenRoutes = trainRoutes.flatMap { $0 }
            tripRoute = findRouteWithGraphFor(routes: flattenRoutes, andOrigin: origin, andDestination: destiantion)
        }

        return tripRoute
    }

    func findDirectionsFrom(_ origin: String, andDestination: String, forDirectRoute directRoute: Bool, _ completion: @escaping (RailwaysResponse<Route>) -> Void) {
        let originCaseInsensitive = origin.lowercased()
        let destinationCaseInsensitive = andDestination.lowercased()

        getAllStationsData(){ stationResponse in
            let tempTrainRoute: Route = Route(directions: [], isDirect: false, origin: origin, destination: andDestination)
            let response = RailwaysResponse<Route>(data: tempTrainRoute)

            if let data = stationResponse.data {
                let originStationData = data.first { $0.stationDescCaseInsensitive == originCaseInsensitive }
                let destinationStationData = data.first { $0.stationDescCaseInsensitive == destinationCaseInsensitive }

                guard var originStationCode = originStationData?.StationCode, var destinationStationCode = destinationStationData?.StationCode else {
                    let error = RaiwayResponseError(title: "Error getting station data", description: "Station data for \(origin) cannot be found.", code: 1)
                    response.error = error
                    completion(response)

                    return
                }

                // Note: For some reason the API sometimes returns codes with empty trailing characters, we trim them to be able to use this with other APis
                originStationCode = originStationCode.trimmingCharacters(in: .whitespacesAndNewlines)
                destinationStationCode = destinationStationCode.trimmingCharacters(in: .whitespacesAndNewlines)

                self.findTrainRoutesFrom(originStationCode) { receivedData in

                    guard let trainRoutes = receivedData.data else {
                        response.data = nil
                        response.error = receivedData.error
                        completion(response)
                        return
                    }

                    let data = self.findRouteFor(origin: originStationCode, andDestination: destinationStationCode, withTrainRoutes: trainRoutes, andDirectRoute: directRoute)
                    let trainRoute: Route = Route(directions: data.directions, isDirect: data.isDirect, origin: origin, destination: andDestination)
                    response.data = trainRoute
                    response.error = nil
                    completion(response)
                }
            }
        }
    }

    func findTrainRoutesFrom(_ from: String, _ completion: @escaping (RailwaysResponse<[[TrainRoute]]>) -> Void) {
        getAllTrainsMovementsFrom(from) { receivedData in
            self.processData(receivedData, completion)
        }
    }

    private  func processData(_ receivedData: RailwaysResponse<[[TrainMovement]]>, _ completion: @escaping (RailwaysResponse<[[TrainRoute]]>) -> Void) {
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

    func getAllTrainsMovementsFrom(_ from: String, _ completion: @escaping (RailwaysResponse<[[TrainMovement]]>) -> Void) {
        getCurrentTrains() { receivedData in
            let trainsMovements = [[TrainMovement]]()
            let response = RailwaysResponse<[[TrainMovement]]>(data: trainsMovements)
            guard let data = receivedData.data, data.count > 0 else {
                response.data = nil
                response.error = receivedData.error
                completion(response)
                return
            }

            if let firstPosition = data.first {
                self.getTrainMovementsRecursive(byId: firstPosition.TrainCode, andDate: firstPosition.TrainDate, andResultData: [[TrainMovement]](), andSourceData: data) { trainMovemenetsData in
                    response.data = trainMovemenetsData
                    response.error = nil
                    completion(response)
                }
            }
        }
    }

    private func getTrainMovementsRecursive(byId id: String, andDate date: String, andResultData resultData: [[TrainMovement]], andSourceData sourceData: [TrainPosition],_ completion: @escaping ([[TrainMovement]]) -> Void) {
        self.getTrainMovements(byId: id, andDate: date) { trainData in
            guard let currentTrainData = trainData.data else { return }
            var newResult = resultData
            newResult.append(currentTrainData)

            let nextIndex = resultData.count
            if nextIndex < sourceData.count {
                let trainPosition = sourceData[nextIndex]
                self.getTrainMovementsRecursive(byId: trainPosition.TrainCode, andDate: trainPosition.TrainDate, andResultData: newResult, andSourceData: sourceData, completion)
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



    // MARK: Mocks, remove this ASAP, only here for testing uding times when there are no enough trains in live data

    func mockFindDirectionsFrom(_ origin: String, andDestination: String, forDirectRoute directRoute: Bool, _ completion: @escaping (RailwaysResponse<Route>) -> Void) {
        let originCaseInsensitive = origin.lowercased()
        let destinationCaseInsensitive = andDestination.lowercased()

        mockFindTrainRoutesFrom(originCaseInsensitive) { receivedData in
            let tempTrainRoute: Route = Route(directions: [], isDirect: false, origin: origin, destination: andDestination)
            let response = RailwaysResponse<Route>(data: tempTrainRoute)

            guard let trainRoutes = receivedData.data else {
                response.data = nil
                response.error = receivedData.error
                completion(response)
                return
            }

            let data = self.findRouteFor(origin: originCaseInsensitive, andDestination: destinationCaseInsensitive, withTrainRoutes: trainRoutes, andDirectRoute: directRoute)
            let trainRoute: Route = Route(directions: data.directions, isDirect: data.isDirect, origin: origin, destination: andDestination)
            response.data = trainRoute
            response.error = nil
            completion(response)
        }
    }

    private func mockFindTrainRoutesFrom(_ from: String, _ completion: @escaping (RailwaysResponse<[[TrainRoute]]>) -> Void) {
        let response = RailwaysResponse<[[TrainMovement]]>(data: self.trainMovementsMock())
        self.processData(response, completion)
    }

    private func trainMovementsMock() -> [[TrainMovement]] {
        // Assumes arrival and departure of trains is 1 hour apart
        // 00:00:00 means that there is not time set
        let todaytDate = "3 May 2020"
        let stationCodes = ["A", "B", "C", "Z"]

        var trainMovements = [[TrainMovement]]()
        var trainMovementsLineTrain1 = [TrainMovement]()

        // Train 1 A
        var currentStationCode = stationCodes[0] // A
        var currentDestinationCode = stationCodes[2] // C
        let train1Movmement1 = TrainMovement(TrainCode: "Train 1", TrainDate: todaytDate, LocationCode: currentStationCode, LocationFullName: "\(currentStationCode) name", LocationOrder: "1", LocationType: "location type", TrainOrigin: stationCodes[0], TrainDestination: currentDestinationCode, ScheduledArrival: "10:00:00", ScheduledDeparture: "11:00:00", ExpectedArrival: "10:00:01", ExpectedDeparture: "11:00:01", Arrival: "", Departure: "", AutoArrival: "", AutoDepart: "", StopType: "stop type")
        trainMovementsLineTrain1.append(train1Movmement1)

        // Train 1 B
        currentStationCode = stationCodes[1] // B
        let train1Movmement2 = TrainMovement(TrainCode: "Train 1", TrainDate: todaytDate, LocationCode: currentStationCode, LocationFullName: "\(currentStationCode) name", LocationOrder: "2", LocationType: "location type", TrainOrigin: stationCodes[0], TrainDestination: currentDestinationCode, ScheduledArrival: "12:00:00", ScheduledDeparture: "13:00:00", ExpectedArrival: "12:00:01", ExpectedDeparture: "13:00:01", Arrival: "", Departure: "", AutoArrival: "", AutoDepart: "", StopType: "stop type")
        trainMovementsLineTrain1.append(train1Movmement2)

        // Train 1 C
        currentStationCode = stationCodes[2] // C
        let train1Movmement3 = TrainMovement(TrainCode: "Train 1", TrainDate: todaytDate, LocationCode: currentStationCode, LocationFullName: "\(currentStationCode) name", LocationOrder: "2", LocationType: "location type", TrainOrigin: stationCodes[0], TrainDestination: currentDestinationCode, ScheduledArrival: "14:00:00", ScheduledDeparture: "00:00:00", ExpectedArrival: "14:00:01", ExpectedDeparture: "00:00:00", Arrival: "", Departure: "", AutoArrival: "", AutoDepart: "", StopType: "stop type")
        trainMovementsLineTrain1.append(train1Movmement3)

        trainMovements.append(trainMovementsLineTrain1)

        // Train 2 B
        var trainMovementsLineTrain2 = [TrainMovement]()

        currentStationCode = stationCodes[1] //B
        currentDestinationCode = stationCodes[3] // Z
        var expectedArrival = "12:30:01" // 12:30:01 value, 09:30:01 invalud (overdue hour)
        let train2Movmement1 = TrainMovement(TrainCode: "train 2", TrainDate: todaytDate, LocationCode: currentStationCode, LocationFullName: "\(currentStationCode) name", LocationOrder: "1", LocationType: "location type", TrainOrigin: stationCodes[1], TrainDestination: currentDestinationCode, ScheduledArrival: "12:30:00", ScheduledDeparture: "13:00:00", ExpectedArrival: expectedArrival, ExpectedDeparture: "13:00:01", Arrival: "", Departure: "", AutoArrival: "", AutoDepart: "", StopType: "stop type")
        trainMovementsLineTrain2.append(train2Movmement1)

        trainMovements.append(trainMovementsLineTrain2)

        // Train 3 C
        var trainMovementsLineTrain3 = [TrainMovement]()

        currentStationCode = stationCodes[2] //C
        currentDestinationCode = stationCodes[3] // Z
        expectedArrival = "14:30:01" // 14:30:01 value, 09:30:01 invalud (overdue hour)
        let train3Movmement1 = TrainMovement(TrainCode: "train 3", TrainDate: todaytDate, LocationCode: currentStationCode, LocationFullName: "\(currentStationCode) name", LocationOrder: "1", LocationType: "location type", TrainOrigin: stationCodes[2], TrainDestination: currentDestinationCode, ScheduledArrival: "12:30:00", ScheduledDeparture: "13:00:00", ExpectedArrival: expectedArrival, ExpectedDeparture: "13:00:01", Arrival: "", Departure: "", AutoArrival: "", AutoDepart: "", StopType: "stop type")
        trainMovementsLineTrain3.append(train3Movmement1)

        trainMovements.append(trainMovementsLineTrain3)

        return trainMovements
    }
}
