//
//  AMRadarChartView.swift
//  AMChart, https://github.com/adventam10/AMChart
//
//  Created by am10 on 2018/01/02.
//  Copyright © 2018年 am10. All rights reserved.
//

import UIKit

public protocol AMRadarChartViewDataSource: AnyObject {
    func numberOfSections(in radarChartView: AMRadarChartView) -> Int
    func numberOfRows(in radarChartView: AMRadarChartView) -> Int
    func radarChartView(_ radarChartView: AMRadarChartView, valueForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    func radarChartView(_ radarChartView: AMRadarChartView, fillColorForSection section: Int) -> UIColor
    func radarChartView(_ radarChartView: AMRadarChartView, strokeColorForSection section: Int) -> UIColor
    func radarChartView(_ radarChartView: AMRadarChartView, titleForXlabelInRow row: Int) -> String
}

extension AMRadarChartViewDataSource {
    func radarChartView(radarChartView: AMRadarChartView,
                        titleForXlabelInRow row: Int) -> String {
        return ""
    }
}

public class AMRadarChartView: AMChartView {

    @IBInspectable public var axisMaxValue: CGFloat = 5.0
    @IBInspectable public var axisMinValue: CGFloat = 0.0
    @IBInspectable public var numberOfAxisLabel: Int = 6
    @IBInspectable public var rowLabelWidth: CGFloat = 50.0
    @IBInspectable public var rowLabelHeight: CGFloat = 30.0
    @IBInspectable public var axisColor: UIColor = .black
    @IBInspectable public var axisWidth: CGFloat = 1.0
    @IBInspectable public var axisLabelsFont: UIFont = .systemFont(ofSize: 12)
    @IBInspectable public var axisLabelsWidth: CGFloat = 50.0
    @IBInspectable public var rowLabelsFont: UIFont = .systemFont(ofSize: 15)
    @IBInspectable public var axisLabelsTextColor: UIColor = .black
    @IBInspectable public var rowLabelsTextColor: UIColor = .black
    @IBInspectable public var isDottedLine: Bool = false
    
    weak public var dataSource: AMRadarChartViewDataSource?
    public var axisDecimalFormat: AMDecimalFormat = .none
    public var animationDuration: CFTimeInterval = 0.6
    
    private let space: CGFloat = 10
    private let borderLineWidth: CGFloat = 3.5
    private let chartView = UIView()
    private let axisView = UIView()
    private let graphView = UIView()
    
    private var rowLabels = [UILabel]()
    private var axisLabels = [UILabel]()
    private var graphLayers = [CAShapeLayer]()
    private var radarChartLayer:CAShapeLayer?
    private var angleList = [Float]()
    private var animationPaths = [UIBezierPath]()
    private var radius: CGFloat {
        if let radarChartLayer = radarChartLayer {
            return radarChartLayer.frame.size.width / 2
        }
        let height = chartView.frame.height - (space*2) - (rowLabelHeight*2)
        let width = chartView.frame.width - (space*2) - (rowLabelWidth*2)
        let length = (height < width) ? height : width
        return length / 2
    }
    private var chartCenter: CGPoint {
        return chartView.center
    }
    
    override public func initView() {
        addSubview(chartView)
        chartView.addSubview(axisView)
        chartView.addSubview(graphView)
    }
    
    // MARK:- Prepare View
    private func settingChartViewFrame() {
        let length = (frame.height < frame.width) ? frame.height : frame.width
        chartView.frame = CGRect(x: frame.width/2 - length/2, y: frame.height/2 - length/2,
                                 width: length, height: length)
        axisView.frame = chartView.bounds
        graphView.frame = chartView.bounds
    }
    
