//
//  ModelData.swift
//  E4tester
//
//  Created by Waley Zheng on 6/29/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import Foundation

@MainActor class ModelData: ObservableObject {
    @Published var heartRate: Int = 0
    @Published var fatigueLevel: Int = 0
}
