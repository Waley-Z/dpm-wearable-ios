//
//  User.swift
//  E4tester
//
//  Created by Waley Zheng on 7/22/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import Foundation

struct User: Decodable {
    var fullname: String = ""
    var user_id: Int = -1
    var group_id: String = ""
    var age: Int = -1
    var max_heart_rate: Int = -1
    var rest_heart_rate: Int = -1
    var hrr_cp: Int = -1
    var awc_tot: Int = -1
    var k_value: Int = -1
}
