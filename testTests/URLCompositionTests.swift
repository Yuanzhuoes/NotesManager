//
//  URLCompositionTests.swift
//  testTests
//
//  Created by leon on 12/07/2021.
//

import XCTest
@testable import test

class URLCompositionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMakingAURL() throws {
        for path in URL.Path.allCases {
            let url = URL.make(path: path)
            XCTAssertTrue(url != nil)
        }
    }
}
