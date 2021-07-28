//
//  OffOff_iOSUITests.swift
//  OffOff_iOSUITests
//
//  Created by Lee Nam Jun on 2021/07/19.
//

import XCTest

class OffOff_iOSUITests: XCTestCase {

    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        // Put setup code here. This method is called before the invocation of each test method in the class.

    

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        
        

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testSignUpProcess() throws {
        let signUpButton = app.buttons["회원가입"].firstMatch
        signUpButton.tap()
        pause()
    }
    
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
