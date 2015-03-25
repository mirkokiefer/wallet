//
//  ServerProtocol.swift
//  wallet
//
//  Created by Mirko on 3/23/15.
//  Copyright (c) 2015 LivelyCode. All rights reserved.
//

import Foundation

typealias ReadCurrenciesHandler = (error: NSError?, currencies: [String]?) -> Void
typealias CalculateHandler = (error: NSError?, result: Double?) -> Void
typealias SendMoneyHandler = (error: NSError?) -> Void

protocol Server {
    func readCurrencies(handler: ReadCurrenciesHandler)
    func calculateReceiveAmount(sendAmount: Double, sendCurrency: String, receiveCurrency: String, handler: CalculateHandler)
    func sendTransaction(transaction: Transaction, handler: SendMoneyHandler)
}

class ServerImpl: NSObject, Server {
    let session = NSURLSession.sharedSession()
    
    func readCurrencies(handler: ReadCurrenciesHandler) {
        let url = NSURL(string: "https://wr-interview.herokuapp.com/api/currencies")
        let task = self.session.dataTaskWithURL(url!, completionHandler: { (data, res, err) -> Void in
            let httpRes = res as NSHTTPURLResponse
            if (err != nil) {
                return handler(error: err, currencies: nil)
            }
            if (httpRes.statusCode != 200) {
                let errorMessage = NSHTTPURLResponse.localizedStringForStatusCode(httpRes.statusCode)
                let error = NSError(domain: "worldremit", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                return handler(error: error, currencies: nil)
            }
            let array = NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: nil) as [String]
            handler(error: nil, currencies: array)
        })
        task.resume()
    }
    
    func calculateReceiveAmount(sendAmount: Double, sendCurrency: String, receiveCurrency: String, handler: CalculateHandler) {
        let urlString = "https://wr-interview.herokuapp.com/api/calculate?amount=\(sendAmount)&sendcurrency=\(sendCurrency)&receivecurrency=\(receiveCurrency)"
        let url = NSURL(string: urlString)
        let task = self.session.dataTaskWithURL(url!, completionHandler: { (data, res, err) -> Void in
            let httpRes = res as NSHTTPURLResponse
            if (err != nil) {
                return handler(error: err, result: nil)
            }
            if (httpRes.statusCode != 200) {
                let errorMessage = NSHTTPURLResponse.localizedStringForStatusCode(httpRes.statusCode)
                let error = NSError(domain: "worldremit", code: 2, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                return handler(error: error, result: nil)
            }
            let dict = NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: nil) as [String: AnyObject]
            let receiveAmount = dict["receiveamount"] as NSNumber
            handler(error: nil, result: receiveAmount.doubleValue)
        })
        task.resume()
    }
    
    func sendTransaction(transaction: Transaction, handler: SendMoneyHandler) {
        let url = NSURL(string: "https://wr-interview.herokuapp.com/api/send")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let dict = [
            "sendamount": transaction.sendingAmount!,
            "sendcurrency": transaction.sendingCurrency!,
            "receiveamount": transaction.receivingAmount!,
            "receivecurrency": transaction.receivingCurrency!,
            "recipient": transaction.recipient!
        ]
        let data = NSJSONSerialization.dataWithJSONObject(dict, options: .allZeros, error: nil)
        request.HTTPBody = data
        let task = self.session.dataTaskWithRequest(request, completionHandler: { (data, res, err) -> Void in
            let httpRes = res as NSHTTPURLResponse
            if (err != nil) {
                return handler(error: err)
            }
            if (httpRes.statusCode != 201) {
                let errorMessage = NSHTTPURLResponse.localizedStringForStatusCode(httpRes.statusCode)
                let error = NSError(domain: "worldremit", code: 3, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                return handler(error: error)
            }
            handler(error: nil)
        })
        task.resume()
    }
}
