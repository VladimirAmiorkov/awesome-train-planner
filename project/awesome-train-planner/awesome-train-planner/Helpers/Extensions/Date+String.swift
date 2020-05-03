//
//  Date+String.swift
//  awesome-train-planner
//
//  Created by Vladimir Amiorkov on 3.05.20.
//  Copyright © 2020 Vladimir Amiorkov. All rights reserved.
//

import Foundation

extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
