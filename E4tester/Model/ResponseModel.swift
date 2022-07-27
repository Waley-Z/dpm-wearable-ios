//
//  UpdateCrewResponseModel.swift
//  E4tester
//
//  Created by Waley Zheng on 7/22/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import Foundation

struct UpdateCrewResponseModel: Decodable {
    var peers: [PeerResponseModel]
}

struct PeerResponseModel: Decodable {
    var user_id: Int
    var fullname: String
    var fatigue_level: Int
    var last_update: Int
}

struct PeerFatigueResponseModel: Decodable {
    var observations: [Peer.Observation]
}
