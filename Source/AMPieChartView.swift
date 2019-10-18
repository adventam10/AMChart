//
//  AMPieChartView.swift
//  AMChart, https://github.com/adventam10/AMChart
//
//  Created by am10 on 2018/01/02.
//  Copyright © 2018年 am10. All rights reserved.
//

import UIKit

public protocol AMPieChartViewDataSource: AnyObject {
    func numberOfSections(in pieChartView: AMPieChartView) -> Int
    func pieChartView(_ pieChartView: AMPieChartView, valueForSection section: Int) -> CGFloat
    func pieChartView(_ pieChartView: AMPieChartView, colorForSection section: Int) -> UIColor
}

public protocol AMPieChartViewDelegate: AnyObject {
    func pieChartView(_ pieChartView: AMPieChartView, didSelectSection section: Int)
    func pieChartView(_ pieChartView: AMPieChartView, didDeSelectSection section: Int)
}

private let animationSpace: CGFloat = 10
private let deSelectIndex: Int = -1

public class AMPieChartView: AMChartView {
    
    class FanLayer: CAShapeLayer {
        var index: Int = 0
        @objc var startAngle: Float = 0
        @objc var endAngle: Float = 0
        var value: CGFloat = 0
        var rate: CGFloat = 0
        var isDounut = false
        private var centerPoint: CGPoint {
            return CGPoint(x: bounds.midX, y: bounds.midY)
        }
        private var radius: CGFloat {
            return (frame.width - animationSpace * 2) / 2
        }
        private var dounutRadius: CGFloat {
            return radius / 2
        }
        override class func needsDisplay(forKey key: String) -> Bool {
            if key == #keyPath(endAngle) || key == #keyPath(startAngle) {
                return true
            }
            return super.needsDisplay(forKey: key)
        }
        
        override init() {
            super.init()
        }
        
        override init(layer: Any) {
            if let layer = layer as? FanLayer {
                startAngle = layer.startAngle
                endAngle = layer.endAngle
                isDounut = layer.isDounut
            }
            
            super.init(layer: layer)
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(in ctx: CGContext) {
            ctx.beginPath()
            if isDounut {
                ctx.move(to: .init(x: centerPoint.x + dounutRadius * CGFloat(cosf(startAngle)),
                                   y: centerPoint.y + dounutRadius * CGFloat(sinf(startAngle))))
            } else {
                ctx.move(to: CGPoint(x: centerPoint.x, y: centerPoint.y))
            }
            ctx.addLine(to: .init(x: centerPoint.x + radius * CGFloat(cosf(startAngle)),
                                  y: centerPoint.y + radius * CGFloat(sinf(startAngle))))
            ctx.addArc(center: centerPoint, radius: radius, startAngle: CGFloat(startAngle),
                       endAngle: CGFloat(endAngle), clockwise: false)
            if isDounut {
                ctx.addLine(to: .init(x: centerPoint.x + dounutRadius * CGFloat(cosf(endAngle)),
                                      y: centerPoint.y + dounutRadius * CGFloat(sinf(endAngle))))
                ctx.addArc(center: centerPoint, radius: dounutRadius, startAngle: CGFloat(endAngle),
                           endAngle: CGFloat(startAngle) + CGFloat(Double.pi * 2), clockwise: true)
            }
            ctx.closePath()
            ctx.setFillColor(fillColor!)
            ctx.drawPath(using: .fill)
        }
    }
    
    @IBInspectable public var isDounut: Bool = false
    @IBInspectable public var centerLabelFont: UIFont = .systemFont(ofSize: 15)
    @IBInspectable public var centerLabelTextColor: UIColor = .black
    @IBInspectable public var centerLabelText: String = "" {
        didSet {
            centerLabel.text = centerLabelText
        }
    }
    
    weak public var dataSource: AMPieChartViewDataSource?
    weak public var delegate: AMPieChartViewDelegate?
    public var animationDuration: CFTimeInterval = 0.4
    public var selectedAnimationDuration: CFTimeInterval = 0.3
    public var centerLabelAttribetedText: NSAttributedString? = nil {
        didSet {
            centerLabel.attributedText = centerLabelAttribetedText
        }
    }
    
    private let chartView = UIView()
    private let animationChartView = UIView()
    private var selectedIndex: Int = deSelectIndex
    private let centerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()
    private var fanLayers = [FanLayer]()
    private var animationFanLayers = [FanLayer]()
    private var animationStartAngles = [Float]()
    private var animationEndAngles = [Float]()
    private var radius: CGFloat {
        return (chartView.frame.width - animationSpace * 2)/2
    }
    private var dounutRadius: CGFloat {
        return radius / 2
    }
    
