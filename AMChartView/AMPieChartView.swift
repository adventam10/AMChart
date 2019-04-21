//
//  AMPieChartView.swift
//  AMChart, https://github.com/adventam10/AMChart
//
//  Created by am10 on 2018/01/02.
//  Copyright © 2018年 am10. All rights reserved.
//

import UIKit

private let AMPCSpace:CGFloat = 10

private let AMPCDeSelectIndex:Int = -1

public protocol AMPieChartViewDataSource:class {
    func numberOfSections(in pieChartView: AMPieChartView) -> Int
    func pieChartView(_ pieChartView: AMPieChartView, valueForSection section: Int) -> CGFloat
    func pieChartView(_ pieChartView: AMPieChartView, colorForSection section: Int) -> UIColor
}

public protocol AMPieChartViewDelegate:class {
    func pieChartView(_ pieChartView: AMPieChartView, didSelectSection section: Int)
    func pieChartView(_ pieChartView: AMPieChartView, didDeSelectSection section: Int)
}

public class AMPieChartView: UIView {

    class FanLayer: CAShapeLayer {
        
        var index:Int = 0
        
        @objc var startAngle:Float = 0
        
        @objc var endAngle:Float = 0
        
        var value:CGFloat = 0
        
        var rate:CGFloat = 0
        
        var isDounut = false
        
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
            // Create the path
            let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
            let radius = (frame.width - AMPCSpace * 2)/2
            let smallRadius = radius/2
            
            ctx.beginPath()
            if isDounut {
                let p = CGPoint(x: centerPoint.x + smallRadius * CGFloat(cosf(startAngle)),
                                y: centerPoint.y + smallRadius * CGFloat(sinf(startAngle)))
                ctx.move(to: CGPoint(x: p.x, y: p.y))
            } else {
                ctx.move(to: CGPoint(x: centerPoint.x, y: centerPoint.y))
            }
            
            let p1 = CGPoint(x: centerPoint.x + radius * CGFloat(cosf(startAngle)),
                             y: centerPoint.y + radius * CGFloat(sinf(self.startAngle)))
            ctx.addLine(to: CGPoint(x: p1.x, y: p1.y))
            
            ctx.addArc(center: centerPoint,
                           radius: radius,
                           startAngle: CGFloat(startAngle),
                           endAngle: CGFloat(endAngle),
                           clockwise: false)
            
            if isDounut {
                let p3 = CGPoint(x: centerPoint.x + smallRadius * CGFloat(cosf(endAngle)),
                                 y: centerPoint.y + smallRadius * CGFloat(sinf(endAngle)))
                ctx.addLine(to: CGPoint(x: p3.x, y: p3.y))
                ctx.addArc(center: centerPoint,
                               radius: smallRadius,
                               startAngle: CGFloat(endAngle),
                               endAngle: CGFloat(startAngle) + CGFloat(Double.pi * 2),
                               clockwise: true)
            }
            ctx.closePath()
            
