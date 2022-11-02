//
//  MultiLineChartView.swift
//  E4tester
//
//  Created by Waley Zheng on 11/1/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI
import Charts

struct MultiLineChartView : UIViewRepresentable {
    
    var peers : [Peer]
    
    let highestPoint: Double = 100

    var dataSets : [LineChartDataSetProtocol] {
        var dataSets: [LineChartDataSetProtocol] = []
        for (index_peer, peer) in peers.enumerated() {
            var entries: [ChartDataEntry] = []
            for (index, o) in peer.observations.enumerated() {
                let data = min(o.avg_fatigue_level, highestPoint)
                if (data != -1) {
                    entries.append(ChartDataEntry(x: Double(index), y: data))
                }
            }
            let dataSet = generateLineChartDataSet(
                dataSetEntries: entries,
                color: UIColor(Color.getColor(withIndex: index_peer)),
                fillColor: UIColor(Color(#colorLiteral(red: 0, green: 0.8134518862, blue: 0.9959517121, alpha: 1))))
            dataSets.append(dataSet)
        }
        return dataSets
    }
    
    
    func makeUIView(context: Context) -> LineChartView {
        let chart = LineChartView()
        return createChart(chart: chart)
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        uiView.data = LineChartData(dataSets: dataSets)
    }
    
    func createChart(chart: LineChartView) -> LineChartView{
        chart.chartDescription.enabled = false
        chart.xAxis.enabled = false
        chart.xAxis.axisMaximum = 8.3
        chart.xAxis.axisMinimum = -0.3
//        chart.xAxis.drawGridLinesEnabled = false
//        chart.xAxis.drawLabelsEnabled = false
//        chart.xAxis.drawAxisLineEnabled = false
//        chart.xAxis.labelPosition = .bottom
        chart.rightAxis.enabled = false
        chart.leftAxis.enabled = true
        chart.drawBordersEnabled = false
        chart.legend.form = .none
//        chart.xAxis.labelCount = 7
//        chart.xAxis.forceLabelsEnabled = true
//        chart.xAxis.granularityEnabled = true
//        chart.xAxis.granularity = 1
//        chart.dragEnabled = false
        chart.pinchZoomEnabled = false
        chart.doubleTapToZoomEnabled = false
        chart.scaleXEnabled = false
        chart.scaleYEnabled = false
        chart.setViewPortOffsets(left: 5, top: 0, right: 5, bottom: 0)
        chart.leftAxis.axisMaximum = 100
        chart.leftAxis.axisMinimum = 0
        chart.leftAxis.drawGridLinesBehindDataEnabled = true
        chart.leftAxis.drawAxisLineEnabled = false
        chart.leftAxis.granularityEnabled = true
        chart.leftAxis.granularity = 25
        
        chart.data = LineChartData(dataSets: dataSets)
        return chart
    }

    func generateLineChartDataSet(dataSetEntries: [ChartDataEntry], color: UIColor, fillColor: UIColor) -> LineChartDataSet{
        let dataSet = LineChartDataSet(entries: dataSetEntries, label: "")
        dataSet.colors = [color]
        dataSet.mode = .cubicBezier
        dataSet.drawCirclesEnabled = true
        dataSet.drawCircleHoleEnabled = false
        dataSet.circleRadius = 3
        dataSet.circleHoleRadius = 2
        dataSet.circleColors = [color]
        dataSet.circleHoleColor = UIColor.clear
//        dataSet.fill = Fill.fillWithColor(fillColor)
        dataSet.drawFilledEnabled = false
//        dataSet.setCircleColor(UIColor.clear)
        dataSet.lineWidth = 2
        dataSet.drawValuesEnabled = false
        dataSet.highlightEnabled = false
//        dataSet.highlight
//        dataSet.lineDashLengths = [20, 3]
        
//        dataSet.valueTextColor = color
//        dataSet.valueFont = UIFont(name: "Avenir", size: 12)!
        return dataSet
    }
    
}
