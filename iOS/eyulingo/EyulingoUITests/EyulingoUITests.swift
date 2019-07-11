//
//  EyulingoUITests.swift
//  EyulingoUITests
//
//  Created by 法好 on 2019/7/11.
//  Copyright © 2019 yuetsin. All rights reserved.
//

import XCTest

class EyulingoUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

        func testOperation() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
            
            let app = XCUIApplication()
            app.textFields["用户名"].tap()
            app.textFields["用户名"].typeText("随千山")
            app.secureTextFields["密码"].tap()
            app.secureTextFields["密码"].typeText("Suiqianshan123456")
            app.buttons["登录按钮"].tap()
            let tabBarsQuery = app.tabBars
            tabBarsQuery.buttons["购物车"].tap()
            tabBarsQuery.buttons["已购项目"].tap()
            tabBarsQuery.buttons["我"].tap()
            XCUIDevice.shared.orientation = .portrait
            app.tables/*@START_MENU_TOKEN@*/.staticTexts["头像"]/*[[".cells.staticTexts[\"头像\"]",".staticTexts[\"头像\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            app.sheets["想进行什么操作？"].scrollViews.otherElements.buttons["修改头像"].tap()
            
            let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
            
    }

}
