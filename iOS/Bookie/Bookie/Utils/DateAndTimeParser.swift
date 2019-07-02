//
//  DateAndTimeParser.swift
//  
//
//  Created by 法好 on 2019/7/2.
//

import Foundation

class DateAndTimeParser {
    static func parseDateAndTimeString(_ str: String, makeUTC8Conversion convert: Bool = true) -> String {
        let dateFormatter = DateFormatter()
        let betterFormatter = DateFormatter()
        // 2019-07-02 00:20:10.0
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.S"
        betterFormatter.dateFormat = "yyyy 年 MM 月 dd 日 HH:mm:ss"
    
        if var date = dateFormatter.date(from: str) {
            if convert {
                date = date.addingTimeInterval(TimeInterval(60 * 60 * 8))
            }
            return betterFormatter.string(from: date)
        }
        return str
    }
    
    static func getDateFromString(_ str: String, makeUTC8Conversion convert: Bool = true) -> Date? {
        let dateFormatter = DateFormatter()
        // 2019-07-02 00:20:10.0
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.S"

        if var date = dateFormatter.date(from: str) {
            if convert {
                date = date.addingTimeInterval(TimeInterval(60 * 60 * 8))
            }
            return date
        }
        return nil
    }
    
    static func parseDayFromString(_ str: String, makeUTC8Conversion convert: Bool = true) -> String {
        let dateFormatter = DateFormatter()
        let betterFormatter = DateFormatter()
        // 2019-07-02 00:20:10.0
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.S"
        betterFormatter.dateFormat = "yyyy 年 MM 月 dd 日"
        
        if var date = dateFormatter.date(from: str) {
            if convert {
                date = date.addingTimeInterval(TimeInterval(60 * 60 * 8))
            }
            return betterFormatter.string(from: date)
        }
        return str
    }
}
