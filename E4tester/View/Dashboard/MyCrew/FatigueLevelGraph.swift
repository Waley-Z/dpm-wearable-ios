/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The elevation, heart rate, and pace of a hike plotted on a graph.
*/

import SwiftUI

extension Animation {
    static func ripple(index: Int) -> Animation {
        Animation.spring(dampingFraction: 0.5)
            .speed(2)
            .delay(0.03 * Double(index))
    }
}

struct FatigueLevelGraph: View {
    var peer: Peer

    var color: Color {
            return Color(hue: 0, saturation: 0.5, brightness: 0.7)
    }

    func capsuleDisplay(range: Range<Int>) -> Range<Int> {
        if (range.upperBound <= 100) {
            return range
        } else if (range.lowerBound >= 100) {
            return 100..<100
        } else {
            return range.lowerBound..<100
        }
    }
    
    var body: some View {
        let path = \Peer.Observation.fatigue_level_range
        let data = peer.observations
        let overallRange = 0..<100
        let maxMagnitude = min(data.map { magnitude(of: $0[keyPath: path]) }.max()!, 100)
        let heightRatio = 1 - CGFloat(maxMagnitude / magnitude(of: overallRange))

        return GeometryReader { proxy in
            HStack(alignment: .bottom, spacing: proxy.size.width / 120) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, observation in
                    GraphCapsule(
                        index: index,
                        color: color,
                        height: proxy.size.height,
                        range: capsuleDisplay(range: observation.fatigue_level_range)
                    )
                    .animation(.ripple(index: index))
                }
                .offset(x: 0, y: proxy.size.height * heightRatio)
            }
        }
    }
}

func magnitude(of range: Range<Int>) -> Double {
    Double(range.upperBound - range.lowerBound)
}

//struct HeartRateGraph_Previews: PreviewProvider {
//    static var hike = ModelData().hikes[0]
//
//    static var previews: some View {
//        Group {
//            HikeGraph(hike: hike, path: \.elevation)
//                .frame(height: 200)
//            HikeGraph(hike: hike, path: \.heartRate)
//                .frame(height: 200)
//            HikeGraph(hike: hike, path: \.pace)
//                .frame(height: 200)
//        }
//    }
//}
