//
//  AMBarChartView.swift
//  AMChart, https://github.com/adventam10/AMChart
//
//  Created by am10 on 2018/01/02.
//  Copyright © 2018年 am10. All rights reserved.
//

import UIKit

public protocol AMBarChartViewDataSource: AnyObject {
    func numberOfSections(in barChartView: AMBarChartView) -> Int
    func barChartView(_ barChartView: AMBarChartView, numberOfRowsInSection section: Int) -> Int
    func barChartView(_ barChartView: AMBarChartView, valueForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    func barChartView(_ barChartView: AMBarChartView, colorForRowAtIndexPath indexPath: IndexPath) -> UIColor
    func barChartView(_ barChartView: AMBarChartView, titleForXlabelInSection section: Int) -> String
}

public class AMBarChartView: AMChartView {
    
    @IBInspectable public var yAxisMaxValue: CGFloat = 1000
    @IBInspectable public var numberOfYAxisLabel: Int = 6
    @IBInspectable public var axisColor: UIColor = .black
    @IBInspectable public var axisWidth: CGFloat = 1.0
    @IBInspectable public var barSpace: CGFloat = 8
    @IBInspectable public var yAxisTitleFont: UIFont = .systemFont(ofSize: 15)
    @IBInspectable public var xAxisTitleFont: UIFont = .systemFont(ofSize: 15)
    @IBInspectable public var yLabelsFont: UIFont = .systemFont(ofSize: 15)
    @IBInspectable public var xLabelsFont: UIFont = .systemFont(ofSize: 15)
    @IBInspectable public var yAxisTitleColor: UIColor = .black
    @IBInspectable public var xAxisTitleColor: UIColor = .black
    @IBInspectable public var yLabelsTextColor: UIColor = .black
    @IBInspectable public var xLabelsTextColor: UIColor = .black
    @IBInspectable public var isHorizontalLine: Bool = false
    @IBInspectable public var yAxisTitle: String = ""
    @IBInspectable public var xAxisTitle: String = ""
    
    weak public var dataSource: AMBarChartViewDataSource?
    public var yAxisDecimalFormat: AMDecimalFormat = .none
    public var animationDuration: CFTimeInterval = 0.6
        
    private let yAxisMinValue: CGFloat = 0
    private let margin: CGFloat = 8
    private let xAxisView = UIView()
    private let yAxisView = UIView()
    private var xLabels = [UILabel]()
    private var yLabels = [UILabel]()
    private var barLayers = [CALayer]()
    private let xAxisTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private let yAxisTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    private var horizontalLineLayers = [CALayer]()
    private var graphLineLayers = [CAShapeLayer]()
    private var graphLineLayer = CALayer()
    private var yAxisPositionX: CGFloat {
        let sorted = yLabels.sorted { $0.frame.width > $1.frame.width }
        guard let maxWidthLabel = sorted.first else {
            return margin
        }
        return maxWidthLabel.frame.size.width + margin
    }
    private var xAxisPositionY: CGFloat {
        let sorted = xLabels.sorted { $0.frame.height > $1.frame.height }
        let margin = xAxisTitleLabel.frame.size.height > 0 ? self.margin * 2 : self.margin
        guard let maxHeightLabel = sorted.first else {
            return frame.size.height - margin - xAxisTitleLabel.frame.size.height - axisWidth
        }
        return frame.size.height - maxHeightLabel.frame.size.height - margin - xAxisTitleLabel.frame.size.height - axisWidth
    }
    
    override public func initView() {
        addSubview(yAxisView)
        addSubview(yAxisTitleLabel)
        addSubview(xAxisView)
        addSubview(xAxisTitleLabel)
        graphLineLayer.masksToBounds = true
        layer.addSublayer(graphLineLayer)
    }
    
    // MARK:- Draw
    private func makeXAxisLabels(sections: Int) -> [UILabel] {
        var labels = [UILabel]()
        for _ in 0..<sections {
            let label = UILabel(frame: .zero)
            label.font = xLabelsFont
            label.textColor = xLabelsTextColor
            labels.append(label)
            label.text = "X"
            label.sizeToFit()
        }
        return labels
    }
    