            // Color it
            ctx.setFillColor(fillColor!)
            ctx.drawPath(using: .fill)
        }
    }
    
    override public var bounds: CGRect {
        didSet {
            reloadData()
        }
    }

    weak public var dataSource:AMPieChartViewDataSource?
    
    weak public var delegate:AMPieChartViewDelegate?
    
    public var animationDuration:CFTimeInterval = 0.6
    
    public var selectedAnimationDuration:CFTimeInterval = 0.3
    
    @IBInspectable public var isDounut:Bool = false
    
    @IBInspectable public var centerLabelFont:UIFont = UIFont.systemFont(ofSize: 15)

    @IBInspectable public var centerLabelTextColor:UIColor = UIColor.black
    
    @IBInspectable public var centerLabelText:String = "" {
        didSet {
            centerLabel.text = centerLabelText
        }
    }
    
    public var centerLabelAttribetedText:NSAttributedString? = nil {
        didSet {
            centerLabel.attributedText = centerLabelAttribetedText
        }
    }
    
    private var fanLayers = [FanLayer]()
    
    private var animationFanLayers = [FanLayer]()
    
    private var animationStartAngles = [Float]()
    private var animationEndAngles = [Float]()
    
    private let chartView = UIView()
    
    private let animationChartView = UIView()
    
    private var selectedIndex:Int = AMPCDeSelectIndex
    
    private let centerLabel = UILabel()
    
    //MARK:Initialize
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        initView()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        initView()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    private func initView() {
        addSubview(animationChartView)
        addSubview(chartView)
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(self.tapAction(gesture:)))
        chartView.addGestureRecognizer(tap)
        
        centerLabel.textAlignment = .center
        centerLabel.adjustsFontSizeToFitWidth = true
        centerLabel.numberOfLines = 0
        addSubview(centerLabel)
    }
    
    override public func draw(_ rect: CGRect) {
        reloadData()
    }
    
    public func reloadData() {
        selectedIndex = AMPCDeSelectIndex
        settingChartViewFrame()
        guard let dataSource = dataSource else {
            return
        }
        
        let sections = dataSource.numberOfSections(in: self)
        prepareFanLayer(sections: sections)
        var values = [CGFloat]()
        var colors = [UIColor]()
        for section in 0..<sections {
            values.append(dataSource.pieChartView(self, valueForSection: section))
            colors.append(dataSource.pieChartView(self, colorForSection: section))
        }
        prepareFanLayers(colors: colors, values: values)
        showAnimation()
    }
    
    public func redrawChart() {
        fanLayers.forEach{$0.removeFromSuperlayer()}
        fanLayers.removeAll()
        animationFanLayers.forEach{$0.removeFromSuperlayer()}
        animationFanLayers.removeAll()
        reloadData()
    }
    
    private func settingChartViewFrame() {
        let length = (frame.width < frame.height) ? frame.width : frame.height
        chartView.frame = CGRect(x: bounds.midX - length/2,
                                  y: bounds.midY - length/2,
                                  width: length,
                                  height: length)
        
        animationChartView.frame = chartView.frame
        chartView.isHidden = true
        animationChartView.isHidden = false
        
        let labelLength : CGFloat = 1.4 * (length/2 - AMPCSpace)/2
        centerLabel.frame = CGRect(x: bounds.midX - labelLength/2,
                                    y: bounds.midY - labelLength/2,
                                    width: labelLength,
                                    height: labelLength)
        centerLabel.font = centerLabelFont
        centerLabel.textColor = centerLabelTextColor
    }
    
    private func prepareFanLayer(sections: Int) {
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

    private func prepareFanLayers(colors: [UIColor], values: [CGFloat]) {
        let sum = values.reduce(0, +)
        var angle = Float(Double.pi/2 + Double.pi)
        for (index, fanLayer) in fanLayers.enumerated() {
            let animFanLayer = animationFanLayers[index]
            let rate = values[index] / sum
            fanLayer.fillColor = colors[index].cgColor
            fanLayer.value = values[index]
            fanLayer.rate = rate
            fanLayer.startAngle = angle
            fanLayer.endAngle = angle + Float(Double.pi*2) * Float(rate)
            fanLayer.isDounut = isDounut
            
            animFanLayer.fillColor = colors[index].cgColor
            animFanLayer.value = values[index]
            animFanLayer.rate = rate
            animFanLayer.isDounut = isDounut
            
            animationStartAngles.append(angle)
            animationEndAngles.append(angle + Float(Double.pi*2) * Float(rate))
            angle += Float(Double.pi*2) * Float(rate)
        }
    }
    
    private func showAnimation() {
        for (index ,animfanLayer) in animationFanLayers.enumerated() {
            CATransaction.begin()
            CATransaction.setCompletionBlock{[unowned self] in
                
                let animation = animfanLayer.animation(forKey: "angleAnimation")
                
                if animation != nil {
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
    
    func animationComplete(index: Int) {
        if index < fanLayers.count {
            let fanLayer = fanLayers[index]
            let radius = (chartView.frame.width - AMPCSpace * 2)/2
            let centerPoint = CGPoint(x: fanLayer.bounds.midX,
                                      y: fanLayer.bounds.midY)
            
            let path = createFanLayerPath(centerPoint: centerPoint,
                                          radius: radius,
                                          startAngle: fanLayer.startAngle,
                                          endAngle: fanLayer.endAngle)
            fanLayer.path = path.cgPath
            animationChartView.isHidden = true
            chartView.isHidden = false
        }
    }
    
    private func createFanLayerPath(centerPoint: CGPoint,
                                    radius: CGFloat,
                                    startAngle: Float,
                                    endAngle: Float) -> UIBezierPath
    {
        let piePath = UIBezierPath()
        let smallRadius = radius/2
        if isDounut {
            let p = CGPoint(x: centerPoint.x + smallRadius * CGFloat(cosf(startAngle)),
                            y: centerPoint.y + smallRadius * CGFloat(sinf(startAngle)))
            piePath.move(to: p)
        } else {
            piePath.move(to: centerPoint)
        }
        
        piePath.addLine(to: CGPoint(x: centerPoint.x + radius * CGFloat(cosf(startAngle)),
                                    y: centerPoint.y + radius * CGFloat(sinf(startAngle))))
        piePath.addArc(withCenter: centerPoint,
                       radius: radius,
                       startAngle: CGFloat(startAngle),
                       endAngle: CGFloat(endAngle),
                       clockwise: true)
        
        if isDounut {
            let p = CGPoint(x: centerPoint.x + smallRadius * CGFloat(cosf(endAngle)),
                            y: centerPoint.y + smallRadius * CGFloat(sinf(endAngle)))
            piePath.addLine(to: p)
            
            if startAngle + Float(Double.pi*2) == endAngle {
                piePath.addArc(withCenter: centerPoint,
                               radius: smallRadius,
                               startAngle: CGFloat(startAngle),
                               endAngle: CGFloat(endAngle),
                               clockwise: false)
            } else {
                piePath.addArc(withCenter: centerPoint,
                               radius:smallRadius,
                               startAngle:CGFloat(endAngle),
                               endAngle:CGFloat(startAngle) + CGFloat(Double.pi*2),
                               clockwise:false)
            }
        }
        piePath.close()
        return piePath
    }
    
    private func createPathAnimation(fromPath: UIBezierPath,
                                     toPath: UIBezierPath,
                                     animationDuration: CFTimeInterval) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.fromValue = fromPath.cgPath
        animation.toValue = toPath.cgPath
        return animation
    }
    
    private func selectedFanAnimation(fanLayer: FanLayer) {
        let radius = (chartView.frame.width - AMPCSpace * 2) / 2
        let centerPoint = CGPoint(x: fanLayer.bounds.midX, y: fanLayer.bounds.midY)
        let smallRadius = AMPCSpace
        let angle = (fanLayer.startAngle + fanLayer.endAngle) / 2
        let smallCenterPoint = CGPoint(x: centerPoint.x + smallRadius * CGFloat(cosf(angle)),
                                       y: centerPoint.y + smallRadius * CGFloat(sinf(angle)))
        
        let animationPath = createFanLayerPath(centerPoint: smallCenterPoint,
                                               radius: radius,
                                               startAngle: fanLayer.startAngle,
                                               endAngle: fanLayer.endAngle)
        let startPath = UIBezierPath(cgPath: fanLayer.path!)
        let animation = createPathAnimation(fromPath: startPath,
                                            toPath: animationPath,
                                            animationDuration: selectedAnimationDuration)
        fanLayer.path = animationPath.cgPath
        fanLayer.add(animation, forKey:nil)
    }
    
    private func deselectedFanAnimation(fanLayer: FanLayer) {
        let radius = (chartView.frame.width - AMPCSpace * 2) / 2
        let centerPoint = CGPoint(x: fanLayer.bounds.midX, y: fanLayer.bounds.midY)
        
        let animationPath = createFanLayerPath(centerPoint: centerPoint,
                                               radius: radius,
                                               startAngle: fanLayer.startAngle,
                                               endAngle: fanLayer.endAngle)
        let startPath = UIBezierPath(cgPath: fanLayer.path!)
        
        let animation = createPathAnimation(fromPath: startPath,
                                            toPath: animationPath,
                                            animationDuration: selectedAnimationDuration)
        fanLayer.path = animationPath.cgPath
        fanLayer.add(animation, forKey:nil)
        delegate?.pieChartView(self, didDeSelectSection: fanLayer.index)
    }
    
    @objc func tapAction(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: chartView)
        fanLayers.forEach {
            if UIBezierPath(cgPath: $0.path!).contains(point) {
                if selectedIndex == AMPCDeSelectIndex {
                    selectedFanAnimation(fanLayer: $0)
                    selectedIndex = $0.index
                } else if selectedIndex == $0.index {
                    deselectedFanAnimation(fanLayer: $0)
                    selectedIndex = AMPCDeSelectIndex
                } else {
                    selectedFanAnimation(fanLayer: $0)
                    deselectedFanAnimation(fanLayer: fanLayers[selectedIndex])
                    selectedIndex = $0.index
                }
                delegate?.pieChartView(self, didSelectSection: selectedIndex)
            }
        }
    }
}
