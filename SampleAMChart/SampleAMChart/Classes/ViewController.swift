//
//  ViewController.swift
//  SampleAMChart
//
//  Created by am10 on 2018/01/08.
//  Copyright © 2018年 am10. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var radarChartView: AMRadarChartView!
    @IBOutlet private weak var barChartView: AMBarChartView!
    @IBOutlet private weak var pieChartView: AMPieChartView!
    @IBOutlet private weak var scatterChartView: AMScatterChartView!
    @IBOutlet private weak var lineChartView: AMLineChartView!
    
    private var radarDataList = [[CGFloat]]()
    private var barDataList = [[CGFloat]]()
    private var pieDataList = [CGFloat]()
    private var scatterDataList = [[AMScatterValue]]()
    private var lineDataList = [[CGFloat]]()
    private var radarRowNum = 0
    private let radarAxisNum = 6
    private var barColors = [UIColor]()
    private var lineRowNum = 0
    
    private let titles = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        prepareDataList()
        radarChartView.dataSource = self
        barChartView.dataSource = self
        pieChartView.dataSource = self
        scatterChartView.dataSource = self
        lineChartView.dataSource = self
    }

    @IBAction private func tappedReloadButton(_ sender: Any) {
        prepareDataList()
        radarChartView.reloadData()
        lineChartView.reloadData()
        pieChartView.reloadData()
        barChartView.reloadData()
        scatterChartView.reloadData()
    }
    
    @IBAction private func tappedRedrawButton(_ sender: Any) {
        radarChartView.redrawChart()
        lineChartView.redrawChart()
        pieChartView.redrawChart()
        barChartView.reloadData()
        scatterChartView.reloadData()
    }
    
    private func randomColor(alpha: CGFloat) -> UIColor {
        let r = CGFloat.random(in: 0...255) / 255.0
        let g = CGFloat.random(in: 0...255) / 255.0
        let b = CGFloat.random(in: 0...255) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
    
    private func randomPointType() -> AMPointType {
        let pointTypes: [AMPointType] = [.type1, .type2, .type3, .type4, .type5, .type6, .type7, .type8, .type9]
        return pointTypes[Int.random(in: 0...8)]
    }
    
    private func prepareDataList() {
        radarRowNum = Int.random(in: 3...titles.count)
        let radarSectionNum = Int.random(in: 1...7)
        radarDataList.removeAll()
        for _ in 0..<radarSectionNum {
            var values = [CGFloat]()
            for _ in 0..<radarRowNum {
                values.append(CGFloat.random(in: 0...CGFloat(radarAxisNum - 1)))
            }
            radarDataList.append(values)
        }
        
        let lineSectionNum = Int.random(in: 1...11)
        lineRowNum = Int.random(in: 1...16)
        lineDataList.removeAll()
        for _ in 0..<lineSectionNum {
            var values = [CGFloat]()
            for _ in 0..<lineRowNum {
                values.append(CGFloat.random(in: 0...1000))
            }
            lineDataList.append(values)
        }
        
        let pieSectionNum = Int.random(in: 1...11)
        pieDataList.removeAll()
        for _ in 0..<pieSectionNum {
            pieDataList.append(CGFloat.random(in: 0...1000))
        }
        
        let barSectionNum = Int.random(in: 1...11)
        let barRowNum = Int.random(in: 1...6)
        barDataList.removeAll()
        barColors.removeAll()
        for (i) in 0..<barSectionNum {
            var values = [CGFloat]()
            for _ in 0..<barRowNum {
                if i == 0 {
                    barColors.append(randomColor(alpha: 1.0))
                }
                values.append(CGFloat.random(in: 0...200))
            }
            barDataList.append(values)
        }
        
        let scatterSectionNum = Int.random(in: 1...11)
        scatterDataList.removeAll()
        for _ in 0..<scatterSectionNum {
            var values = [AMScatterValue]()
            let scatterRowNum = Int.random(in: 1...100)
            for _ in 0..<scatterRowNum {
                values.append(.init(x: CGFloat.random(in: 0...1000), y: CGFloat.random(in: 0...1000)))
            }
            scatterDataList.append(values)
        }
    }
}

