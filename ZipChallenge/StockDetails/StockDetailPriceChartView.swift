//
//  StockDetailPriceHistoryView.swift
//  ZipChallenge
//
//  Created by Robert Bernardini on 25/2/20.
//  Copyright © 2020 Robert Bernardini. All rights reserved.
//

import UIKit
import Charts

protocol StockDetailPriceChartViewDelegate: AnyObject {
    func stockDetailPriceHistoryViewDidTapUpdateDuration(_ view: StockDetailPriceChartView)
}

class StockDetailPriceChartView: UIView {
    @IBOutlet var durationButton: UIButton!
    @IBOutlet var lineChartView: LineChartView!
    
    weak var delegate: StockDetailPriceChartViewDelegate?
    weak var axisFormatDelegate: IAxisValueFormatter?

    typealias DisplayData = PriceChartDisplayable
    var displayData: PriceChartDisplayable? {
        didSet { updateView() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        axisFormatDelegate = self
    }
    
    func updateView() {
        guard let data = displayData else {
            durationButton.isHidden = true
            lineChartView.isHidden = true
            return
        }
        durationButton.setTitle(data.duration.text, for: .normal)
        configureChart(with: data.duration, historicalPrices: data.historicalPrices)
    }
    
    @IBAction func didTapDuration(_ sender: UIButton) {
        self.delegate?.stockDetailPriceHistoryViewDidTapUpdateDuration(self)
    }
}

extension StockDetailPriceChartView {
    private func configureChart(with duration: PriceChartPeriod, historicalPrices: [StockDetailHistorical]) {
        let dataEntries = historicalPrices.map({ detailHistorical -> ChartDataEntry in
            let timeInterval = detailHistorical.stockDate.timeIntervalSince1970
            let xValue = Double(timeInterval)
            let yValue = detailHistorical.stockPrice
            return ChartDataEntry(x: xValue, y: yValue)
        })
        let label = "Stock price over the last \(duration.text)"
        let dataSet = LineChartDataSet(entries: dataEntries, label: label)
        dataSet.lineWidth = 2
        let lineColor = obtainLineColor(for: historicalPrices)
        dataSet.colors = [lineColor]
        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled = false
        lineChartView.data = LineChartData(dataSet: dataSet)
        let xAxis = lineChartView.xAxis
        xAxis.valueFormatter = axisFormatDelegate
    }
    
    private func obtainLineColor(for historicalPrices: [StockDetailHistorical]) -> UIColor {
        guard let startPrice = historicalPrices.first?.stockPrice,
            let endPrice = historicalPrices.last?.stockPrice else { return .purple }
        let isGain = endPrice > startPrice
        return isGain ? .systemGreen : .red
    }
}

extension StockDetailPriceChartView: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM-yy"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

extension StockDetailPriceChartView: ViewDisplayable {}