    private func makeYAxisLabels() -> [UILabel] {
        let valueCount = (yAxisMaxValue - yAxisMinValue) / CGFloat(numberOfYAxisLabel - 1)
        var value = yAxisMinValue
        var labels = [UILabel]()
        for _ in 0..<numberOfYAxisLabel {
            let label = UILabel(frame: .zero)
            label.font = yLabelsFont
            label.textColor = yLabelsTextColor
            labels.append(label)
            label.text = yAxisDecimalFormat.formattedValue(value)
            label.sizeToFit()
            value += valueCount
        }
        return labels
    }
    
    private func prepareXAxisTitleLabel() {
        xAxisTitleLabel.font = xAxisTitleFont
        xAxisTitleLabel.textColor = xAxisTitleColor
        xAxisTitleLabel.text = xAxisTitle
        xAxisTitleLabel.sizeToFit()
        xAxisTitleLabel.textAlignment = .center
        xAxisTitleLabel.frame = CGRect(x: yAxisPositionX, y: frame.height - xAxisTitleLabel.frame.size.height,
                                       width: frame.width - yAxisPositionX, height: xAxisTitleLabel.frame.size.height)
    }
    
    private func prepareYAxisTitleLabel() {
        yAxisTitleLabel.font = yAxisTitleFont
        yAxisTitleLabel.textColor = yAxisTitleColor
        yAxisTitleLabel.text = yAxisTitle
        yAxisTitleLabel.sizeToFit()
        let width = yAxisTitleLabel.frame.size.width
        yAxisTitleLabel.frame = CGRect(x: yAxisPositionX - width/2, y: 0, width: width , height: yAxisTitleLabel.frame.size.height)
    }
    
    private func settingAxisViewFrame() {
        let yLabelHeight = yLabels.sorted { $0.frame.height > $1.frame.height }.first!.frame.size.height
        let y = yAxisTitleLabel.frame.size.height + margin + yLabelHeight/2
        yAxisView.frame = CGRect(x: yAxisPositionX, y: y, width: axisWidth, height: xAxisPositionY - y)
        xAxisView.frame = CGRect(x: yAxisPositionX, y: xAxisPositionY, width: frame.width - yAxisPositionX, height: axisWidth)
        yAxisView.backgroundColor = axisColor
        xAxisView.backgroundColor = axisColor
        graphLineLayer.frame = CGRect(x: yAxisView.frame.minX + axisWidth, y: yAxisView.frame.minY,
                                      width: xAxisView.frame.width - axisWidth, height: yAxisView.frame.height)
    }
    
    private func prepareYLabels() {
        let space = (yAxisView.frame.height / CGFloat(numberOfYAxisLabel - 1))
        var y = xAxisView.frame.origin.y
        yLabels.forEach {
            let width = $0.frame.size.width
            let height = $0.frame.size.height
            $0.frame = CGRect(x: yAxisView.frame.origin.x - width - margin, y: y - height/2, width: width, height: height)
            y -= space
            addSubview($0)
        }
    }
    
    private func prepareXlabels() {
        let width = (xAxisView.frame.size.width - axisWidth) / CGFloat(xLabels.count)
        for (index, label) in xLabels.enumerated() {
            let x = xAxisView.frame.origin.x + axisWidth + width * CGFloat(index)
            label.text = dataSource?.barChartView(self, titleForXlabelInSection: index)
            label.frame = CGRect(x: x, y: xAxisView.frame.origin.y + axisWidth + margin, width: width, height: label.frame.size.height)
            label.textAlignment = .center
            addSubview(label)
        }
    }
    
    private func prepareGraphLineLayers(positionY: CGFloat) {
        let lineLayer = CALayer()
        lineLayer.frame = CGRect(x: xAxisView.frame.minX, y: positionY,
                                 width: xAxisView.frame.width, height: 1)
        lineLayer.backgroundColor = UIColor.black.cgColor
        layer.addSublayer(lineLayer)
        horizontalLineLayers.append(lineLayer)
    }
        
    private func prepareBarLayers(section: Int) {
        let xLabel = xLabels[section]
        let barLayer = CALayer()
        let width = (xAxisView.frame.width - axisWidth - barSpace*CGFloat(xLabels.count + 1)) / CGFloat(xLabels.count)
        barLayer.frame = CGRect(x: xLabel.center.x - width/2, y: yAxisView.frame.minY,
                                width: width, height: yAxisView.frame.height - axisWidth)
        barLayers.append(barLayer)
        layer.addSublayer(barLayer)
    }
    
