// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  AMBarChartView.swift
//  AMChart, https://github.com/adventam10/AMChart
//
//  Created by am10 on 2018/01/02.
//  Copyright © 2018年 am10. All rights reserved.
//

import PackageDescription

let package = Package(name: "AMChart",
                      platforms: [.iOS(.v9)],
                      products: [.library(name: "AMChart",
                                          targets: ["AMChart"])],
                      targets: [.target(name: "AMChart",
                                        path: "Source")],
                      swiftLanguageVersions: [.v5])
