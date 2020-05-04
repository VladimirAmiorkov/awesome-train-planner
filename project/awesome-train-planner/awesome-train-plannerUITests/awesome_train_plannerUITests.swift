//
//  awesome_train_plannerUITests.swift
//  awesome-train-plannerUITests
//
//  Created by Vladimir Amiorkov on 25.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import XCTest

class awesome_train_plannerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {

    }

    func testAppStartsWithNoCrash() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