    private func prepareRowLabels() {
        for angle in angleList {
            let label = UILabel(frame:CGRect(x: 0, y: 0, width: rowLabelWidth, height: rowLabelHeight))
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .center
            label.font = rowLabelsFont
            label.textColor = rowLabelsTextColor
            label.center = CGPoint(x: chartCenter.x + (radius + rowLabelHeight) * CGFloat(cosf(angle)),
                                   y: chartCenter.y + (radius + rowLabelHeight) * CGFloat(sinf(angle)))
            rowLabels.append(label)
            chartView.addSubview(label)
        }
    }
    
    private func prepareAxisLabels() {
        let angle = angleList.first!
        let width = axisLabelsWidth
        let height = radius / CGFloat(numberOfAxisLabel)
        let valueCount = CGFloat(axisMaxValue - axisMinValue) /  CGFloat(numberOfAxisLabel - 1)
        var value = axisMaxValue
        var drawRadius = radius
        for _ in 0..<numberOfAxisLabel {
            let point = CGPoint(x: chartCenter.x + drawRadius * CGFloat(cosf(angle)),
                                y: chartCenter.y + drawRadius * CGFloat(sinf(angle)))
            let label = UILabel(frame:CGRect(x: point.x - width - space, y: point.y - height/2,
                                             width: width, height: height))
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .right
            label.font = axisLabelsFont
            label.textColor = axisLabelsTextColor
            label.text = axisDecimalFormat.formattedValue(value)
            axisLabels.append(label)
            chartView.addSubview(label)
            drawRadius -= radius/CGFloat(numberOfAxisLabel - 1)
            value -= valueCount
        }
    }
    
    // MARK:- ChartLayers
    private func makeRadarChartLayer() -> CAShapeLayer {
        let radarChartLayer = CAShapeLayer()
        radarChartLayer.lineWidth = axisWidth
        radarChartLayer.frame = CGRect(x: chartView.frame.width/2 - radius,
                                       y: chartView.frame.height/2 - radius,
                                       width: radius*2, height: radius*2)
        radarChartLayer.strokeColor = axisColor.cgColor
        radarChartLayer.fillColor = UIColor.clear.cgColor
        radarChartLayer.path = makeRadarChartPath().cgPath
        radarChartLayer.cornerRadius = radius
        return radarChartLayer
    }
    
    private func makeRadarChartPath() -> UIBezierPath {
        let centerPoint = CGPoint(x: radius, y: radius)
        func point(radius: CGFloat, angle: Float) -> CGPoint {
            return .init(x: centerPoint.x + radius * CGFloat(cosf(angle)), y: centerPoint.y + radius * CGFloat(sinf(angle)))
        }
        let path = UIBezierPath()
        path.move(to: centerPoint)
        angleList.forEach {
            path.addLine(to: point(radius: radius, angle: $0))
            path.move(to: centerPoint)
        }
        
        var drawRadius = radius
        for _ in 0..<numberOfAxisLabel {
            let startPoint = point(radius: drawRadius, angle: angleList.first!)
            path.move(to: startPoint)
            angleList[1..<angleList.count].forEach {
                path.addLine(to: point(radius: drawRadius, angle: $0))
            }
            path.addLine(to: startPoint)
            drawRadius -= radius/CGFloat(numberOfAxisLabel - 1)
        }
        return path
    }
    
    private func makeAngleList(rows: Int) -> [Float] {
        var angle = Float(Double.pi/2 + Double.pi)
        var angleList = [Float]()
        for _ in 0..<rows {
            angleList.append(angle)
            angle +=  Float(Double.pi*2) / Float(rows)
        }
        return angleList
    }
    
    private func prepareGraphLayers(sections: Int) {
        while graphLayers.count < sections {
            let graphLayer = CAShapeLayer()
            graphView.layer.addSublayer(graphLayer)
            graphLayers.append(graphLayer)
        }
        
        while graphLayers.count > sections {
            let graphLayer = graphLayers.last
            graphLayer?.removeFromSuperlayer()
            graphLayers.removeLast()
        }
        
        guard let radarChartLayer = radarChartLayer else {
            return
        }
        
        for graphLayer in graphLayers {
            graphLayer.frame = radarChartLayer.frame
            graphLayer.lineWidth = borderLineWidth
            graphLayer.lineJoin = .round
            graphLayer.lineCap = .round
            graphLayer.lineDashPattern = isDottedLine ? [5, 6] : nil
        }
    }
    
