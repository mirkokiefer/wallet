//
//  MockServer.swift
//  wallet
//
//  Created by Mirko on 3/24/15.
//  Copyright (c) 2015 LivelyCode. All rights reserved.
//

import Foundation

typealias Handler = () -> Void
typealias TransactionHandler = (transaction: Transaction) -> Void

class MockServer: Server {
    var receivingAmount: Double!
    var onReadCurrencies: Handler!
    var onSendTransaction: TransactionHandler!
    var expectedTransaction: Transaction!
    
    init() {
        
    }
    
    func readCurrencies(handler: ReadCurrenciesHandler) {
        let currencies = ["USD", "EUR", "ZAR"]
        handler(error: nil, currencies: currencies)
        onReadCurrencies()
    }
    
    func calculateReceiveAmount(sendAmount: Double, sendCurrency: String, receiveCurrency: String, handler: CalculateHandler) {
        handler(error: nil, result: self.receivingAmount)
    }
    
    func sendTransaction(transaction: Transaction, handler: SendMoneyHandler) {
        handler(error: nil)
        onSendTransaction(transaction: transaction)
    }
}
