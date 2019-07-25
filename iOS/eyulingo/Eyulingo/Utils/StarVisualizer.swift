//
//  StarVisualizer.swift
//  Eyulingo
//
//  Created by 法好 on 2019/7/25.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import Foundation

class StarVisualizer {
    private static let emptyStartSymbol = "☆"
    private static let fillStartSymbol = "★"

    static var rateMax: Int = 5
    static func getStarsText(_ rate: Int) -> String {
        if rate < 1 || rate > StarVisualizer.rateMax {
            return ""
        }
        var resultString = ""

        for index in 0 ..< StarVisualizer.rateMax {
            resultString += index >= rate ? emptyStartSymbol : fillStartSymbol
        }

        return resultString
    }
}