    private func setGraphLayer(_ graphLayer: CAShapeLayer, path: UIBezierPath,
                                   fillColor: UIColor, strokeColor: UIColor) {
        graphLayer.fillColor = fillColor.cgColor
        graphLayer.strokeColor = strokeColor.cgColor
        graphLayer.cornerRadius = radius
        if graphLayer.path == nil {
            graphLayer.path = path.cgPath
        }
    }
    
    private func makeGraphPath(rows: Int, values: [CGFloat]) -> (start: UIBezierPath, animation: UIBezierPath) {
        let centerPoint = CGPoint(x: radius, y: radius)
        let animationPath = UIBezierPath()
        let startPath = UIBezierPath()
        var startPoint = CGPoint.zero
        for row in 0..<rows {
            let angle = angleList[row]
            let rate = values[row] / (axisMaxValue - axisMinValue)
            let point = CGPoint(x: centerPoint.x + (radius * rate) * CGFloat(cosf(angle)),
                                y: centerPoint.y + (radius * rate) * CGFloat(sinf(angle)))
            if row == 0 {
                animationPath.move(to: point)
                startPath.move(to: centerPoint)
                startPoint = point
            } else {
                animationPath.addLine(to: point)
                startPath.addLine(to: centerPoint)
            }
        }
        animationPath.addLine(to: startPoint)
        startPath.move(to: centerPoint)
        return (startPath, animationPath)
    }
    
    private func showAnimation() {
        for (index, graphLayer) in graphLayers.enumerated() {
            let animation = CABasicAnimation(keyPath: "path")
            animation.duration = animationDuration
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            animation.fromValue = UIBezierPath(cgPath: graphLayer.path!).cgPath
            animation.toValue = animationPaths[index].cgPath
            graphLayer.path = animationPaths[index].cgPath
            graphLayer.add(animation, forKey: nil)
        }
        animationPaths.removeAll()
    }
    
    // MARK:- Reload
    override public func reloadData() {
        clearView()
        settingChartViewFrame()
        guard let dataSource = dataSource else {
            return
        }
        
        let sections = dataSource.numberOfSections(in: self)
        let rows = dataSource.numberOfRows(in: self)
        if rows < 3 {
            return
        }
        
        angleList = makeAngleList(rows: rows)
        radarChartLayer = makeRadarChartLayer()
        axisView.layer.addSublayer(radarChartLayer!)
        prepareGraphLayers(sections: sections)
        prepareRowLabels()
        prepareAxisLabels()
        
        for section in 0..<sections {
            var values = [CGFloat]()
            for row in 0..<rows {
                if section == 0 {
                    rowLabels[row].text = dataSource.radarChartView(radarChartView: self, titleForXlabelInRow: row)
                }
                values.append(dataSource.radarChartView(self, valueForRowAtIndexPath: IndexPath(row:row, section: section)))
            }
            let paths = makeGraphPath(rows: rows, values: values)
            setGraphLayer(graphLayers[section], path: paths.start,
                          fillColor: dataSource.radarChartView(self, fillColorForSection:section),
                          strokeColor: dataSource.radarChartView(self, strokeColorForSection:section))
            animationPaths.append(paths.animation)
        }
        showAnimation()
    }
    
    public func redrawChart() {
        graphLayers.forEach { $0.removeFromSuperlayer() }
        graphLayers.removeAll()
        reloadData()
    }
    
    private func clearView() {
        axisLabels.forEach { $0.removeFromSuperview() }
        axisLabels.removeAll()
        
        rowLabels.forEach { $0.removeFromSuperview() }
        rowLabels.removeAll()
        
        radarChartLayer?.removeFromSuperlayer()
        radarChartLayer = nil
        angleList.removeAll()
    }
}
