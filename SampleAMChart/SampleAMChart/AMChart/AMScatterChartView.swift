//
//  AMScatterChartView.swift
//  TestProject
//
//  Created by am10 on 2018/01/02.
//  Copyright © 2018年 am10. All rights reserved.
//

import UIKit

enum AMSCDecimalFormat {
    case none // 小数なし
    case first // 小数第一位まで
    case second // 小数第二位まで
}

enum AMSCPointType {
    /// 丸（塗りつぶしなし）
    case type1
    /// 丸（塗りつぶしあり）
    case type2
    /// 四角（塗りつぶしなし）
    case type3
    /// 四角（塗りつぶしあり）
    case type4
    /// 三角（塗りつぶしなし）
    case type5
    /// 三角（塗りつぶしあり）
    case type6
    /// ひし形（塗りつぶしなし）
    case type7
    /// ひし形（塗りつぶしあり）
    case type8
    /// ×印
    case type9
}

struct AMSCScatterValue {
    
    var xValue : CGFloat = 0
    var yValue : CGFloat = 0
    
    init(x :CGFloat, y :CGFloat) {
        xValue = x
        yValue = y
    }
}

protocol AMScatterChartViewDataSource:class {
    
    func numberOfSections(inScatterChartView scatterChartView:AMScatterChartView) -> Int

    func scatterChartView(scatterChartView:AMScatterChartView, numberOfRowsInSection section: Int) -> Int
    
    func scatterChartView(scatterChartView:AMScatterChartView, valueForRowAtIndexPath indexPath: IndexPath) -> AMSCScatterValue
    
    func scatterChartView(scatterChartView:AMScatterChartView, colorForSection section: Int) -> UIColor

    func scatterChartView(scatterChartView:AMScatterChartView, pointTypeForSection section: Int) -> AMSCPointType
}

class AMScatterChartView: UIView {

    override var bounds: CGRect {
        
        didSet {
            
            reloadData()
        }
    }
    
    /// 上下左右の余白
    private let space:CGFloat = 10
    
    /// 点の半径
    private let pointRadius:CGFloat = 5
    
    weak var dataSource : AMScatterChartViewDataSource?
    /// y軸の最大値
    @IBInspectable var yAxisMaxValue:CGFloat = 1000
    
    /// y軸の最小値
    @IBInspectable var yAxisMinValue:CGFloat = 0
    
    /// y軸ラベルの数
    @IBInspectable var numberOfYAxisLabel:Int = 6
    
    /// y軸のタイトル
    @IBInspectable var yAxisTitle:String = "" {
        
        didSet {
            
            yAxisTitleLabel.text = yAxisTitle
        }
    }
    
    /// x軸の最大値
    @IBInspectable var xAxisMaxValue:CGFloat = 1000
    
    /// x軸の最小値
    @IBInspectable var xAxisMinValue:CGFloat = 0
    
    /// x軸ラベルの数
    @IBInspectable var numberOfXAxisLabel:Int = 6
    
    /// x軸のタイトル
    @IBInspectable var xAxisTitle:String = "" {
        
        didSet {
            
            xAxisTitleLabel.text = xAxisTitle
        }
    }
    
    /// y軸ラベルの幅
    @IBInspectable var yLabelWidth:CGFloat = 50.0
    
    /// x軸ラベルの高さ
    @IBInspectable var xLabelHeight:CGFloat = 30.0
    
    /// 軸の色
    @IBInspectable var axisColor:UIColor = UIColor.black
    
    /// 軸の太さ
    @IBInspectable var axisWidth:CGFloat = 1.0
    
    /// y軸のタイトルのフォント
    @IBInspectable var yAxisTitleFont:UIFont = UIFont.systemFont(ofSize: 15)
    
    /// x軸のタイトルのフォント
    @IBInspectable var xAxisTitleFont:UIFont = UIFont.systemFont(ofSize: 15)
    
    /// x軸のタイトルラベルの高さ
    @IBInspectable var xAxisTitleLabelHeight:CGFloat = 50.0
    
    /// y軸のタイトルラベルの高さ
    @IBInspectable var yAxisTitleLabelHeight:CGFloat = 50.0
    
    /// y軸ラベルのフォント
    @IBInspectable var yLabelsFont:UIFont = UIFont.systemFont(ofSize: 15)
    
    /// x軸ラベルのフォント
    @IBInspectable var xLabelsFont:UIFont = UIFont.systemFont(ofSize: 15)
    
    /// y軸のタイトルの文字色
    @IBInspectable var yAxisTitleColor:UIColor = UIColor.black
    
    /// x軸のタイトルの文字色
    @IBInspectable var xAxisTitleColor:UIColor = UIColor.black
    
    /// y軸ラベルの文字色
    @IBInspectable var yLabelsTextColor:UIColor = UIColor.black
    
    /// x軸ラベルの文字色
    @IBInspectable var xLabelsTextColor:UIColor = UIColor.black
    
    /// y軸の値の小数点以下の表記
    var yAxisDecimalFormat:AMSCDecimalFormat = .none
    
