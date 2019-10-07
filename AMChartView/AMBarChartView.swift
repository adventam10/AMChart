//
//  AMBarChartView.swift
//  AMChart, https://github.com/adventam10/AMChart
//
//  Created by am10 on 2018/01/02.
//  Copyright © 2018年 am10. All rights reserved.
//

import UIKit

public enum AMBCDecimalFormat {
    case none
    case first
    case second
}

public protocol AMBarChartViewDataSource: AnyObject {
    func numberOfSections(in barChartView: AMBarChartView) -> Int
    func barChartView(_ barChartView: AMBarChartView, numberOfRowsInSection section: Int) -> Int
    func barChartView(_ barChartView: AMBarChartView, valueForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    func barChartView(_ barChartView: AMBarChartView, colorForRowAtIndexPath indexPath: IndexPath) -> UIColor
    func barChartView(_ barChartView: AMBarChartView, titleForXlabelInSection section: Int) -> String
}

public class AMBarChartView: UIView {
    
    @IBInspectable public var yAxisMaxValue: CGFloat = 1000
    @IBInspectable public var yAxisMinValue: CGFloat = 0
    @IBInspectable public var numberOfYAxisLabel: Int = 6
    @IBInspectable public var yLabelWidth: CGFloat = 50.0
    @IBInspectable public var xLabelHeight: CGFloat = 30.0
    @IBInspectable public var axisColor: UIColor = .black
    @IBInspectable public var axisWidth: CGFloat = 1.0
    @IBInspectable public var barSpace: CGFloat = 10
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
    
    weak public var dataSource: AMBarChartViewDataSource?
    public var yAxisDecimalFormat: AMBCDecimalFormat = .none
    public var animationDuration: CFTimeInterval = 0.6
    
    override public var bounds: CGRect {
        didSet {
            reloadData()
        }
    }
    
    private let space: CGFloat = 10
    private let xAxisView = UIView()
    private let yAxisView = UIView()
    private var xLabels = [UILabel]()
    private var yLabels = [UILabel]()
    private var barLayers = [CALayer]()
    private let xAxisTitleLabel = UILabel()
    private let yAxisTitleLabel = UILabel()
    private var horizontalLineLayers = [CALayer]()
    private var graphLineLayers = [CAShapeLayer]()
    private var graphLineLayer = CALayer()
    
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
        
        graphLineLayer.masksToBounds = true
        layer.addSublayer(graphLineLayer)
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
        
        guard let dataSource = dataSource else {
            return
        }
        
        let sections = dataSource.numberOfSections(in: self)
        
        for section in 0..<sections {
            prepareXlabels(sections:sections, section:section)
            prepareBarLayers(section:section)
            
            let label = xLabels[section]
            label.text = dataSource.barChartView(self, titleForXlabelInSection: section)
            
            let rows = dataSource.barChartView(self, numberOfRowsInSection: section)
            var values = [CGFloat]()
            var colors = [UIColor]()
            for row in 0..<rows {
                let indexPath = IndexPath(row:row, section: section)
                let value = dataSource.barChartView(self, valueForRowAtIndexPath: indexPath)
                let color = dataSource.barChartView(self, colorForRowAtIndexPath: indexPath)
                values.append(value)
                colors.append(color)
            }
            
            prepareBarGraph(section: section, colors: colors, values: values)
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
        
        barLayers.forEach { $0.removeFromSuperlayer() }
        barLayers.removeAll()
        
        graphLineLayers.forEach { $0.removeFromSuperlayer() }
        graphLineLayers.removeAll()
    }
    
    private func settingAxisViewFrame() {
        let a = (frame.height - space - yAxisTitleLabelHeight - space - xLabelHeight - xAxisTitleLabelHeight)
        let b = CGFloat(numberOfYAxisLabel - 1)
        var yLabelHeight = (a / b) * 0.6
        if yLabelHeight.isNaN {
            yLabelHeight = 0
        }
        
        // Set Y axis
        yAxisView.frame = CGRect(x: space + yLabelWidth,
                                 y: space + yAxisTitleLabelHeight + yLabelHeight/2,
                                 width: axisWidth,
                                 height: frame.height - (space + yAxisTitleLabelHeight + yLabelHeight/2) - space - xLabelHeight - xAxisTitleLabelHeight)
        
        yAxisTitleLabel.frame = CGRect(x: space,
                                       y: space,
                                       width: yLabelWidth - space,
                                       height: yAxisTitleLabelHeight)
        
        // Set X axis
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
        
        graphLineLayer.frame = CGRect(x: yAxisView.frame.minX + axisWidth,
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
        if numberOfYAxisLabel == 0 {
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
            
            switch yAxisDecimalFormat {
            case .none:
                yLabel.text = NSString(format: "%.0f", value) as String
            case .first:
                yLabel.text = NSString(format: "%.1f", value) as String
            case .second:
                yLabel.text = NSString(format: "%.2f", value) as String
            }
            
            if isHorizontalLine {
                prepareGraphLineLayers(positionY:y + height/2)
            }
            y -= height + space
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
    
    private func prepareXlabels(sections: Int, section: Int) {
        if sections == 0 {
            return
        }
        
        let width = (xAxisView.frame.width - axisWidth - barSpace) / CGFloat(sections) - barSpace
        var x = xAxisView.frame.minX + axisWidth + (barSpace + width) * CGFloat(section)
        x += barSpace
        let y = xAxisView.frame.minY + axisWidth
        let xLabel = UILabel(frame:CGRect(x: x,
                                          y: y,
                                          width: width,
                                          height: xLabelHeight))
        xLabel.textAlignment = .center
        xLabel.adjustsFontSizeToFitWidth = true
        xLabel.numberOfLines = 0
        xLabel.font = xLabelsFont
        xLabel.textColor = xLabelsTextColor
        xLabel.tag = section
        xLabels.append(xLabel)
        addSubview(xLabel)
    }
    
    private func prepareBarLayers(section: Int) {
        let xLabel = xLabels[section]
        let barLayer = CALayer()
        barLayer.frame = CGRect(x: xLabel.frame.minX,
                                y: yAxisView.frame.minY,
                                width: xLabel.frame.width,
                                height: yAxisView.frame.height - axisWidth)
        barLayers.append(barLayer)
        layer.addSublayer(barLayer)
    }
    
    private func prepareBarGraph(section: Int, colors: [UIColor], values: [CGFloat]) {
        let sum = values.reduce(0, +)
        let barLayer = barLayers[section]
        barLayer.masksToBounds = true
        var frame = barLayer.frame
        frame.size.height = ((sum - yAxisMinValue) / (yAxisMaxValue - yAxisMinValue)) * barLayer.frame.height
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
}
