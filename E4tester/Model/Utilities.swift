//
//  Utilities.swift
//  E4tester
//
//  Created by Waley Zheng on 7/26/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import Foundation
import SwiftUI

extension Color {
    static let Colors: [Color] = [
        Color(red: 4/255, green: 116/255, blue: 186/255),
        Color(red: 255/255, green: 166/255, blue: 48/255),
        Color(red: 92/255, green: 92/255, blue: 92/255),
        Color(red: 107/255, green: 189/255, blue: 96/255),
        Color(red: 0/255, green: 167/255, blue: 225/255),
        Color(red: 255/255, green: 166/255, blue: 0)
    ]
    
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
    
    static func getColor(withIndex index: Int) -> Color {
        return Colors[index % 6]
    }
}

// convert timestamp to date string
func ts2date(timestamp: Double) -> String {
    let date = Date(timeIntervalSince1970: timestamp)
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "EST")
    dateFormatter.dateFormat = "HH:mm:ss" //Specify your format that you want
    let strDate = dateFormatter.string(from: date)
    return strDate
}

// trim white spaces and newlines around string
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

// if timestamp is less than n hours from now
func ifLessThanNHours(timestamp: Double, hours: Double) -> Bool {
    return (Date().timeIntervalSince1970 - timestamp <= hours * 3600)
}
