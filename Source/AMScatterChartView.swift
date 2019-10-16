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

public class AMScatterChartView: UIView {

    @IBInspectable public var yAxisMaxValue: CGFloat = 1000
    @IBInspectable public var yAxisMinValue: CGFloat = 0
    @IBInspectable public var numberOfYAxisLabel: Int = 6
    @IBInspectable public var xAxisMaxValue: CGFloat = 1000
    @IBInspectable public var xAxisMinValue: CGFloat = 0
    @IBInspectable public var numberOfXAxisLabel: Int = 6
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
    
    weak public var dataSource: AMScatterChartViewDataSource?
    public var yAxisDecimalFormat: AMDecimalFormat = .none
    public var xAxisDecimalFormat: AMDecimalFormat = .none
    public var animationDuration: CFTimeInterval = 0.6
    
    override public var bounds: CGRect {
        didSet {
            reloadData()
        }
    }
    
    private let xAxisView = UIView()
    private let yAxisView = UIView()
    private let xAxisTitleLabel = UILabel()
    private let yAxisTitleLabel = UILabel()
    private let space: CGFloat = 10
    private let pointRadius: CGFloat = 5
    
    private var xLabels = [UILabel]()
    private var yLabels = [UILabel]()
    private var graphLayers = [CAShapeLayer]()
    private var horizontalLineLayers = [CALayer]()
    private var graphLayer = CALayer()
    
    // MARK:- Initialize
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        initView()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        initView()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    private func initView() {
        // Set Y axis
        addSubview(yAxisView)
        yAxisTitleLabel.textAlignment = .right
        yAxisTitleLabel.adjustsFontSizeToFitWidth = true
        yAxisTitleLabel.numberOfLines = 0
        addSubview(yAxisTitleLabel)
        
        // Set X axis
        addSubview(xAxisView)
        xAxisTitleLabel.textAlignment = .center
        xAxisTitleLabel.adjustsFontSizeToFitWidth = true
        xAxisTitleLabel.numberOfLines = 0
        addSubview(xAxisTitleLabel)
        
        layer.addSublayer(graphLayer)
    }
    
    override public func draw(_ rect: CGRect) {
        reloadData()
    }
    
    // MARK:- Reload
    public func reloadData() {
        clearView()
        settingAxisViewFrame()
        settingAxisTitleLayout()
        prepareYLabels()
        prepareXLabels()
        
        guard let dataSource = dataSource else {
            return
        }
        
        let sections = dataSource.numberOfSections(in: self)
        prepareGraphLayers(sections:sections)
        
        for section in 0..<sections {
            var values = [AMScatterValue]()
            let rows = dataSource.scatterChartView(self, numberOfRowsInSection: section)
            for row in 0..<rows {
                let indexPath = IndexPath(row:row, section: section)
                let value = dataSource.scatterChartView(self, valueForRowAtIndexPath: indexPath)
                values.append(value)
            }
            let pointType = dataSource.scatterChartView(self, pointTypeForSection: section)
            let color = dataSource.scatterChartView(self, colorForSection: section)
            prepareGraph(section: section,
                         color: color,
                         values: values,
                         pointType: pointType)
        }
        showAnimation()
    }
    
    // MARK:- Draw
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
    
    private func settingAxisViewFrame() {
        let a = (frame.height - space - yAxisTitleLabelHeight - space - xLabelHeight - xAxisTitleLabelHeight)
        let b = CGFloat(numberOfYAxisLabel - 1)
        var yLabelHeight = (a / b) * 0.6
        if yLabelHeight.isNaN {
            yLabelHeight = 0
        }
        
        yAxisView.frame = CGRect(x: space + yLabelWidth,
                                 y: space + yAxisTitleLabelHeight + yLabelHeight/2,
                                 width: axisWidth,
                                 height: frame.height - (space + yAxisTitleLabelHeight + yLabelHeight/2) - space - xLabelHeight - xAxisTitleLabelHeight)
        yAxisTitleLabel.frame = CGRect(x: space,
                                       y: space,
                                       width: yLabelWidth - space,
                                       height: yAxisTitleLabelHeight)
        
        xAxisView.frame = CGRect(x: yAxisView.frame.minX,
                                 y: yAxisView.frame.maxY,
                                 width: frame.width - yAxisView.frame.minX - space,
                                 height: axisWidth)
        xAxisTitleLabel.frame = CGRect(x: xAxisView.frame.minX,
                                       y: frame.height - xAxisTitleLabelHeight - space,
                                       width: xAxisView.frame.width,
                                       height: xAxisTitleLabelHeight)
        
        yAxisView.backgroundColor = axisColor
        xAxisView.backgroundColor = axisColor
        
        graphLayer.frame = CGRect(x: yAxisView.frame.maxX,
                                  y: yAxisView.frame.minY,
                                  width: xAxisView.frame.width - axisWidth,
                                  height: yAxisView.frame.height)
    }
    
    private func settingAxisTitleLayout() {
        yAxisTitleLabel.font = yAxisTitleFont
        yAxisTitleLabel.textColor = yAxisTitleColor
        
        xAxisTitleLabel.font = xAxisTitleFont
        xAxisTitleLabel.textColor = xAxisTitleColor
    }
    
