//
//  AMScatterChartView.swift
//  AMChart, https://github.com/adventam10/AMChart
//
//  Created by am10 on 2018/01/02.
//  Copyright © 2018年 am10. All rights reserved.
//

import UIKit

public protocol AMScatterChartViewDataSource: AnyObject {
    func numberOfSections(in scatterChartView: AMScatterChartView) -> Int
    func scatterChartView(_ scatterChartView: AMScatterChartView, numberOfRowsInSection section: Int) -> Int
    func scatterChartView(_ scatterChartView: AMScatterChartView, valueForRowAtIndexPath indexPath: IndexPath) -> AMScatterValue
    func scatterChartView(_ scatterChartView: AMScatterChartView, colorForSection section: Int) -> UIColor
    func scatterChartView(_ scatterChartView: AMScatterChartView, pointTypeForSection section: Int) -> AMPointType
}

public class AMScatterChartView: AMChartView {

    @IBInspectable public var yAxisMaxValue: CGFloat = 1000
    @IBInspectable public var yAxisMinValue: CGFloat = 0
    @IBInspectable public var numberOfYAxisLabel: Int = 6
    @IBInspectable public var xAxisMaxValue: CGFloat = 1000
    @IBInspectable public var xAxisMinValue: CGFloat = 0
    @IBInspectable public var numberOfXAxisLabel: Int = 6
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
    
    weak public var dataSource: AMScatterChartViewDataSource?
    public var yAxisDecimalFormat: AMDecimalFormat = .none
    public var xAxisDecimalFormat: AMDecimalFormat = .none
    public var animationDuration: CFTimeInterval = 0.6
    
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
    private let margin: CGFloat = 8
    private let pointRadius: CGFloat = 5
    
    private var xLabels = [UILabel]()
    private var yLabels = [UILabel]()
    private var graphLayers = [CAShapeLayer]()
    private var horizontalLineLayers = [CALayer]()
    private var graphLayer = CALayer()
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
    private var xAxisWidth: CGFloat {
        let labelWidth = xLabels.last?.frame.size.width ?? 0
        return frame.size.width - yAxisPositionX - labelWidth/2
    }
    
    override public func initView() {
        addSubview(yAxisView)
        addSubview(yAxisTitleLabel)
        addSubview(xAxisView)
        addSubview(xAxisTitleLabel)
        layer.addSublayer(graphLayer)
    }
    
