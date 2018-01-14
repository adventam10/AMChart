//
//  AMLineChartView.swift
//  TestProject
//
//  Created by am10 on 2018/01/02.
//  Copyright © 2018年 am10. All rights reserved.
//

import UIKit

enum AMLCDecimalFormat {
    case none // 小数なし
    case first // 小数第一位まで
    case second // 小数第二位まで
}

enum AMLCPointType {
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

protocol AMLineChartViewDataSource:class {
    
    func numberOfSections(inLineChartView lineChartView:AMLineChartView) -> Int
    
    func numberOfRows(inLineChartView:AMLineChartView) -> Int
    
    func lineChartView(lineChartView:AMLineChartView, valueForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    
    func lineChartView(lineChartView:AMLineChartView, colorForSection section: Int) -> UIColor
    
    func lineChartView(lineChartView:AMLineChartView, titleForXlabelInRow row: Int) -> String
    
    func lineChartView(lineChartView:AMLineChartView, pointTypeForSection section: Int) -> AMLCPointType
}


class AMLineChartView: UIView {

    override var bounds: CGRect {
        
        didSet {
            
            reloadData()
        }
    }
    
    /// 上下左右の余白
    private let space:CGFloat = 10

    /// 点の半径
    private let pointRadius:CGFloat = 5
    
    weak var dataSource : AMLineChartViewDataSource?
    
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
    var yAxisDecimalFormat:AMLCDecimalFormat = .none
    
    /// アニメーション時間
    var animationDuration:CFTimeInterval = 0.6
    
    /// 横線フラグ
    @IBInspectable var isHorizontalLine:Bool = false
    
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
    
    /// アニメーション用の折れ線グラフパスリスト
    private var animationPaths = [UIBezierPath]()
    
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
    }
    
    override func draw(_ rect: CGRect) {
        
        reloadData()
    }
    
    func reloadData() {
        
        clearView()
        settingAxisViewFrame()
        settingAxisTitleLayout()
        prepareYLabels()
        
        guard let dataSource = dataSource else {
            
            return
        }
        
        let sections = dataSource.numberOfSections(inLineChartView: self)
        let rows = dataSource.numberOfRows(inLineChartView: self)
        prepareXlabels(rows:rows)
        prepareGraphLayers(sections:sections)
        
        for section in 0..<sections {
            
            var values = [CGFloat]()
            for row in 0..<rows {
                
                if section == 0 {
                    
                    let label = xLabels[row];
                    label.text = dataSource.lineChartView(lineChartView: self, titleForXlabelInRow: row)
                }
                
                let indexPath = IndexPath(row:row, section: section)
                let value = dataSource.lineChartView(lineChartView: self, valueForRowAtIndexPath: indexPath)
                values.append(value)
            }
            
            let pointType = dataSource.lineChartView(lineChartView: self, pointTypeForSection: section)
            
            
            let color = dataSource.lineChartView(lineChartView: self, colorForSection: section)
            prepareLineGraph(section: section,
                             color: color,
                             values: values,
                             pointType: pointType)
        }
        
        showAnimation()
    }
    
    func reDrawGraph() {
        
        graphLayers.forEach{$0.removeFromSuperlayer()}
        graphLayers.removeAll()
        reloadData()
    }
    
    private func clearView() {
        
        xLabels.forEach{$0.removeFromSuperview()}
        xLabels.removeAll()
        
        yLabels.forEach{$0.removeFromSuperview()}
        yLabels.removeAll()
        
        horizontalLineLayers.forEach{$0.removeFromSuperlayer()}
        horizontalLineLayers.removeAll()
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
                                  y: space + yAxisTitleLabelHeight  + yLabelHeight/2,
                                  width: axisWidth,
                                  height: frame.height - (space + yAxisTitleLabelHeight + yLabelHeight/2) - space - xLabelHeight - xAxisTitleLabelHeight)
        
        yAxisTitleLabel.frame = CGRect(x: space,
                                       y: space,
                                       width: yLabelWidth - space,
                                       height: yAxisTitleLabelHeight)
        
        // x軸設定
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
            
            if yAxisDecimalFormat == .none {
                
                yLabel.text = NSString(format: "%.0f", value) as String
                
            } else if yAxisDecimalFormat == .first {
                
                yLabel.text = NSString(format: "%.1f", value) as String
                
            } else if yAxisDecimalFormat == .second {
                
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
        
        graphLayers.forEach{$0.frame = CGRect(x: yAxisView.frame.origin.x + axisWidth,
                                              y: yAxisView.frame.origin.y,
                                              width: xAxisView.frame.width - axisWidth,
                                              height: yAxisView.frame.height)}
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
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                animation.fromValue = UIBezierPath(cgPath: graphLayer.path!).cgPath
                animation.toValue = animationPath.cgPath
                graphLayer.path = animationPath.cgPath
                graphLayer.add(animation, forKey: nil)
            }
        }
        animationPaths.removeAll()
    }
}
