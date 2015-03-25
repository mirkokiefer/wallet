//
//  RootViewControllerTests.swift
//  wallet
//
//  Created by Mirko on 3/23/15.
//  Copyright (c) 2015 LivelyCode. All rights reserved.
//

import UIKit
import XCTest

class RootViewControllerTests: XCTestCase {
    
    var controller: RootViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        self.controller = storyboard.instantiateInitialViewController() as RootViewController
    }

    func testPresentTransactionViewControllerShouldFetchCurrencies() {
        let readCurrenciesExpectation = self.expectationWithDescription("read currencies")
        let mockServer = MockServer()
        mockServer.onReadCurrencies = {
            readCurrenciesExpectation.fulfill()
        }
        controller.server = mockServer
        
        controller.presentTransactionViewController()
        self.waitForExpectationsWithTimeout(1, handler: { (error) -> Void in
            println(error)
        })
    }
}
