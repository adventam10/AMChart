# AMChart

![Pod Platform](https://img.shields.io/cocoapods/p/AMChart.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/AMChart.svg?style=flat)
[![Pod Version](https://img.shields.io/cocoapods/v/AMChart.svg?style=flat)](http://cocoapods.org/pods/AMChart)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

## Demo

![charts](https://user-images.githubusercontent.com/34936885/67146899-d0171500-f2ca-11e9-8266-31e1984e66e4.gif)

## Usage
### AMBarChartView
![bar](https://user-images.githubusercontent.com/34936885/67146915-f63cb500-f2ca-11e9-9073-5eb8f3314360.png)

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
@IBInspectable public var numberOfYAxisLabel: Int = 6
@IBInspectable public var axisColor: UIColor = .black
@IBInspectable public var axisWidth: CGFloat = 1.0
@IBInspectable public var barSpace: CGFloat = 8
@IBInspectable public var yAxisTitleFont: UIFont = .systemFont(ofSize: 15)
@IBInspectable public var xAxisTitleFont: UIFont = .systemFont(ofSize: 15)
@IBInspectable public var yLabelsFont: UIFont = .systemFont(ofSize: 15)
@IBInspectable public var xLabelsFont: UIFont = .systemFont(ofSize: 15)
@IBInspectable public var yAxisTitleColor: UIColor = .black
@IBInspectable public var xAxisTitleColor: UIColor = .black
@IBInspectable public var yLabelsTextColor: UIColor = .black
@IBInspectable public var xLabelsTextColor: UIColor = .black
@IBInspectable public var isHorizontalLine: Bool = false
@IBInspectable public var yAxisTitle: String = ""
@IBInspectable public var xAxisTitle: String = ""
public var yAxisDecimalFormat: AMDecimalFormat = .none
public var animationDuration: CFTimeInterval = 0.6
```

### AMLineChartView
![line](https://user-images.githubusercontent.com/34936885/67146924-14a2b080-f2cb-11e9-9720-4290ac1b9832.png)

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
func lineChartView(_ lineChartView: AMLineChartView, pointTypeForSection section: Int) -> AMPointType
```

#### Customization
`AMLineChartView` can be customized via the following properties.

```swift
@IBInspectable public var yAxisMaxValue: CGFloat = 1000
@IBInspectable public var yAxisMinValue: CGFloat = 0
@IBInspectable public var numberOfYAxisLabel: Int = 6
@IBInspectable public var axisColor: UIColor = .black
@IBInspectable public var axisWidth: CGFloat = 1.0
@IBInspectable public var yAxisTitleFont: UIFont = .systemFont(ofSize: 15)
@IBInspectable public var xAxisTitleFont: UIFont = .systemFont(ofSize: 15)
@IBInspectable public var yLabelsFont: UIFont = .systemFont(ofSize: 15)
@IBInspectable public var xLabelsFont: UIFont = .systemFont(ofSize: 15)
@IBInspectable public var yAxisTitleColor: UIColor = .black
@IBInspectable public var xAxisTitleColor: UIColor = .black
@IBInspectable public var yLabelsTextColor: UIColor = .black
@IBInspectable public var xLabelsTextColor: UIColor = .black
@IBInspectable public var isHorizontalLine: Bool = false
@IBInspectable public var yAxisTitle: String = ""
@IBInspectable public var xAxisTitle: String = ""
public var yAxisDecimalFormat: AMDecimalFormat = .none
public var animationDuration: CFTimeInterval = 0.6
```

### AMPieChartView
![pie](https://user-images.githubusercontent.com/34936885/67146931-23896300-f2cb-11e9-8dbf-84743a54f314.png)

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
public var animationDuration: CFTimeInterval = 0.4
public var selectedAnimationDuration: CFTimeInterval = 0.3
public var centerLabelAttribetedText: NSAttributedString? = nil
```

### AMRadarChartView
![radar](https://user-images.githubusercontent.com/34936885/67146968-78c57480-f2cb-11e9-896f-4de1b13f0b82.png)

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
func radarChartView(_ radarChartView: AMRadarChartView, titleForVertexInRow row: Int) -> String
func radarChartView(_ radarChartView: AMRadarChartView, fontForVertexInRow row: Int) -> UIFont // default is System 15.0
func radarChartView(_ radarChartView: AMRadarChartView, textColorForVertexInRow row: Int) -> UIColor // default is black
```

#### Customization
`AMRadarChartView` can be customized via the following properties.

```swift
@IBInspectable public var axisMaxValue: CGFloat = 5.0
@IBInspectable public var axisMinValue: CGFloat = 0.0
@IBInspectable public var numberOfAxisLabels: Int = 6
@IBInspectable public var axisColor: UIColor = .black
@IBInspectable public var axisWidth: CGFloat = 1.0
@IBInspectable public var axisLabelsFont: UIFont = .systemFont(ofSize: 15)
@IBInspectable public var axisLabelsTextColor: UIColor = .black
@IBInspectable public var isDottedLine: Bool = false
public var axisDecimalFormat: AMDecimalFormat = .none
public var animationDuration: CFTimeInterval = 0.6
```

### AMScatterChartView
![scatter](https://user-images.githubusercontent.com/34936885/67146918-fccb2c80-f2ca-11e9-8348-ee00d5febf12.png)

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
func scatterChartView(_ scatterChartView: AMScatterChartView, valueForRowAtIndexPath indexPath: IndexPath) -> AMScatterValue
func scatterChartView(_ scatterChartView: AMScatterChartView, colorForSection section: Int) -> UIColor
func scatterChartView(_ scatterChartView: AMScatterChartView, pointTypeForSection section: Int) -> AMPointType
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
@IBInspectable public var axisColor: UIColor = .black
@IBInspectable public var axisWidth: CGFloat = 1.0
@IBInspectable public var yAxisTitleFont: UIFont = .systemFont(ofSize: 15)
@IBInspectable public var xAxisTitleFont: UIFont = .systemFont(ofSize: 15)
@IBInspectable public var yLabelsFont: UIFont = .systemFont(ofSize: 15)
@IBInspectable public var xLabelsFont: UIFont = .systemFont(ofSize: 15)
@IBInspectable public var yAxisTitleColor: UIColor = .black
@IBInspectable public var xAxisTitleColor: UIColor = .black
@IBInspectable public var yLabelsTextColor: UIColor = .black
@IBInspectable public var xLabelsTextColor: UIColor = .black
@IBInspectable public var isHorizontalLine: Bool = false
@IBInspectable public var yAxisTitle: String = ""
@IBInspectable public var xAxisTitle: String = ""
public var yAxisDecimalFormat: AMDecimalFormat = .none
public var xAxisDecimalFormat: AMDecimalFormat = .none
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