    private func prepareYLabels() {
        if numberOfYAxisLabel <= 0 {
            return
        }
        
        let valueCount = (yAxisMaxValue - yAxisMinValue) / CGFloat(numberOfYAxisLabel - 1)
        var value = yAxisMinValue
        let height = (yAxisView.frame.height / CGFloat(numberOfYAxisLabel - 1)) * 0.6
        let space = (yAxisView.frame.height / CGFloat(numberOfYAxisLabel - 1)) * 0.4
        var y = xAxisView.frame.minY - height/2
        
        for index in 0..<numberOfYAxisLabel {
            let yLabel = UILabel(frame:CGRect(x: space,
                                              y: y,
                                              width: yLabelWidth - space,
                                              height: height))
            yLabel.tag = index
            yLabels.append(yLabel)
            yLabel.textAlignment = .right
            yLabel.adjustsFontSizeToFitWidth = true
            yLabel.font = yLabelsFont
            yLabel.textColor = yLabelsTextColor
            addSubview(yLabel)
            yLabel.text = yAxisDecimalFormat.formattedValue(value)
            
            y -= height + space
            value += valueCount
        }
    }
    
    private func prepareXLabels() {
        if numberOfXAxisLabel <= 0 {
            return
        }
        
        let valueCount = (xAxisMaxValue - xAxisMinValue) / CGFloat(numberOfXAxisLabel - 1)
        var value = xAxisMinValue
        var width = (xAxisView.frame.width / CGFloat(numberOfXAxisLabel - 1)) * 0.6
        if width > (frame.width - xAxisView.frame.maxX)*2 {
            width = (frame.width - xAxisView.frame.maxX)*2
        }
        let space = (xAxisView.frame.width - (width*CGFloat(numberOfXAxisLabel - 1))) / CGFloat(numberOfXAxisLabel - 1)
        var x = xAxisView.frame.minX - width/2
        
        for index in 0..<numberOfXAxisLabel {
            let xLabel = UILabel(frame:CGRect(x: x,
                                              y: xAxisView.frame.maxY,
                                              width: width,
                                              height: xLabelHeight))
            
            xLabel.tag = index
            xLabels.append(xLabel)
            xLabel.textAlignment = .center
            xLabel.adjustsFontSizeToFitWidth = true
            xLabel.font = xLabelsFont
            xLabel.textColor = xLabelsTextColor
            addSubview(xLabel)
            xLabel.text = xAxisDecimalFormat.formattedValue(value)
            x += width + space
            value += valueCount
        }
    }
    
    private func prepareGraphLineLayers(positionY: CGFloat) {
        let lineLayer = CALayer()
        lineLayer.frame = CGRect(x: xAxisView.frame.minX,
                                 y: positionY,
                                 width: xAxisView.frame.width,
                                 height: 1)
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
    
    private func prepareGraph(section: Int,
                              color: UIColor,
                              values: [AMScatterValue],
                              pointType: AMPointType) {
        
        let graphLayer = graphLayers[section]
        graphLayer.strokeColor = color.cgColor
        
        if pointType == .type1 ||
            pointType == .type3 ||
            pointType == .type5 ||
            pointType == .type7 {
            graphLayer.fillColor = UIColor.clear.cgColor
        } else {
            graphLayer.fillColor = color.cgColor
        }
        
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
            path.append(createPointPath(centerPoint: point, pointType: pointType))
            path.move(to: point)
        }
        graphLayer.path = path.cgPath
    }
    
    private func createPointPath(centerPoint: CGPoint,
                                 pointType: AMPointType) -> UIBezierPath {
        if pointType == .type1 || pointType == .type2 {
            return UIBezierPath(ovalIn: CGRect(x: centerPoint.x - pointRadius,
                                               y: centerPoint.y - pointRadius,
                                               width: pointRadius * 2,
                                               height: pointRadius * 2))
        } else if pointType == .type3 || pointType == .type4 {
            return UIBezierPath(rect: CGRect(x: centerPoint.x - pointRadius,
                                             y: centerPoint.y - pointRadius,
                                             width: pointRadius * 2,
                                             height: pointRadius * 2))
        } else if pointType == .type5 || pointType == .type6 {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: centerPoint.x, y: centerPoint.y - pointRadius))
            path.addLine(to: CGPoint(x: centerPoint.x + pointRadius, y: centerPoint.y + pointRadius))
            path.addLine(to: CGPoint(x: centerPoint.x - pointRadius, y: centerPoint.y + pointRadius))
            path.close()
            return path
        } else if pointType == .type7 || pointType == .type8 {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: centerPoint.x, y: centerPoint.y - pointRadius))
            path.addLine(to: CGPoint(x: centerPoint.x + pointRadius, y: centerPoint.y))
            path.addLine(to: CGPoint(x: centerPoint.x , y: centerPoint.y + pointRadius))
            path.addLine(to: CGPoint(x: centerPoint.x - pointRadius, y: centerPoint.y))
            path.close()
            return path
        } else if pointType == .type9 {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: centerPoint.x - pointRadius, y: centerPoint.y - pointRadius))
            path.addLine(to: CGPoint(x: centerPoint.x + pointRadius, y: centerPoint.y + pointRadius))
            path.move(to: CGPoint(x: centerPoint.x + pointRadius, y: centerPoint.y - pointRadius))
            path.addLine(to: CGPoint(x: centerPoint.x - pointRadius, y: centerPoint.y + pointRadius))
            return path
        }
        
        return UIBezierPath(ovalIn: CGRect(x: centerPoint.x - pointRadius,
                                           y: centerPoint.y - pointRadius,
                                           width: pointRadius * 2,
                                           height: pointRadius * 2))
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
}
