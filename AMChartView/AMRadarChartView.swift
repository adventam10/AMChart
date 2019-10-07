//
//  AMRadarChartView.swift
//  AMChart, https://github.com/adventam10/AMChart
//
//  Created by am10 on 2018/01/02.
//  Copyright © 2018年 am10. All rights reserved.
//

import UIKit

public enum AMRCDecimalFormat {
    case none
    case first
    case second
}

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

public class AMRadarChartView: UIView {

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
    public var axisDecimalFormat: AMRCDecimalFormat = .none
    public var animationDuration: CFTimeInterval = 0.6
    
    override public var bounds: CGRect {
        didSet {
            reloadData()
        }
    }
    
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
        addSubview(chartView)
        chartView.addSubview(axisView)
        chartView.addSubview(graphView)
    }
    
    override public func draw(_ rect: CGRect) {
        reloadData()
    }
    
    // MARK:- Draw
    private func settingChartViewFrame() {
        let length = (frame.height < frame.width) ? frame.height : frame.width
        
        chartView.frame = CGRect(x: frame.width/2 - length/2,
                                 y: frame.height/2 - length/2,
                                 width: length,
                                 height: length)
        axisView.frame = chartView.bounds
        graphView.frame = chartView.bounds
    }
    
    private func prepareRadarChartLayer(rows: Int) {
        radarChartLayer = CAShapeLayer()
        guard let radarChartLayer = radarChartLayer else {
            return
        }
        
        radarChartLayer.lineWidth = axisWidth
        let height = chartView.frame.height - (space*2) - (rowLabelHeight*2)
        let width = chartView.frame.width - (space*2) - (rowLabelWidth*2)
        let length = (height < width) ? height : width
        radarChartLayer.frame = CGRect(x: chartView.frame.width/2 - length/2,
                                       y: chartView.frame.height/2 - length/2,
                                       width: length,
                                       height: length)
        axisView.layer.addSublayer(radarChartLayer)
        radarChartLayer.strokeColor = axisColor.cgColor
        radarChartLayer.fillColor = UIColor.clear.cgColor
        let radius = length/2
        let centerPoint = CGPoint(x: length/2, y: length/2)
        let path = UIBezierPath()
        path.move(to: centerPoint)
        var angle:Float = Float(Double.pi/2 + Double.pi)

        for _ in 0..<rows {
            let point = CGPoint(x: centerPoint.x + radius * CGFloat(cosf(angle)),
                                y: centerPoint.y + radius * CGFloat(sinf(angle)))
            
            path.addLine(to: point)
            path.move(to: centerPoint)
            angleList.append(angle)
            angle +=  Float(Double.pi*2) / Float(rows)
        }
        
        var drawRadius = radius
        for _ in 0..<numberOfAxisLabel {
            var startPoint = CGPoint.zero
            var angle:Float = Float(Double.pi/2 + Double.pi)
            for row in 0..<rows {
                let point = CGPoint(x: centerPoint.x + drawRadius * CGFloat(cosf(angle)),
                                    y: centerPoint.y + drawRadius * CGFloat(sinf(angle)))
                if row == 0 {
                    path.move(to: point)
                    startPoint = point
                } else {
                    path.addLine(to: point)
                }
                
                angle +=  Float(Double.pi*2) / Float(rows)
            }
            path.addLine(to: startPoint)
            drawRadius -= radius/CGFloat(numberOfAxisLabel - 1)
        }
        
        radarChartLayer.path = path.cgPath
        radarChartLayer.cornerRadius = radius
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
            graphLayer.lineJoin = CAShapeLayerLineJoin.round
            graphLayer.lineCap = CAShapeLayerLineCap.round
            graphLayer.lineDashPattern = (isDottedLine) ? [5, 6] : nil
        }
    }
    
    private func prepareRowLabels() {
        guard let radarChartLayer = radarChartLayer else {
            return
        }
        
        let radius = radarChartLayer.frame.width/2
        let centerPoint = CGPoint(x: radarChartLayer.frame.origin.x + radius,
                                  y: radarChartLayer.frame.origin.y + radius)
        
        for angle in angleList {
            let label = UILabel(frame:CGRect(x: 0,
                                             y: 0,
                                             width: rowLabelWidth,
                                             height: rowLabelHeight))
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .center
            label.font = rowLabelsFont
            label.textColor = rowLabelsTextColor
            let point = CGPoint(x: centerPoint.x + (radius + rowLabelHeight) * CGFloat(cosf(angle)),
                                y: centerPoint.y + (radius + rowLabelHeight) * CGFloat(sinf(angle)))
            label.center = point
            rowLabels.append(label)
            chartView.addSubview(label)
        }
    }
    
    private func prepareAxisLabels() {
        guard let radarChartLayer = radarChartLayer else {
            return
        }
        
        let radius = radarChartLayer.frame.width/2
        let centerPoint = CGPoint(x: radarChartLayer.frame.origin.x + radius,
                                  y: radarChartLayer.frame.origin.y + radius)
        var drawRadius = radius
        let angle = angleList.first!
        let width = axisLabelsWidth
        let height = radius / CGFloat(numberOfAxisLabel)
        let valueCount = CGFloat(axisMaxValue - axisMinValue) /  CGFloat(numberOfAxisLabel - 1)
        var value = axisMaxValue
        
        for _ in 0..<numberOfAxisLabel {
            let point = CGPoint(x: centerPoint.x + drawRadius * CGFloat(cosf(angle)),
                                y: centerPoint.y + drawRadius * CGFloat(sinf(angle)))
            
            let label = UILabel(frame:CGRect(x: point.x - width - space,
                                             y: point.y - height/2,
                                             width: width,
                                             height: height))
            
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .right
            label.font = axisLabelsFont
            label.textColor = axisLabelsTextColor
            
            var text = ""
            switch axisDecimalFormat {
            case .none:
                text = NSString(format: "%.0f", value) as String
            case .first:
                text = NSString(format: "%.1f", value) as String
            case .second:
                text = NSString(format: "%.2f", value) as String
            }
            
            label.text = text
            axisLabels.append(label)
            chartView.addSubview(label)
            drawRadius -= radius/CGFloat(numberOfAxisLabel - 1)
            value -= valueCount
        }
    }
    
    private func prepareGraphLayers(section: Int,
                                    rows: Int,
                                    fillColor: UIColor,
                                    strokeColor: UIColor,
                                    values: [CGFloat]) {
        guard let radarChartLayer = radarChartLayer else {
            return
        }
        
        let layer = graphLayers[section]
        layer.fillColor = fillColor.cgColor
        layer.strokeColor = strokeColor.cgColor
        let radius = radarChartLayer.frame.width/2
        layer.cornerRadius = radius
        
        let centerPoint = CGPoint(x: radius, y: radius)
        let path = UIBezierPath()
        let startPath = UIBezierPath()
        var startPoint = CGPoint.zero
        
        for row in 0..<rows {
            let angle = angleList[row]
            let rate = values[row] / (axisMaxValue - axisMinValue)
            let point = CGPoint(x: centerPoint.x + (radius * rate) * CGFloat(cosf(angle)),
                                y: centerPoint.y + (radius * rate) * CGFloat(sinf(angle)))
            if row == 0 {
                path.move(to: point)
                startPath.move(to: centerPoint)
                startPoint = point
            } else {
                path.addLine(to: point)
                startPath.addLine(to: centerPoint)
            }
        }
        path.addLine(to: startPoint)
        startPath.move(to: centerPoint)
        
        if (layer.path == nil) {
            layer.path = startPath.cgPath
        }
        animationPaths.append(path)
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
    
    private func clearView() {
        axisLabels.forEach { $0.removeFromSuperview() }
        axisLabels.removeAll()
        
        rowLabels.forEach { $0.removeFromSuperview() }
        rowLabels.removeAll()
        
        radarChartLayer?.removeFromSuperlayer()
        radarChartLayer = nil
        angleList.removeAll()
    }
    
    // MARK:- Reload
    public func reloadData() {
        clearView()
        settingChartViewFrame()
        guard let dataSource = dataSource else {
            return
        }
        
        let sections = dataSource.numberOfSections(in: self)
        let rows = dataSource.numberOfRows(in: self)
        
        if (rows < 3) {
            return
        }
        
        prepareRadarChartLayer(rows:rows)
        prepareGraphLayers(sections:sections)
        prepareRowLabels()
        prepareAxisLabels()
        
        for section in 0..<sections {
            var values = [CGFloat]()
            for row in 0..<rows {
                if section == 0 {
                    let label = rowLabels[row]
                    label.text = dataSource.radarChartView(radarChartView: self,
                                                           titleForXlabelInRow: row)
                }
                
                let indexPath = IndexPath(row:row, section: section)
                let value = dataSource.radarChartView(self, valueForRowAtIndexPath: indexPath)
                values.append(value)
            }
            
            let fillColor = dataSource.radarChartView(self, fillColorForSection:section)
            let strokeColor = dataSource.radarChartView(self, strokeColorForSection:section)
            prepareGraphLayers(section:section,
                               rows:rows,
                               fillColor:fillColor,
                               strokeColor:strokeColor,
                               values:values)
        }
        
        showAnimation()
    }
    
    public func redrawChart() {
        graphLayers.forEach { $0.removeFromSuperlayer() }
        graphLayers.removeAll()
        reloadData()
    }
}
