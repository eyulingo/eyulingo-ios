//
//  EyulingoUnitTests.swift
//  EyulingoUnitTests
//
//  Created by 法好 on 2019/7/11.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import XCTest
@testable import Eyulingo

class EyulingoUnitTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testDateTimeParser() {
        let rawString = "2000-01-26 21:41:33.0"
        let date1 = DateAndTimeParser.getDateFromString(rawString,
                                            makeUTC8Conversion: true)
        let date2 = DateAndTimeParser.getDateFromString(rawString,
                                            makeUTC8Conversion: false)
        
        assert(date1 == date2?.addingTimeInterval(60 * 60 * 8))
        
        let dayStr1 = DateAndTimeParser.parseDayFromString(rawString, makeUTC8Conversion: true)
        
        let dayStr2 = DateAndTimeParser.parseDayFromString(rawString, makeUTC8Conversion: false)
        
        assert(dayStr1 == "2000 年 01 月 27 日")
        assert(dayStr2 == "2000 年 01 月 26 日")
    }

}
