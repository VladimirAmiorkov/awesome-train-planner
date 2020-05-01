//
//  RaiwayResponseError.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 2.05.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation

protocol RaiwayResponseErrorProtocol: LocalizedError {

    var title: String? { get }
    var code: Int { get }
}

struct RaiwayResponseError: RaiwayResponseErrorProtocol {

    var title: String?
    var code: Int
    var errorDescription: String? { return _description }
    var failureReason: String? { return _description }

    private var _description: String

    init(title: String?, description: String, code: Int) {
        self.title = title ?? "Error"
        self._description = description
        self.code = code
    }
}
