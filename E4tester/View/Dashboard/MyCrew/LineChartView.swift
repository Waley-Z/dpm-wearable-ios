//
//  LineChartView.swift
//  E4tester
//
//  Created by Waley Zheng on 10/28/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI

struct _LineChartView: View {
    var peer: Peer
    var radius: CGFloat

    var highestPoint: Double = 100
    var dataPoints: [Double] {
        var dataPoints: [Double] = []
        for o in peer.observations {
            dataPoints.append(min(o.avg_fatigue_level, highestPoint))
        }
        return dataPoints
    }
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            let firstIndex = findFirstIndex()
            
            if (firstIndex != -1) {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height * ratio(for: firstIndex)))
                    
                    for index in 1..<dataPoints.count {
                        if (dataPoints[index] != -1) {
                            path.addLine(to: CGPoint(
                                x: CGFloat(index) * width / CGFloat(dataPoints.count - 1),
                                y: height * ratio(for: index)))
                        }
                    }
                }
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, lineJoin: .round))
                
                Path { path in
                    path.move(to: CGPoint(x: 0, y: (height * ratio(for: firstIndex)) - radius))
                    
                    path.addArc(center: CGPoint(x: 0, y: height * ratio(for: firstIndex)),
                                radius: radius, startAngle: .zero,
                                endAngle: .degrees(360.0), clockwise: false)
                    
                    for index in 1..<dataPoints.count {
                        if (dataPoints[index] != -1) {
                            path.move(to: CGPoint(
                                x: CGFloat(index) * width / CGFloat(dataPoints.count - 1),
                                y: height * dataPoints[index] / highestPoint))
                            
                            path.addArc(center: CGPoint(
                                x: CGFloat(index) * width / CGFloat(dataPoints.count - 1),
                                y: height * ratio(for: index)),
                                        radius: radius, startAngle: .zero,
                                        endAngle: .degrees(360.0), clockwise: false)
                        }
                    }
                }
                .stroke(Color.accentColor, lineWidth: 2)
            }
        }
        .padding(.vertical)
    }
    
    private func ratio(for index: Int) -> Double {
        1 - (dataPoints[index] / highestPoint)
    }

    private func findFirstIndex() -> Int {
        for (index, d) in dataPoints.enumerated() {
            if d != -1 {
                return index
            }
        }
        return -1
    }
}