    // MARK:- Draw
    private func makeXAxisLabels() -> [UILabel] {
        let valueCount = (xAxisMaxValue - xAxisMinValue) / CGFloat(numberOfXAxisLabel - 1)
        var value = xAxisMinValue
        var labels = [UILabel]()
        for _ in 0..<numberOfXAxisLabel {
            let label = UILabel(frame: .zero)
            label.font = xLabelsFont
            label.textColor = xLabelsTextColor
            labels.append(label)
            label.text = xAxisDecimalFormat.formattedValue(value)
            label.sizeToFit()
            value += valueCount
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
                                       width: xAxisWidth, height: xAxisTitleLabel.frame.size.height)
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
        xAxisView.frame = CGRect(x: yAxisView.frame.minX, y: xAxisPositionY, width: xAxisWidth, height: axisWidth)
        yAxisView.backgroundColor = axisColor
        xAxisView.backgroundColor = axisColor
        
        graphLayer.frame = CGRect(x: yAxisView.frame.maxX,
                                  y: yAxisView.frame.minY,
                                  width: xAxisView.frame.width - axisWidth,
                                  height: yAxisView.frame.height)
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
    
    private func prepareXLabels() {
        let space = (xAxisWidth / CGFloat(numberOfXAxisLabel - 1))
        var x = xAxisView.frame.origin.x
        xLabels.forEach {
            let width = $0.frame.size.width
            let height = $0.frame.size.height
            $0.frame = CGRect(x: x - width/2, y: xAxisView.frame.origin.y + axisWidth + margin, width: width, height: height)
            x += space
            addSubview($0)
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
    
    private func prepareGraphLayers(sections: Int) {
        while graphLayers.count < sections {
            let layer = CAShapeLayer()
            graphLayer.addSublayer(layer)
            graphLayers.append(layer)
        }
        
        while graphLayers.count > sections {
            let layer = graphLayers.last
            layer?.removeFromSuperlayer()
            graphLayers.removeLast()
        }
        
        graphLayers.forEach { $0.frame = graphLayer.bounds }
    }
    
    private func setGraphLayerColor(_ graphLayer: CAShapeLayer, color: UIColor, pointType: AMPointType) {
        graphLayer.strokeColor = color.cgColor
        if pointType.isFilled {
            graphLayer.fillColor = color.cgColor
        } else {
            graphLayer.fillColor = UIColor.clear.cgColor
        }
    }
    
    private func makeAnimationPath(_ graphLayer: CAShapeLayer, values: [AMScatterValue], pointType: AMPointType) -> UIBezierPath {
        let path = UIBezierPath()
        for value in values {
            var x =  (value.xValue / (xAxisMaxValue - xAxisMinValue)) * graphLayer.frame.width - graphLayer.frame.width * (xAxisMinValue / (xAxisMaxValue - xAxisMinValue))
            var y = (graphLayer.frame.height + graphLayer.frame.height * (yAxisMinValue / (yAxisMaxValue - yAxisMinValue))) - ((value.yValue / (yAxisMaxValue - yAxisMinValue)) * graphLayer.frame.height)
            if y.isNaN {
                y = 0
            }
            if x.isNaN {
                x = 0
            }
            let point = CGPoint(x: x, y: y)
            path.append(makePointPath(center: point, pointType: pointType))
            path.move(to: point)
        }
        return path
    }
    
    private func makePointPath(center: CGPoint, pointType: AMPointType) -> UIBezierPath {
        switch pointType {
        case .type1, .type2:
            return makeCirclePointPath(center: center)
        case .type3, .type4:
            return makeSquarePointPath(center: center)
        case .type5, .type6:
            return makeTrianglePointPath(center: center)
        case .type7, .type8:
            return makeDiamondPointPath(center: center)
        case .type9:
            return makeXPointPath(center: center)
        }
    }
    
    private func makeCirclePointPath(center: CGPoint) -> UIBezierPath {
        return .init(ovalIn: CGRect(x: center.x - pointRadius, y: center.y - pointRadius,
                                    width: pointRadius * 2, height: pointRadius * 2))
    }
    
    private func makeSquarePointPath(center: CGPoint) -> UIBezierPath {
        return .init(rect: CGRect(x: center.x - pointRadius, y: center.y - pointRadius,
                                  width: pointRadius * 2, height: pointRadius * 2))
    }
    
    private func makeTrianglePointPath(center: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: center.x, y: center.y - pointRadius))
        path.addLine(to: CGPoint(x: center.x + pointRadius, y: center.y + pointRadius))
        path.addLine(to: CGPoint(x: center.x - pointRadius, y: center.y + pointRadius))
        path.close()
        return path
    }
    
    private func makeDiamondPointPath(center: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: center.x, y: center.y - pointRadius))
        path.addLine(to: CGPoint(x: center.x + pointRadius, y: center.y))
        path.addLine(to: CGPoint(x: center.x , y: center.y + pointRadius))
        path.addLine(to: CGPoint(x: center.x - pointRadius, y: center.y))
        path.close()
        return path
    }
    
    private func makeXPointPath(center: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: center.x - pointRadius, y: center.y - pointRadius))
        path.addLine(to: CGPoint(x: center.x + pointRadius, y: center.y + pointRadius))
        path.move(to: CGPoint(x: center.x + pointRadius, y: center.y - pointRadius))
        path.addLine(to: CGPoint(x: center.x - pointRadius, y: center.y + pointRadius))
        return path
    }
    
    private func showAnimation() {
        for graphLayer in graphLayers {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = animationDuration
            animation.fromValue = 0
            animation.toValue = 1
            graphLayer.add(animation, forKey: nil)
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
        precondition(numberOfXAxisLabel > 1, "numberOfXAxisLabel is less than 2")
        precondition(xAxisMinValue < xAxisMaxValue, "xAxisMaxValue is less than or eqaul to xAxisMinValue")
        precondition(yAxisMinValue < yAxisMaxValue, "yAxisMaxValue is less than or eqaul to yAxisMinValue")
        yLabels = makeYAxisLabels()
        xLabels = makeXAxisLabels()
        prepareXAxisTitleLabel()
        prepareYAxisTitleLabel()
        settingAxisViewFrame()
        prepareYLabels()
        prepareXLabels()
        if isHorizontalLine {
            yLabels.forEach {
                prepareGraphLineLayers(positionY: $0.center.y)
            }
        }
        prepareGraphLayers(sections:sections)
        for section in 0..<sections {
            var values = [AMScatterValue]()
            let rows = dataSource.scatterChartView(self, numberOfRowsInSection: section)
            for row in 0..<rows {
                values.append(dataSource.scatterChartView(self, valueForRowAtIndexPath: .init(row:row, section: section)))
            }
            let pointType = dataSource.scatterChartView(self, pointTypeForSection: section)
            let graphLayer = graphLayers[section]
            setGraphLayerColor(graphLayer, color: dataSource.scatterChartView(self, colorForSection: section), pointType: pointType)
            graphLayer.path = makeAnimationPath(graphLayer, values: values, pointType: pointType).cgPath
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
        
        graphLayers.forEach { $0.removeFromSuperlayer() }
        graphLayers.removeAll()
    }
}
