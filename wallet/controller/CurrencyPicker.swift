//
//  CurrencyPicker.swift
//  wallet
//
//  Created by Mirko on 3/23/15.
//  Copyright (c) 2015 LivelyCode. All rights reserved.
//

import UIKit

protocol CurrencyPickerPresenterDelegate {
    func currencyPicker(sender: CurrencyPickerPresenter, didSelectCurrency currency: String)
    func currencyPickerDidCancel(sender: CurrencyPickerPresenter)
}

protocol CurrencyPickerPresenter {
    func setDelegate(delegate: CurrencyPickerPresenterDelegate)
    func presentCurrencyPickerWithParent(parent: UIViewController)
}

class CurrencyPickerPresenterImpl: NSObject, CurrencyPickerPresenter {
    var currencies: [String]?
    var delegate: CurrencyPickerPresenterDelegate!
    
    func setDelegate(delegate: CurrencyPickerPresenterDelegate) {
        self.delegate = delegate
    }
    
    func presentCurrencyPickerWithParent(parent: UIViewController) {
        let navigationController = parent.storyboard!.instantiateViewControllerWithIdentifier("CurrencyPickerNaviController") as UINavigationController
        let currencyPickerController = navigationController.topViewController as CurrencyPickerViewController
        currencyPickerController.currencies = self.currencies
        currencyPickerController.onSelectCurrency = { (currency) in
            self.delegate.currencyPicker(self, didSelectCurrency: currency)
        }
        parent.presentViewController(navigationController, animated: true, completion: nil)
    }
}

typealias CurrencyHandler = (currency: String) -> Void

class CurrencyPickerViewController: UITableViewController {
    var currencies: [String]?
    var onSelectCurrency: CurrencyHandler!
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currencies!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        cell.textLabel?.text = self.currencies![indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currency = self.currencies![indexPath.row]
        onSelectCurrency(currency: currency)
    }
}