    private func prepareBarGraph(section: Int, colors: [UIColor], values: [CGFloat]) {
        let sum = values.reduce(0, +)
        let barLayer = barLayers[section]
        barLayer.masksToBounds = true
        var frame = barLayer.frame
        frame.size.height = ((sum - yAxisMinValue) / (yAxisMaxValue - yAxisMinValue)) * barLayer.frame.height
        if frame.size.height.isNaN {
            frame.size.height = 0
        }
        frame.origin.y = xAxisView.frame.minY - frame.height
        barLayer.frame = frame
        var y = barLayer.frame.height + (barLayer.frame.height * yAxisMinValue) / (sum - yAxisMinValue)
        if y.isNaN {
            y = 0
        }
        
        for (index, color) in colors.enumerated() {
            let value = values[index]
            var height = (value/(sum - yAxisMinValue)) * barLayer.frame.height
            if height.isNaN {
                height = 0
            }
            let valueLayer = CAShapeLayer()
            valueLayer.frame = barLayer.bounds
            valueLayer.fillColor = color.cgColor
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: y - height))
            path.addLine(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: barLayer.frame.width, y: y))
            path.addLine(to: CGPoint(x: barLayer.frame.width, y: y - height))
            path.addLine(to: CGPoint(x: 0, y: y - height))
            valueLayer.path = path.cgPath
            barLayer.addSublayer(valueLayer)
            y -= height
        }
    }
    
    private func showAnimation() {
        for barLayer in barLayers {
            let startPath = UIBezierPath()
            startPath.move(to: CGPoint(x: 0, y: barLayer.frame.height))
            startPath.addLine(to: CGPoint(x: 0, y: barLayer.frame.height))
            startPath.addLine(to: CGPoint(x: barLayer.frame.width, y: barLayer.frame.height))
            startPath.addLine(to: CGPoint(x: barLayer.frame.width, y: barLayer.frame.height))
            startPath.addLine(to: CGPoint(x: 0, y: barLayer.frame.height))
            for layer in barLayer.sublayers! {
                let valueLayer = layer as! CAShapeLayer
                let animationPath = UIBezierPath(cgPath: valueLayer.path!)
                let animation = CABasicAnimation(keyPath: "path")
                animation.duration = animationDuration
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
                animation.fromValue = startPath.cgPath
                animation.toValue = animationPath.cgPath
                valueLayer.path = animationPath.cgPath
                valueLayer.add(animation, forKey: nil)
            }
        }
    }
    
    // MARK:- Reload
    override public func reloadData() {
        clearView()
        guard let dataSource = dataSource else {
            return
        }
        let sections = dataSource.numberOfSections(in: self)
        precondition(numberOfYAxisLabel > 1, "numberOfYAxisLabel is less than 2")
        precondition(sections > 0, "sections is less than 1")
        precondition(yAxisMaxValue >= 0, "yAxisMaxValue is less than 0")
        yLabels = makeYAxisLabels()
        xLabels = makeXAxisLabels(sections: sections)
        prepareXAxisTitleLabel()
        prepareYAxisTitleLabel()
        settingAxisViewFrame()
        prepareYLabels()
        prepareXlabels()
        if isHorizontalLine {
            yLabels.forEach {
                prepareGraphLineLayers(positionY: $0.center.y)
            }
        }
        for section in 0..<sections {
            prepareBarLayers(section: section)
            let rows = dataSource.barChartView(self, numberOfRowsInSection: section)
            var values = [CGFloat]()
            var colors = [UIColor]()
            for row in 0..<rows {
                let indexPath = IndexPath(row:row, section: section)
                let value = dataSource.barChartView(self, valueForRowAtIndexPath: indexPath)
                precondition(value >= 0, "value is less than 0 \(indexPath)")
                values.append(value)
                colors.append(dataSource.barChartView(self, colorForRowAtIndexPath: indexPath))
            }
            prepareBarGraph(section: section, colors: colors, values: values)
        }
        showAnimation()
    }
    
    private func clearView() {
        xLabels.forEach { $0.removeFromSuperview() }
        xLabels.removeAll()
        
        yLabels.forEach { $0.removeFromSuperview() }
        yLabels.removeAll()
        
        horizontalLineLayers.forEach { $0.removeFromSuperlayer() }
        horizontalLineLayers.removeAll()
        
        barLayers.forEach { $0.removeFromSuperlayer() }
        barLayers.removeAll()
        
        graphLineLayers.forEach { $0.removeFromSuperlayer() }
        graphLineLayers.removeAll()
    }
}