extension ViewController: AMRadarChartViewDataSource {
    func numberOfSections(in radarChartView:AMRadarChartView) -> Int {
        return radarDataList.count
    }
    
    func numberOfRows(in radarChartView:AMRadarChartView) -> Int {
        return radarRowNum
    }
    
    func radarChartView(_ radarChartView:AMRadarChartView, valueForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return radarDataList[indexPath.section][indexPath.row]
    }
    
    func radarChartView(_ radarChartView:AMRadarChartView, fillColorForSection section: Int) -> UIColor {
        return randomColor(alpha: 0.5)
    }
    
    func radarChartView(_ radarChartView:AMRadarChartView, strokeColorForSection section: Int) -> UIColor {
        return randomColor(alpha: 0.5)
    }
    
    func radarChartView(_ radarChartView: AMRadarChartView, titleForVertexInRow row: Int) -> String {
        return titles[row]
    }
}

extension ViewController: AMScatterChartViewDataSource {
    func numberOfSections(in scatterChartView:AMScatterChartView) -> Int {
        return scatterDataList.count
    }
    
    func scatterChartView(_ scatterChartView:AMScatterChartView, numberOfRowsInSection section: Int) -> Int {
        return scatterDataList[section].count
    }
    
    func scatterChartView(_ scatterChartView:AMScatterChartView, valueForRowAtIndexPath indexPath: IndexPath) -> AMScatterValue {
        return scatterDataList[indexPath.section][indexPath.row]
    }
    
    func scatterChartView(_ scatterChartView:AMScatterChartView, colorForSection section: Int) -> UIColor {
        return randomColor(alpha: 1.0)
    }
    
    func scatterChartView(_ scatterChartView:AMScatterChartView, pointTypeForSection section: Int) -> AMPointType {
        return randomPointType()
    }
}

extension ViewController: AMPieChartViewDataSource {
    func numberOfSections(in pieChartView: AMPieChartView) -> Int {
        return pieDataList.count
    }
    
    func pieChartView(_ pieChartView:AMPieChartView, valueForSection section: Int) -> CGFloat {
        return pieDataList[section]
    }
    
    func pieChartView(_ pieChartView:AMPieChartView, colorForSection section: Int) -> UIColor {
        return randomColor(alpha: 1.0)
    }
}

extension ViewController: AMLineChartViewDataSource {
    func numberOfSections(in lineChartView:AMLineChartView) -> Int {
        return lineDataList.count
    }
    
    func numberOfRows(in lineChartView:AMLineChartView) -> Int {
        return lineRowNum
    }
    
    func lineChartView(_ lineChartView:AMLineChartView, valueForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return lineDataList[indexPath.section][indexPath.row]
    }
    
    func lineChartView(_ lineChartView:AMLineChartView, colorForSection section: Int) -> UIColor {
        return randomColor(alpha: 1.0)
    }
    
    func lineChartView(_ lineChartView:AMLineChartView, titleForXlabelInRow row: Int) -> String {
        return titles[row]
    }
    
    func lineChartView(_ lineChartView:AMLineChartView, pointTypeForSection section: Int) -> AMPointType {
        return randomPointType()
    }
}

extension ViewController: AMBarChartViewDataSource {
    func numberOfSections(in barChartView: AMBarChartView) -> Int {
        return barDataList.count
    }
    
    func barChartView(_ barChartView: AMBarChartView, numberOfRowsInSection section: Int) -> Int {
        return barDataList[section].count
    }
    
    func barChartView(_ barChartView: AMBarChartView, valueForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return barDataList[indexPath.section][indexPath.row]
    }
    
    func barChartView(_ barChartView: AMBarChartView, colorForRowAtIndexPath indexPath: IndexPath) -> UIColor {
        return barColors[indexPath.row]
    }
    
    func barChartView(_ barChartView: AMBarChartView, titleForXlabelInSection section: Int) -> String {
        return titles[section]
    }
}
