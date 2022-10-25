//
//  Utilities.swift
//  E4tester
//
//  Created by Waley Zheng on 7/26/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import Foundation

// convert timestamp to date string
func ts2date(timestamp: Double) -> String {
    let date = Date(timeIntervalSince1970: timestamp)
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "EST")
    dateFormatter.dateFormat = "HH:mm:ss" //Specify your format that you want
    let strDate = dateFormatter.string(from: date)
    return strDate
}

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
