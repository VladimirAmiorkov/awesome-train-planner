//
//  IrishRailAPI.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 26.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation

/// Usage, append any of the with the `baseURL`
struct IrishRailAPI {
    
    // MARK: Types
    let trainTypeAll = "A"
    let trainTypeMainline = "M"
    let trainTypeSuburban = "S"
    let trainTypeDART = "D"
    let statuionTypeAll = "A"
    let statuionTypeMainline = "M"
    let statuionTypeSuburban = "S"
    let statuionTypeDART = "D"
    
    
    // MARK: Stations APIs
    private let getAllStationsPath = "/getAllStationsXML" // Example: http://api.irishrail.ie/realtime/realtime.asmx/getAllStationsXML
    private let getAllStationsURLWithTypePath = "/getAllStationsXML_WithStationType" // accepts a single param, `stationTypeParam`. Example: http://api.irishrail.ie/realtime/realtime.asmx/getAllStationsXML_WithStationType?StationType=D
    private let getStationDataByNamePath = "/getStationDataByNameXML" // accepts a single param, `stationDescriptionParam`. Example: private http://api.irishrail.ie/realtime/realtime.asmx/getStationDataByNameXML?StationDesc=Bayside
    private let getStationDataByNameAndTimeSpanPath = "/getStationDataByNameXML" // accepts two params, `stationDescriptionParam` and `minutesParam`. Example: http://api.irishrail.ie/realtime/realtime.asmx/getStationDataByNameXML_withNumMins?StationDesc=Bayside&NumMins=20
    private let getStationDataByCodePath = "/getStationDataByCodeXML" // accepts a single param, `stationCodeParam`. Example: http://api.irishrail.ie/realtime/realtime.asmx/getStationDataByCodeXML?StationCode=mhide
    private let getStationDataByCodeAndTimeSpanPath = "/getStationDataByCodeXML_WithNumMins" // accepts two params, `stationCodeParam` and `minutesParam`. private Example:
    private let getFilteredStationDataByStringPath = "/getStationsFilterXML" // accepts a single param, `staticTextParam`. Example: http://api.irishrail.ie/realtime/realtime.asmx/getStationDataByCodeXML_WithNumMins?StationCode=mhide&NumMins=20
    
    private func getBaseURLComponenets() -> URLComponents {
        var components = URLComponents()
        components.scheme = IrishRailAPI.scheme
        components.host = IrishRailAPI.host
        components.path = IrishRailAPI.path
        
        return components
    }
    
    func getURLForAllStations() -> URL? {
        var components = getBaseURLComponenets()
        components.path += getAllStationsPath

        return components.url
    }
    
    func getURLForAllStations(withType type: StationType) -> URL? {
        var components = getBaseURLComponenets()
        components.path += getAllStationsURLWithTypePath
        components.queryItems = [
            URLQueryItem(name: stationTypeParam, value: type.rawValue)
        ]

        return components.url
    }
    
    func getStationData(withName name: String) -> URL? {
        var components = getBaseURLComponenets()
        components.path += getStationDataByNamePath
        components.queryItems = [
            URLQueryItem(name: stationDescriptionParam, value: name)
        ]

        return components.url
    }
    
    // TODO: Chagne param `andDate` to be of Date type
    func getStationData(withName name: String, andDate date: String) -> URL? {
        var components = getBaseURLComponenets()
        components.path += getStationDataByNameAndTimeSpanPath
        components.queryItems = [
            URLQueryItem(name: stationDescriptionParam, value: name),
            URLQueryItem(name: minutesParam, value: date)
        ]

        return components.url
    }
    
    func getStationData(withCode code: String) -> URL? {
        var components = getBaseURLComponenets()
        components.path += getStationDataByCodePath
        components.queryItems = [
            URLQueryItem(name: stationCodeParam, value: code)
        ]

        return components.url
    }
    
    // TODO: Chagne param `andDate` to be of Date type
    func getStationData(withCode code: String, andDate date: String) -> URL? {
        var components = getBaseURLComponenets()
        components.path += getStationDataByCodeAndTimeSpanPath
        components.queryItems = [
            URLQueryItem(name: stationCodeParam, value: code),
            URLQueryItem(name: minutesParam, value: date)
        ]
        
        return components.url
    }
    
    
    func getStationData(withStaticString query: String) -> URL? {
        var components = getBaseURLComponenets()
        components.path += getFilteredStationDataByStringPath
        components.queryItems = [
            URLQueryItem(name: staticTextParam, value: query)
        ]

        return components.url
    }
    
    // MARK: Trains APIs
    private let getCurrentTrainsPath = "/getCurrentTrainsXML" // Example: http://api.irishrail.ie/realtime/realtime.asmx/getCurrentTrainsXML
    private let getCurrentTrainsWithTypePath = "/getCurrentTrainsXML_WithTrainType" // accepts a single param, `trainTypeParam`. Example: http://api.irishrail.ie/realtime/realtime.asmx/getCurrentTrainsXML_WithTrainType?TrainType=D
    private let getTrainMovementsByIdAndDatePath = "/getTrainMovementsXML" // accepts two params, `trainIdParam` and `trainDateParam`. Example: http://api.irishrail.ie/realtime/realtime.asmx/getTrainMovementsXML?TrainId=E976&TrainDate=26%20apr%2020
    
    // MARK: Params
    private let stationDescriptionParam = "StationDesc"
    private let minutesParam = "NumMins" // Format in "31 Dec 2019"
    private let stationCodeParam = "StationCode"
    private let staticTextParam = "StationText"
    private let trainIdParam = "TrainId"
    private let trainDateParam = "TrainDate"
    private let trainTypeParam = "TrainType"
    private let stationTypeParam = "StationType"
    
    func getCurrentTrains() -> URL? {
        var components = getBaseURLComponenets()
        components.path += getCurrentTrainsPath

        return components.url
    }
    
    func getCurrentTrains(withType type: TrainType) -> URL? {
        var components = getBaseURLComponenets()
        components.path += getCurrentTrainsWithTypePath
        components.queryItems = [
            URLQueryItem(name: trainTypeParam, value: type.rawValue)
        ]

        return components.url
    }
    
    // TODO: Chagne param `andDate` to be of Date type
    func getTrainMovements(byId id: String, andDate date: String) -> URL? {
        var components = getBaseURLComponenets()
        components.path += getTrainMovementsByIdAndDatePath
        components.queryItems = [
            URLQueryItem(name: trainIdParam, value: id),
            URLQueryItem(name: trainDateParam, value: date)
        ]

        return components.url
    }
}

// MARK: Static fields
extension IrishRailAPI {
    
    private static let baseURL: String = "https://api.irishrail.ie/realtime/realtime.asmx/"
    private static let scheme = "http"
    private static let host = "api.irishrail.ie"
    private static let path = "/realtime/realtime.asmx"
}

// MARK: Enums
extension IrishRailAPI {
    
    enum TrainType: String {
        case all = "A"
        case mainline = "M"
        case suburban = "S"
        case dart = "D"
    }

    enum StationType: String {
        case all = "A"
        case mainline = "M"
        case suburban = "S"
        case dart = "D"
    }
}
