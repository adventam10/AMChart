//
//  ViewController.swift
//  SampleAMChart
//
//  Created by am10 on 2018/01/08.
//  Copyright © 2018年 am10. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var radarChartView: AMRadarChartView!
    @IBOutlet weak var barChartView: AMBarChartView!
    @IBOutlet weak var pieChartView: AMPieChartView!
    @IBOutlet weak var scatterChartView: AMScatterChartView!
    @IBOutlet weak var lineChartView: AMLineChartView!
    
    var radarDataList = [[CGFloat]]()
    var barDataList = [[CGFloat]]()
    var pieDataList = [CGFloat]()
    var scatterDataList = [[AMSCScatterValue]]()
    var lineDataList = [[CGFloat]]()
    var radarRowNum:Int = 0
    let radarAxisNum:UInt32 = 6
    var barColors = [UIColor]()
    var lineRowNum:Int = 0;
    
    let titles = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    let linePointTypes:[AMLCPointType] = [.type1, .type2, .type3, .type4, .type5, .type6, .type7, .type8, .type9]
    
    let scatterPointTypes:[AMSCPointType] = [.type1, .type2, .type3, .type4, .type5, .type6, .type7, .type8, .type9]
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    private func prepareDataList () {
        radarRowNum = Int(arc4random_uniform(24)) + 3
        let radarSectionNum = Int(arc4random_uniform(6)) + 1
        radarDataList.removeAll()
        for _ in 0..<radarSectionNum {
            var values = [CGFloat]()
            for _ in 0..<radarRowNum {
                let value = CGFloat(arc4random_uniform(radarAxisNum))
                values.append(value)
            }
            radarDataList.append(values)
        }
        
        let lineSectionNum = Int(arc4random_uniform(10)) + 1
        lineRowNum = Int(arc4random_uniform(15)) + 1
        lineDataList.removeAll()
        for _ in 0..<lineSectionNum {
            var values = [CGFloat]()
            for _ in 0..<lineRowNum {
                let value = CGFloat(arc4random_uniform(800))
                values.append(value)
            }
            lineDataList.append(values)
        }
        
        let pieSectionNum = Int(arc4random_uniform(10)) + 1
        pieDataList.removeAll()
        for _ in 0..<pieSectionNum {
            let value = CGFloat(arc4random_uniform(800))
            pieDataList.append(value)
        }
        
        let barSectionNum = Int(arc4random_uniform(10)) + 1
        let barRownNum = Int(arc4random_uniform(5)) + 1
        barDataList.removeAll()
        barColors.removeAll()
        for (i) in 0..<barSectionNum {
            var values = [CGFloat]()
            for _ in 0..<barRownNum {
                if i == 0 {
                    let r = CGFloat(arc4random_uniform(255) + 1)/255.0
                    let g = CGFloat(arc4random_uniform(255) + 1)/255.0
                    let b = CGFloat(arc4random_uniform(255) + 1)/255.0
                    
                    let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
                    barColors.append(color)
                }
                let value = CGFloat(arc4random_uniform(200))
                values.append(value)
            }
            barDataList.append(values)
        }
        
        let scatterSectionNum = Int(arc4random_uniform(10)) + 1
        scatterDataList.removeAll()
        for _ in 0..<scatterSectionNum {
            var values = [AMSCScatterValue]()
            let scatterRownNum = Int(arc4random_uniform(100)) + 1
            for _ in 0..<scatterRownNum {
                let valueX = CGFloat(arc4random_uniform(1000))
                let valueY = CGFloat(arc4random_uniform(1000))
                values.append(AMSCScatterValue(x:valueX, y: valueY))
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
        let r = CGFloat(arc4random_uniform(255) + 1)/255.0
        let g = CGFloat(arc4random_uniform(255) + 1)/255.0
        let b = CGFloat(arc4random_uniform(255) + 1)/255.0
        return UIColor(red: r, green: g, blue: b, alpha: 0.5)
    }
    
    func radarChartView(_ radarChartView:AMRadarChartView, strokeColorForSection section: Int) -> UIColor {
        let r = CGFloat(arc4random_uniform(255) + 1)/255.0
        let g = CGFloat(arc4random_uniform(255) + 1)/255.0
        let b = CGFloat(arc4random_uniform(255) + 1)/255.0
        return UIColor(red: r, green: g, blue: b, alpha: 0.5)
    }
    
    func radarChartView(_ radarChartView: AMRadarChartView, titleForXlabelInRow row: Int) -> String {
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
    
    func scatterChartView(_ scatterChartView:AMScatterChartView, valueForRowAtIndexPath indexPath: IndexPath) -> AMSCScatterValue {
        return scatterDataList[indexPath.section][indexPath.row]
    }
    
    func scatterChartView(_ scatterChartView:AMScatterChartView, colorForSection section: Int) -> UIColor {
        let r = CGFloat(arc4random_uniform(255) + 1)/255.0
        let g = CGFloat(arc4random_uniform(255) + 1)/255.0
        let b = CGFloat(arc4random_uniform(255) + 1)/255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    func scatterChartView(_ scatterChartView:AMScatterChartView, pointTypeForSection section: Int) -> AMSCPointType {
        return scatterPointTypes[Int(arc4random_uniform(9))]
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
        let r = CGFloat(arc4random_uniform(255) + 1)/255.0
        let g = CGFloat(arc4random_uniform(255) + 1)/255.0
        let b = CGFloat(arc4random_uniform(255) + 1)/255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
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
        let r = CGFloat(arc4random_uniform(255) + 1)/255.0
        let g = CGFloat(arc4random_uniform(255) + 1)/255.0
        let b = CGFloat(arc4random_uniform(255) + 1)/255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    func lineChartView(_ lineChartView:AMLineChartView, titleForXlabelInRow row: Int) -> String {
        return titles[row]
    }
    
    func lineChartView(_ lineChartView:AMLineChartView, pointTypeForSection section: Int) -> AMLCPointType {
        return linePointTypes[Int(arc4random_uniform(9))]
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
