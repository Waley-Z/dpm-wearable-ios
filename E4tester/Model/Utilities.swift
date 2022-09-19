//
//  Utilities.swift
//  E4tester
//
//  Created by Waley Zheng on 7/26/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import Foundation

func trimStr(str: String) -> String {
    return str.trimmingCharacters(in: .whitespacesAndNewlines)
}

func fileURL() throws -> URL {
    try FileManager.default.url(for: .documentDirectory,
                                   in: .userDomainMask,
                                   appropriateFor: nil,
                                   create: false)
        .appendingPathComponent("user.data")
}

func ifLessThanNHours(timestamp: Double, hours: Double) -> Bool {
    return (Date().timeIntervalSince1970 - timestamp <= hours * 3600)
}
