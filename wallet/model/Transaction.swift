//
//  Transaction.swift
//  wallet
//
//  Created by Mirko on 3/23/15.
//  Copyright (c) 2015 LivelyCode. All rights reserved.
//

import Foundation

enum TransactionDirection {
    case Sending
    case Receiving
}

class Transaction: NSObject {
    dynamic var recipient: String?
    dynamic var sendingCurrency: String?
    dynamic var receivingCurrency: String?
    dynamic var sendingAmount: NSNumber?
    dynamic var receivingAmount: NSNumber?
    
    func currencyForTransactionDirection(direction: TransactionDirection) -> String? {
        switch direction {
        case .Sending:
            return self.sendingCurrency
        case .Receiving:
            return self.receivingCurrency
        }
    }
    
    func setCurrency(currency: String, forTransactionDirection direction: TransactionDirection) {
        switch direction {
        case .Sending:
            self.sendingCurrency = currency
        case .Receiving:
            self.receivingCurrency = currency
        }
    }
    
    class func currencyKeyForTransactionDirection(direction: TransactionDirection) -> String {
        switch direction {
        case .Sending:
            return "sendingCurrency"
        case .Receiving:
            return "receivingCurrency"
        }
    }
}
