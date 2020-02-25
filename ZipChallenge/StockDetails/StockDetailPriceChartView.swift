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
    @IBOutlet var titleLabel: UILabel!
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
            titleLabel.text = ""
            lineChartView.isHidden = true
            return
        }
        titleLabel.text = data.duration.message
        configureChart(with: data.duration, historicalPrices: data.historicalPrices)
    }
    
    func configureChart(with duration: PriceChartDuration, historicalPrices: [StockDetailHistorical]) {
        let dataEntries = historicalPrices.map({ detailHistorical -> ChartDataEntry in
            let timeInterval = detailHistorical.stockDate.timeIntervalSince1970
            let xValue = Double(timeInterval)
            let yValue = detailHistorical.stockPrice
            return ChartDataEntry(x: xValue, y: yValue)
        })
        let label = "Price History for \(duration.message)"
        let dataSet = LineChartDataSet(entries: dataEntries, label: label)
        lineChartView.data = LineChartData(dataSet: dataSet)
        let xAxis = lineChartView.xAxis
        xAxis.valueFormatter = axisFormatDelegate
    }
    
    @IBAction func didTapDuration(_ sender: UIButton) {
        self.delegate?.stockDetailPriceHistoryViewDidTapUpdateDuration(self)
    }
}

extension StockDetailPriceChartView: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

extension StockDetailPriceChartView: ViewDisplayable {}
