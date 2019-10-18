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
    @IBInspectable public var yLabelWidth: CGFloat = 50.0
    @IBInspectable public var xLabelHeight: CGFloat = 30.0
    @IBInspectable public var axisColor: UIColor = .black
    @IBInspectable public var axisWidth: CGFloat = 1.0
    @IBInspectable public var yAxisTitleFont: UIFont = .systemFont(ofSize: 15)
    @IBInspectable public var xAxisTitleFont: UIFont = .systemFont(ofSize: 15)
    @IBInspectable public var xAxisTitleLabelHeight: CGFloat = 50.0
    @IBInspectable public var yAxisTitleLabelHeight: CGFloat = 50.0
    @IBInspectable public var yLabelsFont: UIFont = .systemFont(ofSize: 15)
    @IBInspectable public var xLabelsFont: UIFont = .systemFont(ofSize: 15)
    @IBInspectable public var yAxisTitleColor: UIColor = .black
    @IBInspectable public var xAxisTitleColor: UIColor = .black
    @IBInspectable public var yLabelsTextColor: UIColor = .black
    @IBInspectable public var xLabelsTextColor: UIColor = .black
    @IBInspectable public var isHorizontalLine: Bool = false
    @IBInspectable public var yAxisTitle: String = "" {
        didSet {
            yAxisTitleLabel.text = yAxisTitle
        }
    }
    @IBInspectable public var xAxisTitle: String = "" {
        didSet {
            xAxisTitleLabel.text = xAxisTitle
        }
    }
    
    weak public var dataSource: AMLineChartViewDataSource?
    public var yAxisDecimalFormat: AMDecimalFormat = .none
    public var animationDuration: CFTimeInterval = 0.6
    
    private let space: CGFloat = 10
    private let pointRadius: CGFloat = 5
    private let xAxisView = UIView()
    private let yAxisView = UIView()
    private let xAxisTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()
    private let yAxisTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()
    
    private var xLabels = [UILabel]()
    private var yLabels = [UILabel]()
    private var graphLayers = [CAShapeLayer]()
    private var horizontalLineLayers = [CALayer]()
    private var animationPaths = [UIBezierPath]()
    
    override public func initView() {
        // Set Y axis
        addSubview(yAxisView)
        addSubview(yAxisTitleLabel)
        
        // Set X axis
        addSubview(xAxisView)
        addSubview(xAxisTitleLabel)
        backgroundColor = .red
    }
    
    // MARK:- Draw
    private func settingAxisViewFrame() {
        let a = (frame.height - space - yAxisTitleLabelHeight - space - xLabelHeight - xAxisTitleLabelHeight)
        let b = CGFloat(numberOfYAxisLabel - 1)
        var yLabelHeight = (a / b) * 0.6
        if yLabelHeight.isNaN {
            yLabelHeight = 0
        }
        // Set Y axis
        yAxisView.frame = CGRect(x: space + yLabelWidth, y: space + yAxisTitleLabelHeight  + yLabelHeight/2,
                                 width: axisWidth, height: frame.height - (space + yAxisTitleLabelHeight + yLabelHeight/2) - space - xLabelHeight - xAxisTitleLabelHeight)
        yAxisTitleLabel.frame = CGRect(x: space, y: space, width: yLabelWidth - space, height: yAxisTitleLabelHeight)
        
        // Set X axis
        xAxisView.frame = CGRect(x: yAxisView.frame.origin.x, y: yAxisView.frame.height + yAxisView.frame.origin.y,
                                 width: frame.width - yAxisView.frame.origin.x - space, height: axisWidth)
        xAxisTitleLabel.frame = CGRect(x: xAxisView.frame.origin.x, y: frame.height - xAxisTitleLabelHeight - space,
                                       width: xAxisView.frame.width, height: xAxisTitleLabelHeight)
        
        yAxisView.backgroundColor = axisColor
        xAxisView.backgroundColor = axisColor
    }
    
    private func settingAxisTitleLayout() {
        yAxisTitleLabel.font = yAxisTitleFont
        yAxisTitleLabel.textColor = yAxisTitleColor
        
        xAxisTitleLabel.font = xAxisTitleFont
        xAxisTitleLabel.textColor = xAxisTitleColor
    }
    
    private func prepareYLabels() {
        if numberOfYAxisLabel == 0 {
            return
        }
        
        let valueCount = (yAxisMaxValue - yAxisMinValue) / CGFloat(numberOfYAxisLabel - 1)
        var value = yAxisMinValue
        let height = (yAxisView.frame.height / CGFloat(numberOfYAxisLabel - 1)) * 0.6
        let space = (yAxisView.frame.height / CGFloat(numberOfYAxisLabel - 1)) * 0.4
        var y = xAxisView.frame.origin.y - height/2
        
        for index in 0..<numberOfYAxisLabel {
            let yLabel = UILabel(frame:CGRect(x: space, y: y,  width: yLabelWidth - space, height: height))
            yLabel.tag = index
            yLabels.append(yLabel)
            yLabel.textAlignment = .right
            yLabel.adjustsFontSizeToFitWidth = true
            yLabel.font = yLabelsFont
            yLabel.textColor = yLabelsTextColor
            yLabel.backgroundColor = .green
            addSubview(yLabel)
            yLabel.text = yAxisDecimalFormat.formattedValue(value)
            
            if isHorizontalLine {
                prepareGraphLineLayers(positionY:y + height/2)
            }
            y -= height + space
            value += valueCount
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
    
    private func prepareXlabels(rows: Int) {
        if rows == 0 {
            return
        }
        
        let width = (xAxisView.frame.size.width - axisWidth) / CGFloat(rows)
        for row in 0..<rows {
            let x = xAxisView.frame.origin.x + axisWidth + width * CGFloat(row)
            let y = xAxisView.frame.origin.y + axisWidth
            let xLabel = UILabel(frame: CGRect(x: x, y: y, width: width, height: xLabelHeight))
            xLabel.textAlignment = .center
            xLabel.adjustsFontSizeToFitWidth = true
            xLabel.numberOfLines = 0
            xLabel.font = xLabelsFont
            xLabel.textColor = xLabelsTextColor
            xLabel.tag = row
            xLabels.append(xLabel)
            xLabel.backgroundColor = .blue
            addSubview(xLabel)
        }
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
        settingAxisViewFrame()
        settingAxisTitleLayout()
        prepareYLabels()
        
        guard let dataSource = dataSource else {
            return
        }
        
        let sections = dataSource.numberOfSections(in: self)
        let rows = dataSource.numberOfRows(in: self)
        prepareXlabels(rows: rows)
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
        xAxisTitle = "AAA"
        yAxisTitle = "BBB"
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
