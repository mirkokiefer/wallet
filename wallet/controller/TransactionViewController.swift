//
//  TransactionViewController.swift
//  wallet
//
//  Created by Mirko on 3/23/15.
//  Copyright (c) 2015 LivelyCode. All rights reserved.
//

import UIKit

typealias SuccessHandler = (error: NSError?) -> Void

class TransactionViewController: UITableViewController, PeoplePickerPresenterDelegate, UITextFieldDelegate, CurrencyPickerPresenterDelegate, UIAlertViewDelegate {
    
    var server: Server!
    var transaction: Transaction!
    var peoplePicker: PeoplePickerPresenter!
    var currencyPicker: CurrencyPickerPresenter!
    var editingCurrencyDirection: TransactionDirection?
    
    var sendButton: UIBarButtonItem {
        get {
            return self.navigationItem.rightBarButtonItems?[0] as UIBarButtonItem
        }
    }
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    @IBOutlet weak var recipientField: UITextField!
    @IBOutlet weak var sendingCurrencyButton: UIButton!
    @IBOutlet weak var receivingCurrencyButton: UIButton!
    @IBOutlet weak var sendingAmountField: UITextField!
    @IBOutlet weak var receivingAmountField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerEvents()
        self.sendingCurrencyButton.setTitle(transaction.sendingCurrency, forState: .Normal)
        self.receivingCurrencyButton.setTitle(transaction.receivingCurrency, forState: .Normal)
        
        let loadingIndicatorBarItem = UIBarButtonItem(customView: self.activityIndicator)
        let sendButton = self.navigationItem.rightBarButtonItem!
        self.navigationItem.rightBarButtonItems = [sendButton, loadingIndicatorBarItem]
    }
    
    func registerEvents() {
        transaction.bk_addObserverForKeyPath("recipient", task: { (sender) -> Void in
            self.recipientField.text = self.transaction.recipient
            self.updateSendButton()
        })
        transaction.bk_addObserverForKeyPath("sendingAmount", task: { (sender) -> Void in
            self.updateReceivingAmount()
            self.updateSendButton()
        })
        self.transaction.bk_addObserverForKeyPath("sendingCurrency", task: { (sender) -> Void in
            self.sendingCurrencyButton?.setTitle(self.transaction.sendingCurrency, forState: .Normal)
            self.updateReceivingAmount()
            self.updateSendButton()
        })
        self.transaction.bk_addObserverForKeyPath("receivingCurrency", task: { (sender) -> Void in
            self.receivingCurrencyButton?.setTitle(self.transaction.receivingCurrency, forState: .Normal)
            self.updateReceivingAmount()
            self.updateSendButton()
        })
        self.transaction.bk_addObserverForKeyPath("receivingAmount", task: { (sender) -> Void in
            self.updateSendButton()
            let receivingAmount = self.transaction.receivingAmount
            if (receivingAmount == nil) {
                self.receivingAmountField?.text = ""
                return
            }
            let text = receivingAmount!.stringValue
            dispatch_async(dispatch_get_main_queue(), {
                self.receivingAmountField?.text = text
                return
            })
        })
    }
    
    func updateReceivingAmount() {
        if transaction.sendingAmount == nil {
            transaction.receivingAmount = 0
            return
        }
        let sendingAmount = transaction.sendingAmount!.doubleValue
        let sendingCurrency = transaction.sendingCurrency!
        let receivingCurrency = transaction.receivingCurrency!
        self.receivingAmountField?.text = "Calculating..."
        self.server.calculateReceiveAmount(sendingAmount, sendCurrency: sendingCurrency, receiveCurrency: receivingCurrency, handler: { (error, result) -> Void in
            self.transaction.receivingAmount = result
        })
    }
    
    func updateSendButton() {
        dispatch_async(dispatch_get_main_queue(), {
            self.navigationItem.rightBarButtonItem?.enabled = self.canSendTransaction(self.transaction)
            return
        })
    }
    
    func canSendTransaction(transaction: Transaction) -> Bool {
        if (transaction.recipient == nil) {
            return false
        }
        if (transaction.sendingAmount == nil) {
            return false
        }
        if (transaction.receivingAmount == nil) {
            return false
        }
        return true
    }
    
    func presentPersonPicker() {
        self.peoplePicker.setDelegate(self)
        self.peoplePicker.presentPeoplePickerWithParent(self)
    }
    
    func presentCurrencyPickerForDirection(direction: TransactionDirection) {
        self.currencyPicker.setDelegate(self)
        self.editingCurrencyDirection = direction
        self.currencyPicker.presentCurrencyPickerWithParent(self)
    }
    
    func setSendAmount(amount: Double) {
        self.transaction.sendingAmount = amount
    }
    
    func sendTransaction(handler: SuccessHandler) {
        self.server.sendTransaction(transaction, handler: handler)
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendMoneyTapped(sender: AnyObject) {
        let recipient = self.transaction.recipient!
        let currency = self.transaction.sendingCurrency!
        let amount = self.transaction.sendingAmount!
        self.activityIndicator.startAnimating()
        self.sendButton.enabled = false
        self.sendTransaction { (error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let message = "\(currency) \(amount) will be transferred to \(recipient)."
                let alert = UIAlertView(title: "Transaction successful", message: message, delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Continue")
                alert.show()
            })
        }
    }
    
    @IBAction func selectSendingCurrencyTapped(sender: AnyObject) {
        self.presentCurrencyPickerForDirection(.Sending)
    }
    
    @IBAction func selectReceivingCurrencyTapped(sender: AnyObject) {
        self.presentCurrencyPickerForDirection(.Receiving)
    }
    
    @IBAction func didChangeSendingAmount(sender: AnyObject) {
        let sendingAmountString = self.sendingAmountField!.text
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        let amount = formatter.numberFromString(sendingAmountString)
        self.setSendAmount(amount!.doubleValue)
    }
    
    func peoplePicker(sender: PeoplePickerPresenter, didSelectPerson person: String) {
        self.transaction.recipient = person
    }
    
    func peoplePickerDidCancel(sender: PeoplePickerPresenter) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.presentPersonPicker()
        return false
    }
    
    func currencyPicker(sender: CurrencyPickerPresenter, didSelectCurrency currency: String) {
        self.transaction.setCurrency(currency, forTransactionDirection: self.editingCurrencyDirection!)
        self.editingCurrencyDirection = nil
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func currencyPickerDidCancel(sender: CurrencyPickerPresenter) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
