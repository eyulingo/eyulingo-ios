//
//  EyulingoUnitTests.swift
//  EyulingoUnitTests
//
//  Created by 法好 on 2019/7/11.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import XCTest
@testable import Eyulingo
@testable import Alamofire

class EyulingoUnitTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        NSLog("Starting Unit test.")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        NSLog("Unit test done.")
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
    
    func testPinYinConverter() {
        assert(PYConverter.transformChinese("瀋備軍").starts(with: "S"))
        assert(PYConverter.transformChinese("陈浩鹏").starts(with: "C"))
        assert(PYConverter.transformChinese("林忠钦").starts(with: "L"))
        assert(PYConverter.transformChinese("随千山").starts(with: "S"))
        assert(PYConverter.transformChinese("真采萱").starts(with: "Z"))
    }
    
    func testEmailValidation() {
        assert(EmailVerifier.verify("akaza_akari@outlook.com") == true)
        assert(EmailVerifier.verify("akaza_akari@sjtu.edu.com") == true)
        
        assert(EmailVerifier.verify("akaza_akari@outlook.") == false)
        assert(EmailVerifier.verify("akaza_akari#outlook.com") == false)
        assert(EmailVerifier.verify("@outlook.com") == false)
        assert(EmailVerifier.verify("akaza_akari@outlook.c") == false)
    }

    func testUriValid() {
        let baseUri = Eyulingo_UserUri.baseUri
        
        assert(Eyulingo_UserUri.addAddressPostUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.addressGetUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.addToCartPostUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.avatarPostUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.captchaGetPostUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.commentGoodsPostUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.commentStorePostUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.emailChangePostUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.findCheckCodePostUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.goodDetailGetUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.imageGetUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.imagePostUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.loginPostUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.logOutPostUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.myCartGetUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.passwordChangePostUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.profileGetUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.purchasedGetUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.purchasePostUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.registerPostUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.removeAddressPostUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.resetPasswordPostUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.searchGoodsGetUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.searchStoresGetUri.starts(with: baseUri))
        assert(Eyulingo_UserUri.storeDetailGetUri.starts(with: baseUri))
    }
}
