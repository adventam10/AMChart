//
//  AMChartData.swift
//  SampleAMChart
//
//  Created by am10 on 2019/10/16.
//  Copyright © 2019 am10. All rights reserved.
//

import UIKit

public enum AMDecimalFormat {
    case none
    case first
    case second
    
    public func formattedValue(_ value: CGFloat) -> String {
        switch self {
        case .none:
            return String(format: "%.0f", value)
        case .first:
            return String(format: "%.1f", value)
        case .second:
            return String(format: "%.2f", value)
        }
    }
}

public enum AMPointType {
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
    
    var isFilled: Bool {
        switch self {
        case .type2, .type4, .type6, .type8:
            return true
        default:
            return false
        }
    }
}

public struct AMScatterValue {
    
    public var xValue: CGFloat = 0
    public var yValue: CGFloat = 0
    
    public init(x: CGFloat, y: CGFloat) {
        xValue = x
        yValue = y
    }
}
