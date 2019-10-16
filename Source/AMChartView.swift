//
//  AMChartView.swift
//  SampleAMChart
//
//  Created by makoto on 2019/10/17.
//  Copyright © 2019 am10. All rights reserved.
//

import UIKit

public class AMChartView: UIView {
    
    override public var bounds: CGRect {
        didSet {
            reloadData()
        }
    }
    
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
    
    public func initView() {
    }
    
    override public func draw(_ rect: CGRect) {
        reloadData()
    }
    
    // MARK:- Reload
    public func reloadData() {
    }
}
