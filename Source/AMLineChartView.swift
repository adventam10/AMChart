//
//  AMLineChartView.swift
//  AMChart, https://github.com/adventam10/AMChart
//
//  Created by am10 on 2018/01/02.
//  Copyright © 2018年 am10. All rights reserved.
//

import UIKit

public protocol AMLineChartViewDataSource: AnyObject {
    func numberOfSections(in lineChartView: AMLineChartView) -> Int
    func numberOfRows(in lineChartView: AMLineChartView) -> Int
    func lineChartView(_ lineChartView: AMLineChartView, valueForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    func lineChartView(_ lineChartView: AMLineChartView, colorForSection section: Int) -> UIColor
    func lineChartView(_ lineChartView: AMLineChartView, titleForXlabelInRow row: Int) -> String
    func lineChartView(_ lineChartView: AMLineChartView, pointTypeForSection section: Int) -> AMPointType
}

public class AMLineChartView: AMChartView {
    
    @IBInspectable public var yAxisMaxValue: CGFloat = 1000
    @IBInspectable public var yAxisMinValue: CGFloat = 0
    @IBInspectable public var numberOfYAxisLabel: Int = 6
    @IBInspectable public var axisColor: UIColor = .black
    @IBInspectable public var axisWidth: CGFloat = 1.0
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
    
    weak public var dataSource: AMLineChartViewDataSource?
    public var yAxisDecimalFormat: AMDecimalFormat = .none
    public var animationDuration: CFTimeInterval = 0.6
    
    private let margin: CGFloat = 8
    private let pointRadius: CGFloat = 5
    private let xAxisView = UIView()
    private let yAxisView = UIView()
    private let xAxisTitleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()
    private let yAxisTitleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()
    
    private var xLabels = [UILabel]()
    private var yLabels = [UILabel]()
    private var graphLayers = [CAShapeLayer]()
    private var horizontalLineLayers = [CALayer]()
    private var animationPaths = [UIBezierPath]()
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
    }
    
    // MARK:- Draw
    private func makeXAxisLabels(rows: Int) -> [UILabel] {
        var labels = [UILabel]()
        for _ in 0..<rows {
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
            label.text = dataSource?.lineChartView(self, titleForXlabelInRow: index)
            label.frame = CGRect(x: x, y: xAxisView.frame.origin.y + axisWidth + margin, width: width, height: label.frame.size.height)
            label.textAlignment = .center
            addSubview(label)
        }
    }
    
    private func prepareGraphLineLayers(positionY: CGFloat) {
        let lineLayer = CALayer()
        lineLayer.frame = CGRect(x: xAxisView.frame.origin.x, y: positionY,
                                 width: xAxisView.frame.width, height: 1)
        lineLayer.backgroundColor = UIColor.black.cgColor
        layer.addSublayer(lineLayer)
        horizontalLineLayers.append(lineLayer)
    }
    
    private func prepareGraphLayers(sections: Int) {
        while graphLayers.count < sections {
            let graphLayer = CAShapeLayer()
            layer.addSublayer(graphLayer)
            graphLayers.append(graphLayer)
        }
        
        while graphLayers.count > sections {
            let graphLayer = graphLayers.last
            graphLayer?.removeFromSuperlayer()
            graphLayers.removeLast()
        }
        
        graphLayers.forEach {
            $0.frame = CGRect(x: yAxisView.frame.origin.x + axisWidth,  y: yAxisView.frame.origin.y,
                              width: xAxisView.frame.width - axisWidth, height: yAxisView.frame.height)
        }
    }
    
    private func setGraphLayerColor(_ graphLayer: CAShapeLayer, color: UIColor, pointType: AMPointType) {
        graphLayer.strokeColor = color.cgColor
        if pointType.isFilled {
            graphLayer.fillColor = color.cgColor
        } else {
            graphLayer.fillColor = UIColor.clear.cgColor
        }
    }
    