    override public func initView() {
        addSubview(animationChartView)
        addSubview(chartView)
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(self.tapAction(gesture:)))
        chartView.addGestureRecognizer(tap)
        addSubview(centerLabel)
    }
        
    // MARK:- Draw
    private func settingChartViewFrame() {
        let length = frame.width < frame.height ? frame.width : frame.height
        chartView.frame = CGRect(x: bounds.midX - length/2, y: bounds.midY - length/2,
                                 width: length, height: length)
        animationChartView.frame = chartView.frame
        chartView.isHidden = true
        animationChartView.isHidden = false
        
        centerLabel.frame = CGRect(x: 0, y: 0, width: dounutRadius*2, height: dounutRadius*2)
        centerLabel.font = centerLabelFont
        centerLabel.textColor = centerLabelTextColor
        centerLabel.layer.cornerRadius = dounutRadius
        centerLabel.layer.masksToBounds = true
        centerLabel.center = chartView.center
    }
    
    private func prepareFanLayers(sections: Int) {
        while fanLayers.count < sections {
            let fanLayer = FanLayer()
            let animfanLayer = FanLayer()
            animationChartView.layer.addSublayer(animfanLayer)
            chartView.layer.addSublayer(fanLayer)
            fanLayers.append(fanLayer)
            animationFanLayers.append(animfanLayer)
        }
        
        while fanLayers.count > sections {
            fanLayers.last?.removeFromSuperlayer()
            animationFanLayers.last?.removeFromSuperlayer()
            fanLayers.removeLast()
            animationFanLayers.removeLast()
        }
        
        for (index, fanLayer) in fanLayers.enumerated() {
            fanLayer.frame = chartView.bounds
            fanLayer.index = index
            animationFanLayers[index].index = index
            animationFanLayers[index].frame = chartView.bounds
        }
    }

    private func setFanLayers(colors: [UIColor], values: [CGFloat]) {
        let sum = values.reduce(0, +)
        var angle = Float(Double.pi/2 + Double.pi)
        for (index, fanLayer) in fanLayers.enumerated() {
            let rate = values[index] / sum
            fanLayer.fillColor = colors[index].cgColor
            fanLayer.value = values[index]
            fanLayer.rate = rate
            fanLayer.startAngle = angle
            fanLayer.endAngle = angle + Float(Double.pi*2) * Float(rate)
            fanLayer.isDounut = isDounut
            
            let animFanLayer = animationFanLayers[index]
            animFanLayer.fillColor = colors[index].cgColor
            animFanLayer.value = values[index]
            animFanLayer.rate = rate
            animFanLayer.isDounut = isDounut
            
            animationStartAngles.append(angle)
            animationEndAngles.append(angle + Float(Double.pi*2) * Float(rate))
            angle += Float(Double.pi*2) * Float(rate)
        }
    }
    
    private func makeFanLayerPath(center: CGPoint, startAngle: Float, endAngle: Float) -> UIBezierPath {
        let piePath = UIBezierPath()
        if isDounut {
            piePath.move(to: CGPoint(x: center.x + dounutRadius * CGFloat(cosf(startAngle)),
                                     y: center.y + dounutRadius * CGFloat(sinf(startAngle))))
        } else {
            piePath.move(to: center)
        }
        piePath.addLine(to: CGPoint(x: center.x + radius * CGFloat(cosf(startAngle)),
                                    y: center.y + radius * CGFloat(sinf(startAngle))))
        piePath.addArc(withCenter: center, radius: radius, startAngle: CGFloat(startAngle),
                       endAngle: CGFloat(endAngle), clockwise: true)
        if isDounut {
            piePath.addLine(to: CGPoint(x: center.x + dounutRadius * CGFloat(cosf(endAngle)),
                                        y: center.y + dounutRadius * CGFloat(sinf(endAngle))))
            if startAngle + Float(Double.pi*2) == endAngle {
                piePath.addArc(withCenter: center, radius: dounutRadius, startAngle: CGFloat(startAngle),
                               endAngle: CGFloat(endAngle), clockwise: false)
            } else {
                piePath.addArc(withCenter: center, radius: dounutRadius, startAngle: CGFloat(endAngle),
                               endAngle: CGFloat(startAngle) + CGFloat(Double.pi*2), clockwise: false)
            }
        }
        piePath.close()
        return piePath
    }
    
    private func showAnimation() {
        for (index ,animfanLayer) in animationFanLayers.enumerated() {
            CATransaction.begin()
            CATransaction.setCompletionBlock { [unowned self] in
                if animfanLayer.animation(forKey: "angleAnimation") != nil{
                    animfanLayer.removeAnimation(forKey: "angleAnimation")
                    self.animationComplete(index: index)
                }
            }
            
            let fanLayer = fanLayers[index]
            let animation1 = CABasicAnimation(keyPath: "startAngle")
            if fanLayer.path == nil {
                animation1.fromValue = Float(Double.pi/2 + Double.pi)
            } else {
                animation1.fromValue = animfanLayer.startAngle
            }
            animation1.toValue = animationStartAngles[index]
            
            let animation2 = CABasicAnimation(keyPath: "endAngle")
            if fanLayer.path == nil {
                animation2.fromValue = Float(Double.pi/2 + Double.pi)
            } else {
                animation2.fromValue = animfanLayer.endAngle
            }
            animation2.toValue = animationEndAngles[index]
            
            let group = CAAnimationGroup()
            group.duration = animationDuration
            group.repeatCount = 1
            group.isRemovedOnCompletion = false
            group.animations = [animation1, animation2]
            
            animfanLayer.startAngle = animationStartAngles[index]
            animfanLayer.endAngle = animationEndAngles[index]
            animfanLayer.add(group, forKey: "angleAnimation")
            CATransaction.commit()
        }
        animationStartAngles.removeAll()
        animationEndAngles.removeAll()
    }
    
    private func animationComplete(index: Int) {
        if index < fanLayers.count {
            let fanLayer = fanLayers[index]
            let path = makeFanLayerPath(center: .init(x: fanLayer.bounds.midX, y: fanLayer.bounds.midY),
                                        startAngle: fanLayer.startAngle, endAngle: fanLayer.endAngle)
            fanLayer.path = path.cgPath
            animationChartView.isHidden = true
            chartView.isHidden = false
        }
    }
    
    // MARK:- Select / Deselect
    private func makeAnimation(fromPath: UIBezierPath, toPath: UIBezierPath, duration: CFTimeInterval) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.fromValue = fromPath.cgPath
        animation.toValue = toPath.cgPath
        return animation
    }
    
    private func setDidSelectAnimation(fanLayer: FanLayer) {
        let centerPoint = CGPoint(x: fanLayer.bounds.midX, y: fanLayer.bounds.midY)
        let angle = (fanLayer.startAngle + fanLayer.endAngle) / 2
        let smallCenterPoint = CGPoint(x: centerPoint.x + animationSpace * CGFloat(cosf(angle)),
                                       y: centerPoint.y + animationSpace * CGFloat(sinf(angle)))
        let animationPath = makeFanLayerPath(center: smallCenterPoint, startAngle: fanLayer.startAngle, endAngle: fanLayer.endAngle)
        let startPath = UIBezierPath(cgPath: fanLayer.path!)
        let animation = makeAnimation(fromPath: startPath, toPath: animationPath, duration: selectedAnimationDuration)
        fanLayer.path = animationPath.cgPath
        fanLayer.add(animation, forKey:nil)
    }
    
    private func setDidDeselectAnimation(fanLayer: FanLayer) {
        let animationPath = makeFanLayerPath(center: .init(x: fanLayer.bounds.midX, y: fanLayer.bounds.midY),
                                             startAngle: fanLayer.startAngle, endAngle: fanLayer.endAngle)
        let startPath = UIBezierPath(cgPath: fanLayer.path!)
        let animation = makeAnimation(fromPath: startPath, toPath: animationPath, duration: selectedAnimationDuration)
        fanLayer.path = animationPath.cgPath
        fanLayer.add(animation, forKey:nil)
    }
    
    @objc func tapAction(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: chartView)
        fanLayers.forEach {
            if UIBezierPath(cgPath: $0.path!).contains(point) {
                if selectedIndex == deSelectIndex {
                    setDidSelectAnimation(fanLayer: $0)
                    selectedIndex = $0.index
                } else if selectedIndex == $0.index {
                    setDidDeselectAnimation(fanLayer: $0)
                    delegate?.pieChartView(self, didDeSelectSection: $0.index)
                    selectedIndex = deSelectIndex
                } else {
                    setDidSelectAnimation(fanLayer: $0)
                    setDidDeselectAnimation(fanLayer: fanLayers[selectedIndex])
                    delegate?.pieChartView(self, didDeSelectSection: fanLayers[selectedIndex].index)
                    selectedIndex = $0.index
                }
                delegate?.pieChartView(self, didSelectSection: selectedIndex)
            }
        }
    }
    
    // MARK:- Reload
    override public func reloadData() {
        selectedIndex = deSelectIndex
        settingChartViewFrame()
        guard let dataSource = dataSource else {
            return
        }
        
        let sections = dataSource.numberOfSections(in: self)
        prepareFanLayers(sections: sections)
        var values = [CGFloat]()
        var colors = [UIColor]()
        for section in 0..<sections {
            values.append(dataSource.pieChartView(self, valueForSection: section))
            colors.append(dataSource.pieChartView(self, colorForSection: section))
        }
        setFanLayers(colors: colors, values: values)
        showAnimation()
    }
    
    public func redrawChart() {
        fanLayers.forEach { $0.removeFromSuperlayer() }
        fanLayers.removeAll()
        animationFanLayers.forEach { $0.removeFromSuperlayer() }
        animationFanLayers.removeAll()
        reloadData()
    }
}
