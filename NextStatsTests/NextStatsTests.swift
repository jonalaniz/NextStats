//
//  NextStatsTests.swift
//  NextStatsTests
//
//  Created by Jon Alaniz on 11/7/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import XCTest
@testable import NextStats

class NextStatsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJSONDecodable() throws {
        // Get our bundle
        let bundle = Bundle(for: type(of: self))

        // Get our url's for the JSON files
        guard let workingURL = bundle.url(forResource: "working", withExtension: "json") else {
            XCTFail("Missing file: default.json")
            return
        }

        guard let testURL = bundle.url(forResource: "test", withExtension: "json") else {
            XCTFail("Missing file: test.json")
            return
        }

        // Grab the data and create an array to loop over and parse
        let workingData = try Data(contentsOf: workingURL)
        let testData = try Data(contentsOf: testURL)
        let testDataArray = [workingData, testData]

        // Prepare our Decoder
        let decoder = JSONDecoder()

        // Try decoding the working and test data
        for data in testDataArray {
            if let decodedJSON = try? decoder.decode(Monitor.self, from: data) {
                print(decodedJSON)
            } else {
                XCTFail("Could not parse JSON file \(testDataArray.firstIndex(of: data)!)")
            }
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
