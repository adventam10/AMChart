//
//  AMLineChartView.swift
//  AMChart, https://github.com/adventam10/AMChart
//
//  Created by am10 on 2018/01/02.
//  Copyright © 2018年 am10. All rights reserved.
//

import UIKit

public enum AMLCDecimalFormat {
    case none
    case first
    case second
}

public enum AMLCPointType {
    /// circle（not filled）
    case type1
    /// circle（filled）
    case type2
    /// square（not filled）
    case type3
    /// square（filled）
    case type4
    /// triangle（not filled）
    case type5
    /// triangle（filled）
    case type6
    /// diamond（not filled）
    case type7
    /// diamond（filled）
    case type8
    /// x mark
    case type9
}

public protocol AMLineChartViewDataSource: AnyObject {
    func numberOfSections(in lineChartView: AMLineChartView) -> Int
    func numberOfRows(in lineChartView: AMLineChartView) -> Int
    func lineChartView(_ lineChartView: AMLineChartView, valueForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    func lineChartView(_ lineChartView: AMLineChartView, colorForSection section: Int) -> UIColor
    func lineChartView(_ lineChartView: AMLineChartView, titleForXlabelInRow row: Int) -> String
    func lineChartView(_ lineChartView: AMLineChartView, pointTypeForSection section: Int) -> AMLCPointType
}

public class AMLineChartView: UIView {
    
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
    public var yAxisDecimalFormat: AMLCDecimalFormat = .none
    public var animationDuration: CFTimeInterval = 0.6
    
    override public var bounds: CGRect {
        didSet {
            reloadData()
        }
    }
    
    private let space: CGFloat = 10
    private let pointRadius: CGFloat = 5
    private let xAxisView = UIView()
    private let yAxisView = UIView()
    private let xAxisTitleLabel = UILabel()
    private let yAxisTitleLabel = UILabel()
    
    private var xLabels = [UILabel]()
    private var yLabels = [UILabel]()
    private var graphLayers = [CAShapeLayer]()
    private var horizontalLineLayers = [CALayer]()
    private var animationPaths = [UIBezierPath]()
    
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
        let rows = dataSource.numberOfRows(in: self)
        prepareXlabels(rows:rows)
        prepareGraphLayers(sections:sections)
        
        for section in 0..<sections {
            var values = [CGFloat]()
            for row in 0..<rows {
                if section == 0 {
                    let label = xLabels[row]
                    label.text = dataSource.lineChartView(self, titleForXlabelInRow: row)
                }
                
                let indexPath = IndexPath(row:row, section: section)
                let value = dataSource.lineChartView(self, valueForRowAtIndexPath: indexPath)
                values.append(value)
            }
            
            let pointType = dataSource.lineChartView(self, pointTypeForSection: section)
            
            let color = dataSource.lineChartView(self, colorForSection: section)
            prepareLineGraph(section: section,
                             color: color,
                             values: values,
                             pointType: pointType)
        }
        
        showAnimation()
    }
    
    public func redrawChart() {
        graphLayers.forEach { $0.removeFromSuperlayer() }
        graphLayers.removeAll()
        reloadData()
    }
    
    // MARK:- Draw
    private func clearView() {
        xLabels.forEach { $0.removeFromSuperview() }
        xLabels.removeAll()
        
        yLabels.forEach { $0.removeFromSuperview() }
        yLabels.removeAll()
        
        horizontalLineLayers.forEach { $0.removeFromSuperlayer() }
        horizontalLineLayers.removeAll()
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
                                  y: space + yAxisTitleLabelHeight  + yLabelHeight/2,
                                  width: axisWidth,
                                  height: frame.height - (space + yAxisTitleLabelHeight + yLabelHeight/2) - space - xLabelHeight - xAxisTitleLabelHeight)
        
        yAxisTitleLabel.frame = CGRect(x: space,
                                       y: space,
                                       width: yLabelWidth - space,
                                       height: yAxisTitleLabelHeight)
        
        // Set X axis
        xAxisView.frame = CGRect(x: yAxisView.frame.origin.x,
                                  y: yAxisView.frame.height + yAxisView.frame.origin.y,
                                  width: frame.width - yAxisView.frame.origin.x - space,
                                  height: axisWidth)
        
