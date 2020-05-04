//
//  mainViewControllerTests.swift
//  awesome-train-plannerTests
//
//  Created by Vladimir Amiorkov on 25.04.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import XCTest
@testable import Awesome_train_planner

class mainVIewModelTests: XCTestCase {
    var viewController: MainViewController?
    var viewModel: MainViewModel?
    var dataService: DataService?
    var router: MockMainRouter?

    override func setUpWithError() throws {
        viewModel = MockMainViewModel()
        dataService = MockDataService()
        router = MockMainRouter()
        viewController = MainViewController(viewModel: viewModel!, andDataService: dataService!, andRouter: router!)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        dataService = nil
        router = nil
        viewController = nil
    }

    func testRouterShowAlertIsCalled() throws {
        viewController?.pickOriginTap(UIButton())
        assert(router!.isShowAlertCalled, "showAlertWith(,) function shuld be called")
    }
}
