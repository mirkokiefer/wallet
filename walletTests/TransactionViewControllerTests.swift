//
//  TransactionViewControllerTests.swift
//  wallet
//
//  Created by Mirko on 3/23/15.
//  Copyright (c) 2015 LivelyCode. All rights reserved.
//

import UIKit
import XCTest

class MockPeoplePicker: PeoplePickerPresenterImpl {
    let selectedPerson: String
    
    init(selectedPerson: String) {
        self.selectedPerson = selectedPerson
    }
    
    override func presentPeoplePickerWithParent(parent: UIViewController) {
        self.delegate?.peoplePicker(self, didSelectPerson: self.selectedPerson)
    }
}

class MockCurrencyPicker: CurrencyPickerPresenter {
    var delegate: CurrencyPickerPresenterDelegate?
    let selectedCurrency: String
    
    init(selectedCurrency: String) {
        self.selectedCurrency = selectedCurrency
    }
    
    func setDelegate(delegate: CurrencyPickerPresenterDelegate) {
        self.delegate = delegate
    }
    
    func presentCurrencyPickerWithParent(parent: UIViewController) {
        self.delegate!.currencyPicker(self, didSelectCurrency: self.selectedCurrency)
    }
}

class TransactionViewControllerTests: XCTestCase {

    var controller: TransactionViewController!
    
    override func setUp() {
        super.setUp()
        self.controller = TransactionViewController()
        self.controller.transaction = Transaction()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testPickRecipient() {
        let expectedPerson = "Ann Lee"
        controller.peoplePicker = MockPeoplePicker(selectedPerson: expectedPerson)
        let selectRecipientExpectation = self.expectationWithDescription("select recipient")
        let transaction = controller.transaction
        controller.transaction.bk_addObserverForKeyPath("recipient", task: { (sender) -> Void in
            XCTAssertEqual(transaction.recipient!, expectedPerson, "correct person is set")
            selectRecipientExpectation.fulfill()
        })
        controller.presentPersonPicker()
        self.waitForExpectationsWithTimeout(1, handler: { (error) -> Void in
            println(error)
        })
    }
    
    func testPickSendingCurrency() {
        self.pickCurrencyForDirection(.Sending)
    }
    
    func testPickReceivingCurrency() {
        self.pickCurrencyForDirection(.Receiving)
    }
    
    func pickCurrencyForDirection(direction: TransactionDirection) {
        let expectedCurrency = "USD"
        controller.currencyPicker = MockCurrencyPicker(selectedCurrency: expectedCurrency)
        let selectCurrencyExpectation = self.expectationWithDescription("select currency")
        let transaction = controller.transaction
        
        let observerKey = Transaction.currencyKeyForTransactionDirection(direction)
        controller.transaction.bk_addObserverForKeyPath(observerKey, task: { (sender) -> Void in
            let currency = transaction.currencyForTransactionDirection(direction)
            XCTAssertEqual(currency!, expectedCurrency, "correct currency is set")
            selectCurrencyExpectation.fulfill()
        })
        controller.presentCurrencyPickerForDirection(direction)
        self.waitForExpectationsWithTimeout(1, handler: { (error) -> Void in
            println(error)
        })
    }
    
    func testUpdateSendAmountShouldUpdateReceiveAmount() {
        let mockServer = MockServer()
        let expectedReceivingAmount = 2.0
        mockServer.receivingAmount = expectedReceivingAmount
        controller.server = mockServer
        self.controller.registerEvents()
        controller.transaction.sendingCurrency = "USD"
        controller.transaction.receivingCurrency = "ZAR"
        let updateSendAmountExpectation = self.expectationWithDescription("update send amount")
        let updateReceiveAmountExpectation = self.expectationWithDescription("update receive amount")

        controller.transaction.bk_addObserverForKeyPath("sendingAmount", task: { (sender) -> Void in
            updateSendAmountExpectation.fulfill()
        })
        
        controller.transaction.bk_addObserverForKeyPath("receivingAmount", task: { (sender) -> Void in
            let receivingAmount = self.controller.transaction.receivingAmount
            XCTAssertEqual(receivingAmount!.doubleValue, expectedReceivingAmount, "set correct receiving amount")
            updateReceiveAmountExpectation.fulfill()
        })
        
        controller.setSendAmount(100)
        self.waitForExpectationsWithTimeout(1, handler: { (error) -> Void in
            println(error)
        })
    }
    
    func testSendTransaction() {
        let mockServer = MockServer()
        let sendTransactionExpectation = self.expectationWithDescription("send transaction")
        controller.server = mockServer
        
        let transaction = controller.transaction
        transaction.recipient = "Ann Lee"
        transaction.sendingCurrency = "USD"
        transaction.receivingCurrency = "ZAR"
        transaction.sendingAmount = 100
        transaction.receivingAmount = 1000
        
        mockServer.expectedTransaction = transaction
        mockServer.onSendTransaction = { (receivedTransaction) -> Void in
            XCTAssertEqual(receivedTransaction.recipient!, transaction.recipient!, "correct recipient")
            sendTransactionExpectation.fulfill()
        }
        
        self.controller.sendTransaction({ (error) -> Void in
            
        })
        self.waitForExpectationsWithTimeout(1, handler: { (error) -> Void in
            println(error)
        })
    }
    
    func testTransactionValidation() {
        let transaction = Transaction()
        transaction.sendingCurrency = "USD"
        transaction.receivingCurrency = "ZAR"
        XCTAssert(controller.canSendTransaction(transaction) == false)
        transaction.recipient = "Ann Lee"
        XCTAssert(controller.canSendTransaction(transaction) == false)
        transaction.sendingAmount = 100
        XCTAssert(controller.canSendTransaction(transaction) == false)
        transaction.receivingAmount = 1
        XCTAssert(controller.canSendTransaction(transaction) == true)
    }
}