    private func makeAnimationPath(_ graphLayer: CAShapeLayer, values: [CGFloat], pointType: AMPointType) -> UIBezierPath {
        let path = UIBezierPath()
        for (index, xLabel) in xLabels.enumerated() {
            let value = values[index]
            let x = xLabel.frame.origin.x + xLabel.frame.width/2 - (yAxisView.frame.origin.x + axisWidth)
            var y = graphLayer.frame.height - (((value - yAxisMinValue)/(yAxisMaxValue - yAxisMinValue)) * graphLayer.frame.height)
            if y.isNaN {
                y = 0
            }
            
            let pointPath = makePointPath(x: x, y: y, pointType: pointType)
            if index == 0 {
                path.append(pointPath)
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
                path.append(pointPath)
                path.move(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }
    
    private func makePointPath(x: CGFloat, y: CGFloat, pointType: AMPointType) -> UIBezierPath {
        switch pointType {
        case .type1, .type2:
            return makeCirclePointPath(x: x, y: y)
        case .type3, .type4:
            return makeSquarePointPath(x: x, y: y)
        case .type5, .type6:
            return makeTrianglePointPath(x: x, y: y)
        case .type7, .type8:
            return makeDiamondPointPath(x: x, y: y)
        case .type9:
            return makeXPointPath(x: x, y: y)
        }
    }
    
    private func makeCirclePointPath(x: CGFloat, y: CGFloat) -> UIBezierPath {
        return .init(ovalIn: CGRect(x: x - pointRadius, y: y - pointRadius,
                                    width: pointRadius * 2, height: pointRadius * 2))
    }
    
    private func makeSquarePointPath(x: CGFloat, y: CGFloat) -> UIBezierPath {
        return .init(rect: CGRect(x: x - pointRadius, y: y - pointRadius,
                                  width: pointRadius * 2, height: pointRadius * 2))
    }
    
    private func makeTrianglePointPath(x: CGFloat, y: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x, y: y - pointRadius))
        path.addLine(to: CGPoint(x: x + pointRadius, y: y + pointRadius))
        path.addLine(to: CGPoint(x: x - pointRadius, y: y + pointRadius))
        path.addLine(to: CGPoint(x: x, y: y - pointRadius))
        return path
    }
    
    private func makeDiamondPointPath(x: CGFloat, y: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x, y: y - pointRadius))
        path.addLine(to: CGPoint(x: x + pointRadius, y: y))
        path.addLine(to: CGPoint(x: x , y: y + pointRadius))
        path.addLine(to: CGPoint(x: x - pointRadius, y: y))
        path.addLine(to: CGPoint(x: x, y: y - pointRadius))
        return path
    }
    
    private func makeXPointPath(x: CGFloat, y: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x - pointRadius, y: y - pointRadius))
        path.addLine(to: CGPoint(x: x + pointRadius, y: y + pointRadius))
        path.move(to: CGPoint(x: x + pointRadius, y: y - pointRadius))
        path.addLine(to: CGPoint(x: x - pointRadius, y: y + pointRadius))
        return path
    }
    
    private func showAnimation() {
        for (index, graphLayer) in graphLayers.enumerated() {
            let animationPath = animationPaths[index]
            if graphLayer.path == nil {
                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.duration = animationDuration
                animation.fromValue = 0
                animation.toValue = 1
                graphLayer.path = animationPath.cgPath
                graphLayer.add(animation, forKey: nil)
            } else {
                let animation = CABasicAnimation(keyPath: "path")
                animation.duration = animationDuration
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
                animation.fromValue = UIBezierPath(cgPath: graphLayer.path!).cgPath
                animation.toValue = animationPath.cgPath
                graphLayer.path = animationPath.cgPath
                graphLayer.add(animation, forKey: nil)
            }
        }
        animationPaths.removeAll()
    }
    
    // MARK:- Reload
    override public func reloadData() {
        clearView()
        guard let dataSource = dataSource else {
            return
        }
        let sections = dataSource.numberOfSections(in: self)
        let rows = dataSource.numberOfRows(in: self)
        precondition(numberOfYAxisLabel > 1, "numberOfYAxisLabel is less than 2")
        precondition(rows > 0, "rows is less than 1")
        precondition(yAxisMinValue < yAxisMaxValue, "yAxisMaxValue is less than or eqaul to yAxisMinValue")
        yLabels = makeYAxisLabels()
        xLabels = makeXAxisLabels(rows: rows)
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
        prepareGraphLayers(sections: sections)
        for section in 0..<sections {
            var values = [CGFloat]()
            for row in 0..<rows {
                if section == 0 {
                    xLabels[row].text = dataSource.lineChartView(self, titleForXlabelInRow: row)
                }
                values.append(dataSource.lineChartView(self, valueForRowAtIndexPath: IndexPath(row:row, section: section)))
            }
            let pointType = dataSource.lineChartView(self, pointTypeForSection: section)
            let graphLayer = graphLayers[section]
            setGraphLayerColor(graphLayer, color: dataSource.lineChartView(self, colorForSection: section), pointType: pointType)
            animationPaths.append(makeAnimationPath(graphLayer, values: values, pointType: pointType))
        }
        showAnimation()
    }
    
    public func redrawChart() {
        graphLayers.forEach { $0.removeFromSuperlayer() }
        graphLayers.removeAll()
        reloadData()
    }
    
    private func clearView() {
        xLabels.forEach { $0.removeFromSuperview() }
        xLabels.removeAll()
        
        yLabels.forEach { $0.removeFromSuperview() }
        yLabels.removeAll()
        
        horizontalLineLayers.forEach { $0.removeFromSuperlayer() }
        horizontalLineLayers.removeAll()
    }
}
