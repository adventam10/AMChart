# AMChart

![Pod Platform](https://img.shields.io/cocoapods/p/AMChart.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/AMChart.svg?style=flat)
[![Pod Version](https://img.shields.io/cocoapods/v/AMChart.svg?style=flat)](http://cocoapods.org/pods/AMChart)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

## Demo

![chart](https://user-images.githubusercontent.com/34936885/34915170-9a4af420-f964-11e7-93ce-662fcae905e2.gif)

![chart2](https://user-images.githubusercontent.com/34936885/34915175-ab7988ce-f964-11e7-90a8-ad07986e8eee.gif)

## Variety

<img width="623" alt="chart" src="https://user-images.githubusercontent.com/34936885/34915180-bb3752fa-f964-11e7-99a4-87706a4a4932.png">

## Usage
### AMBarChartView

```swift
let barChartView = AMBarChartView(frame: view.bounds)

// customize here

barChartView.dataSource = self
view.addSubview(barChartView)
```

Conform to the protocol in the class implementation.

```swift
func numberOfSections(in barChartView: AMBarChartView) -> Int
func barChartView(_ barChartView: AMBarChartView, numberOfRowsInSection section: Int) -> Int
func barChartView(_ barChartView: AMBarChartView, valueForRowAtIndexPath indexPath: IndexPath) -> CGFloat
func barChartView(_ barChartView: AMBarChartView, colorForRowAtIndexPath indexPath: IndexPath) -> UIColor
func barChartView(_ barChartView: AMBarChartView, titleForXlabelInSection section: Int) -> String
```

#### Customization
`AMBarChartView` can be customized via the following properties.

```swift
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
@IBInspectable public var yAxisTitle: String = ""
@IBInspectable public var xAxisTitle: String = ""
public var yAxisDecimalFormat: AMBCDecimalFormat = .none
public var animationDuration: CFTimeInterval = 0.6
```

### AMLineChartView

```swift
let lineChartView = AMLineChartView(frame: view.bounds)

// customize here

lineChartView.dataSource = self
view.addSubview(lineChartView)
```

Conform to the protocol in the class implementation.

```swift
func numberOfSections(in lineChartView: AMLineChartView) -> Int
func numberOfRows(in lineChartView: AMLineChartView) -> Int
func lineChartView(_ lineChartView: AMLineChartView, valueForRowAtIndexPath indexPath: IndexPath) -> CGFloat
func lineChartView(_ lineChartView: AMLineChartView, colorForSection section: Int) -> UIColor
func lineChartView(_ lineChartView: AMLineChartView, titleForXlabelInRow row: Int) -> String
func lineChartView(_ lineChartView: AMLineChartView, pointTypeForSection section: Int) -> AMLCPointType
```

#### Customization
`AMLineChartView` can be customized via the following properties.

```swift
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
@IBInspectable public var yAxisTitle: String = ""
@IBInspectable public var xAxisTitle: String = ""
public var yAxisDecimalFormat: AMLCDecimalFormat = .none
public var animationDuration: CFTimeInterval = 0.6
```

### AMPieChartView

```swift
let pieChartView = AMPieChartView(frame: view.bounds)

// customize here

pieChartView.delegate = self
pieChartView.dataSource = self
view.addSubview(pieChartView)
```

Conform to the protocol in the class implementation.

```swift
/// DataSource
func numberOfSections(in pieChartView: AMPieChartView) -> Int
func pieChartView(_ pieChartView: AMPieChartView, valueForSection section: Int) -> CGFloat
func pieChartView(_ pieChartView: AMPieChartView, colorForSection section: Int) -> UIColor

/// Delegate
func pieChartView(_ pieChartView: AMPieChartView, didSelectSection section: Int) {
    // use selected section here
}

func pieChartView(_ pieChartView: AMPieChartView, didDeSelectSection section: Int) { 
    // use deselected section here
}
```

#### Customization
`AMPieChartView` can be customized via the following properties.

```swift
@IBInspectable public var isDounut: Bool = false
@IBInspectable public var centerLabelFont: UIFont = .systemFont(ofSize: 15)
@IBInspectable public var centerLabelTextColor: UIColor = .black
@IBInspectable public var centerLabelText: String = ""
public var animationDuration: CFTimeInterval = 0.6
public var selectedAnimationDuration: CFTimeInterval = 0.3
public var centerLabelAttribetedText: NSAttributedString? = nil
```

### AMRadarChartView

```swift
let radarChartView = AMRadarChartView(frame: view.bounds)

// customize here

radarChartView.dataSource = self
view.addSubview(radarChartView)
```

Conform to the protocol in the class implementation.

```swift
/// Required
func numberOfSections(in radarChartView: AMRadarChartView) -> Int
func numberOfRows(in radarChartView: AMRadarChartView) -> Int
func radarChartView(_ radarChartView: AMRadarChartView, valueForRowAtIndexPath indexPath: IndexPath) -> CGFloat
func radarChartView(_ radarChartView: AMRadarChartView, fillColorForSection section: Int) -> UIColor
func radarChartView(_ radarChartView: AMRadarChartView, strokeColorForSection section: Int) -> UIColor

/// Optional
func radarChartView(_ radarChartView: AMRadarChartView, titleForXlabelInRow row: Int) -> String
```

#### Customization
`AMRadarChartView` can be customized via the following properties.

```swift
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
public var axisDecimalFormat: AMRCDecimalFormat = .none
public var animationDuration: CFTimeInterval = 0.6
```

### AMScatterChartView

```swift
let scatterChartView = AMScatterChartView(frame: view.bounds)

// customize here

scatterChartView.dataSource = self
view.addSubview(scatterChartView)
```

Conform to the protocol in the class implementation.

```swift
func numberOfSections(in scatterChartView: AMScatterChartView) -> Int
func scatterChartView(_ scatterChartView: AMScatterChartView, numberOfRowsInSection section: Int) -> Int
func scatterChartView(_ scatterChartView: AMScatterChartView, valueForRowAtIndexPath indexPath: IndexPath) -> AMSCScatterValue
func scatterChartView(_ scatterChartView: AMScatterChartView, colorForSection section: Int) -> UIColor
func scatterChartView(_ scatterChartView: AMScatterChartView, pointTypeForSection section: Int) -> AMSCPointType
```

#### Customization
`AMScatterChartView` can be customized via the following properties.

```swift
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
@IBInspectable public var yAxisTitle: String = ""
@IBInspectable public var xAxisTitle: String = ""    
public var yAxisDecimalFormat: AMSCDecimalFormat = .none
public var xAxisDecimalFormat: AMSCDecimalFormat = .none
public var animationDuration: CFTimeInterval = 0.6
```

## Installation

### CocoaPods

Add this to your Podfile.

```ogdl
pod 'AMChart'
```

### Carthage

Add this to your Cartfile.

```ogdl
github "adventam10/AMChart"
```

## License

MIT

