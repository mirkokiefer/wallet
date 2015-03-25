//
//  ViewController.swift
//  wallet
//
//  Created by Mirko on 3/23/15.
//  Copyright (c) 2015 LivelyCode. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    var server: Server = ServerImpl()

    func presentTransactionViewController() {
        server.readCurrencies { (error, currencies) -> Void in
            let navigationController = self.storyboard!.instantiateViewControllerWithIdentifier("TransactionNaviViewController") as UINavigationController
            let transactionController = navigationController.topViewController as TransactionViewController
            
            let transaction = Transaction()
            transaction.sendingCurrency = currencies![0]
            transaction.receivingCurrency = currencies![1]
            transactionController.transaction = transaction
            
            transactionController.peoplePicker = PeoplePickerPresenterImpl()
            
            let currencyPicker = CurrencyPickerPresenterImpl()
            currencyPicker.currencies = currencies
            transactionController.currencyPicker = currencyPicker
            
            transactionController.server = ServerImpl()
            
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    @IBAction func sendMoneyTapped(sender: AnyObject) {
        self.presentTransactionViewController()
    }
}

