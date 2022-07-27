//
//  Peer.swift
//  E4tester
//
//  Created by Waley Zheng on 7/22/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import Foundation

struct Peer : Identifiable {
    var id: Int // user_id
    
    var fullname: String = ""
    var fatigue_level = 0
    var last_update: Int = 0
    var observations: [Observation]
    
    struct Observation: Codable, Hashable {
        var hour_from_midnight: Int
        var fatigue_level_range: Range<Int>
    }
}
