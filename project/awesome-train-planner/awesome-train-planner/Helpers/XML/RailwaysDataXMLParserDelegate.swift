//
//  RailwaysDataXMLParserDelegate.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 27.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation

// TODO: This only parses `[[String: String]]`, extend this to support multiple types e.g `[[String: Any]]`
class RailwaysDataXMLParserDelegate: NSObject, XMLParserDelegate {
    
    private var rootKey: String
    private var dictionaryKeys: Set<String>
    private var results: [[String: String]]?
    private var currentDictionary: [String: String]?
    private var currentValue: String?
    
    init(rootKey: String, dictionaryKeys: [String]) {
        self.rootKey = rootKey
        self .dictionaryKeys = Set<String>(dictionaryKeys)
        
        super.init()
    }
    
    func getResult() -> [[String: String]]? {
        guard let results = results else {
            return nil
        }
        
        return results
    }

    func parserDidStartDocument(_ parser: XMLParser) {
        results = []
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == rootKey {
            currentDictionary = [:]
        } else if dictionaryKeys.contains(elementName) {
            currentValue = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue? += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == rootKey {
            results!.append(currentDictionary!)
            currentDictionary = nil
        } else if dictionaryKeys.contains(elementName) {
            currentDictionary![elementName] = currentValue
            currentValue = nil
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)

        currentValue = nil
        currentDictionary = nil
        results = nil
    }
}