    /// x軸の値の小数点以下の表記
    var xAxisDecimalFormat:AMSCDecimalFormat = .none
    
    /// アニメーション時間
    var animationDuration:CFTimeInterval = 0.6
    
    /// x軸
    private let xAxisView = UIView()
    
    /// y軸
    private let yAxisView = UIView()
    
    /// x軸ラベルリスト
    private var xLabels = [UILabel]()
    
    /// y軸ラベルリスト
    private var yLabels = [UILabel]()
    
    /// グラフレイヤーリスト
    private var graphLayers = [CAShapeLayer]()
    
    /// x軸のタイトルラベル
    private let xAxisTitleLabel = UILabel()
    
    /// y軸のタイトルラベル
    private let yAxisTitleLabel = UILabel()
    
    /// グラフの横線リスト
    private var horizontalLineLayers = [CALayer]()
    
    /// グラフレイヤ
    private var graphLayer = CALayer()
    
    //MARK:Initialize
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder:aDecoder)
        initView()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        initView()
    }
    
    convenience init() {
        
        self.init(frame: CGRect.zero)
    }
    
    private func initView() {
        
        // y軸設定
        addSubview(yAxisView)
        yAxisTitleLabel.textAlignment = .right
        yAxisTitleLabel.adjustsFontSizeToFitWidth = true
        yAxisTitleLabel.numberOfLines = 0
        addSubview(yAxisTitleLabel)
        
        // x軸設定
        addSubview(xAxisView)
        xAxisTitleLabel.textAlignment = .center
        xAxisTitleLabel.adjustsFontSizeToFitWidth = true
        xAxisTitleLabel.numberOfLines = 0
        addSubview(xAxisTitleLabel)
        
        layer.addSublayer(graphLayer)
    }
    
    override func draw(_ rect: CGRect) {
        
        reloadData()
    }
    
    func reloadData() {
        
        clearView()
        settingAxisViewFrame()
        settingAxisTitleLayout()
        prepareYLabels()
        prepareXLabels()
        
        guard let dataSource = dataSource else {
            
            return
        }
        
        let sections = dataSource.numberOfSections(inScatterChartView: self)
        prepareGraphLayers(sections:sections)
        
        for section in 0..<sections {
            
            var values = [AMSCScatterValue]()
            let rows = dataSource.scatterChartView(scatterChartView: self, numberOfRowsInSection: section)
            for row in 0..<rows {
                
                let indexPath = IndexPath(row:row, section: section)
                let value = dataSource.scatterChartView(scatterChartView: self, valueForRowAtIndexPath: indexPath)
                values.append(value)
            }
            let pointType = dataSource.scatterChartView(scatterChartView: self, pointTypeForSection: section)
            let color = dataSource.scatterChartView(scatterChartView: self, colorForSection: section)
            prepareGraph(section: section,
                         color: color,
                         values: values,
                         pointType: pointType)
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
        
        graphLayers.forEach {$0.removeFromSuperlayer()}
        graphLayers.removeAll()
    }
    
    private func settingAxisViewFrame() {
        
        let a = (frame.height - space - yAxisTitleLabelHeight - space - xLabelHeight - xAxisTitleLabelHeight)
        let b = CGFloat(numberOfYAxisLabel - 1)
        var yLabelHeight = (a / b) * 0.6
        if yLabelHeight.isNaN {
            
            yLabelHeight = 0
        }
        
        // y軸設定
        yAxisView.frame = CGRect(x: space + yLabelWidth,
                                 y: space + yAxisTitleLabelHeight + yLabelHeight/2,
                                 width: axisWidth,
                                 height: frame.height - (space + yAxisTitleLabelHeight + yLabelHeight/2) - space - xLabelHeight - xAxisTitleLabelHeight)
        yAxisTitleLabel.frame = CGRect(x: space,
                                       y: space,
                                       width: yLabelWidth - space,
                                       height: yAxisTitleLabelHeight)
        
        // x軸設定
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
            
            if yAxisDecimalFormat == .none {
                
                yLabel.text = NSString(format: "%.0f", value) as String
                
            } else if yAxisDecimalFormat == .first {
                
                yLabel.text = NSString(format: "%.1f", value) as String
                
            } else if yAxisDecimalFormat == .second {
                
                yLabel.text = NSString(format: "%.2f", value) as String
            }
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
            
            if xAxisDecimalFormat == .none {
                
                xLabel.text = NSString(format: "%.0f", value) as String
                
            } else if xAxisDecimalFormat == .first {
                
                xLabel.text = NSString(format: "%.1f", value) as String
                
            } else if xAxisDecimalFormat == .second {
                
                xLabel.text = NSString(format: "%.2f", value) as String
            }
            
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
        
        graphLayers.forEach {$0.frame = graphLayer.bounds}
    }
    
    private func prepareGraph(section: Int,
                              color: UIColor,
                              values: [AMSCScatterValue],
                              pointType: AMSCPointType) {
        
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
                                 pointType: AMSCPointType) -> UIBezierPath {
        
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
