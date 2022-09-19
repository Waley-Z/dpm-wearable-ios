/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A single line in the graph.
*/

import SwiftUI

struct GraphCapsule: View, Equatable {
    var index: Int
    var color: Color
    var height: CGFloat
    var range: Range<Int>
    let overallRange: Range<Int> = 0..<100

    var heightRatio: CGFloat {
        range == -1 ..< -1 ? 0.0 : max(CGFloat(magnitude(of: range) / magnitude(of: overallRange)), 0.12)
    }

    var offsetRatio: CGFloat {
        CGFloat((Double(range.lowerBound)*0.88 - Double(overallRange.lowerBound)) / magnitude(of: overallRange) - 0.03)
    }

    var body: some View {
        Capsule()
            .fill(color)
            .frame(height: height * heightRatio)
            .offset(x: 0, y: height * -offsetRatio)
//            .onAppear() {
//                print(range)
//                print(index)
//            }

    }
}

struct GraphCapsule_Previews: PreviewProvider {
    static var previews: some View {
        GraphCapsule(
            index: 0,
            color: .blue,
            height: 150,
            range: 10..<50)
    }
}
