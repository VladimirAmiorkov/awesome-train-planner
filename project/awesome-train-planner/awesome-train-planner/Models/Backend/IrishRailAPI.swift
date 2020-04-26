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
    let baseURL: String = "http://api.irishrail.ie/realtime/realtime.asmx/"
    
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
    let getAllStationsURL = "getAllStationsXML" // Example: http://api.irishrail.ie/realtime/realtime.asmx/getAllStationsXML
    let getAllStationsURLWithTypeURL = "getAllStationsXML_WithStationType" // accepts a single param, `stationTypeParam`. Example: http://api.irishrail.ie/realtime/realtime.asmx/getAllStationsXML_WithStationType?StationType=D
    let getStationDataByNameURL = "getStationDataByNameXML" // accepts a single param, `stationDescriptionParam`. Example: http://api.irishrail.ie/realtime/realtime.asmx/getStationDataByNameXML?StationDesc=Bayside
    let getStationDataByNameAndTimeSpanURL = "getStationDataByNameXML" // accepts two params, `stationDescriptionParam` and `minutesParam`. Example: http://api.irishrail.ie/realtime/realtime.asmx/getStationDataByNameXML_withNumMins?StationDesc=Bayside&NumMins=20
    let getStationDataByCodeURL = "getStationDataByCodeXML" // accepts a single param, `stationCodeParam`. Example: http://api.irishrail.ie/realtime/realtime.asmx/getStationDataByCodeXML?StationCode=mhide
    let getStationDataByCodeAndTimeSpanURL = "getStationDataByCodeXML_WithNumMins" // accepts two params, `stationCodeParam` and `minutesParam`. Example:
    let getFilteredStationDataByStringURL = "getStationsFilterXML" // accepts a single param, `staticTextParam`. Example: http://api.irishrail.ie/realtime/realtime.asmx/getStationDataByCodeXML_WithNumMins?StationCode=mhide&NumMins=20
    
    // MARK: Trains APIs
    let getCurrentTrainsURL = "getCurrentTrainsXML" // Example: http://api.irishrail.ie/realtime/realtime.asmx/getCurrentTrainsXML
    let getCurrentTrainsWithTypeURL = "getCurrentTrainsXML_WithTrainType" // accepts a single param, `trainTypeParam`. Example: http://api.irishrail.ie/realtime/realtime.asmx/getCurrentTrainsXML_WithTrainType?TrainType=D
    
    let getTrainMovementsByIdAndDateURL = "getTrainMovementsXML" // accepts two params, `trainIdParam` and `trainDateParam`. Example: http://api.irishrail.ie/realtime/realtime.asmx/getTrainMovementsXML?TrainId=E976&TrainDate=26%20apr%2020
    
    // MARK: Params
    let stationDescriptionParam = "StationDesc"
    let minutesParam = "NumMins"
    let stationCodeParam = "StationCode"
    let staticTextParam = "StationText"
    let trainIdParam = "TrainId"
    let trainDateParam = "TrainDate"
    let trainTypeParam = "TrainType"
    let stationTypeParam = "StationType"
}