        xAxisTitleLabel.frame = CGRect(x: xAxisView.frame.origin.x,
                                        y: frame.height - xAxisTitleLabelHeight - space,
                                        width: xAxisView.frame.width,
                                        height: xAxisTitleLabelHeight)
        
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
        lineLayer.frame = CGRect(x: xAxisView.frame.origin.x,
                                 y: positionY,
                                 width: xAxisView.frame.width,
                                 height: 1)
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
            let xLabel = UILabel(frame:CGRect(x: x, y: y, width: width, height: xLabelHeight))
            xLabel.textAlignment = .center
            xLabel.adjustsFontSizeToFitWidth = true
            xLabel.numberOfLines = 0
            xLabel.font = xLabelsFont
            xLabel.textColor = xLabelsTextColor
            xLabel.tag = row
            xLabels.append(xLabel)
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
            $0.frame = CGRect(x: yAxisView.frame.origin.x + axisWidth,
                              y: yAxisView.frame.origin.y,
                              width: xAxisView.frame.width - axisWidth,
                              height: yAxisView.frame.height)
        }
    }
    
    private func prepareLineGraph(section: Int,
                                  color: UIColor,
                                  values: [CGFloat],
                                  pointType: AMLCPointType) {
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
        for (index, xLabel) in xLabels.enumerated() {
            let value = values[index]
            let x = xLabel.frame.origin.x + xLabel.frame.width/2 - (yAxisView.frame.origin.x + axisWidth)
            var y = graphLayer.frame.height - (((value - yAxisMinValue)/(yAxisMaxValue - yAxisMinValue)) * graphLayer.frame.height)
            if y.isNaN {
                y = 0
            }
            
            let pointPath = createPointPath(positionX: x, positionY: y, pointType: pointType)
            if index == 0 {
                path.append(pointPath)
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
                path.append(pointPath)
                path.move(to: CGPoint(x: x, y: y))
            }
        }
        
        animationPaths.append(path)
    }
    
    private func createPointPath(positionX: CGFloat,
                                  positionY: CGFloat,
                                  pointType: AMLCPointType) -> UIBezierPath {
        if pointType == .type1 || pointType == .type2 {
            return UIBezierPath(ovalIn: CGRect(x: positionX - pointRadius,
                                                    y: positionY - pointRadius,
                                                    width: pointRadius * 2,
                                                    height: pointRadius * 2))
        } else if pointType == .type3 || pointType == .type4 {
            return UIBezierPath(rect: CGRect(x: positionX - pointRadius,
                                                  y: positionY - pointRadius,
                                                  width: pointRadius * 2,
                                                  height: pointRadius * 2))
        } else if pointType == .type5 || pointType == .type6 {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: positionX, y: positionY - pointRadius))
            path.addLine(to: CGPoint(x: positionX + pointRadius, y: positionY + pointRadius))
            path.addLine(to: CGPoint(x: positionX - pointRadius, y: positionY + pointRadius))
            path.addLine(to: CGPoint(x: positionX, y: positionY - pointRadius))
            return path
        } else if pointType == .type7 || pointType == .type8 {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: positionX, y: positionY - pointRadius))
            path.addLine(to: CGPoint(x: positionX + pointRadius, y: positionY))
            path.addLine(to: CGPoint(x: positionX , y: positionY + pointRadius))
            path.addLine(to: CGPoint(x: positionX - pointRadius, y: positionY))
            path.addLine(to: CGPoint(x: positionX, y: positionY - pointRadius))
            return path
        } else if pointType == .type9 {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: positionX - pointRadius, y: positionY - pointRadius))
            path.addLine(to: CGPoint(x: positionX + pointRadius, y: positionY + pointRadius))
            path.move(to: CGPoint(x: positionX + pointRadius, y: positionY - pointRadius))
            path.addLine(to: CGPoint(x: positionX - pointRadius, y: positionY + pointRadius))
            return path
        }
        
        return UIBezierPath(ovalIn: CGRect(x: positionX - pointRadius,
                                           y: positionY - pointRadius,
                                           width: pointRadius * 2,
                                           height: pointRadius * 2))
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
}
