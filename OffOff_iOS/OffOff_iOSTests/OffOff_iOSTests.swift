//
//  OffOff_iOSTests.swift
//  OffOff_iOSTests
//
//  Created by Lee Nam Jun on 2021/07/12.
//

import XCTest
@testable import OffOff_iOS

class OffOff_iOSTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print(#fileID, #function, #line, "")
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        print(#fileID, #function, #line, "")
    }
    
    func testFetchPostListWithApi() throws {
        PostServices.fetchPostList { (response) in
            print(response.request)  // original URL request
            print(response.response) // URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            
            
            print(#fileID, #function, #line, "")
        }
        
    }
    
}
