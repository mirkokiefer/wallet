//
//  PersonPicker.swift
//  wallet
//
//  Created by Mirko on 3/23/15.
//  Copyright (c) 2015 LivelyCode. All rights reserved.
//

import UIKit
import AddressBookUI

protocol PeoplePickerPresenterDelegate {
    func peoplePicker(sender: PeoplePickerPresenter, didSelectPerson person: String)
    func peoplePickerDidCancel(sender: PeoplePickerPresenter)
}

protocol PeoplePickerPresenter {
    func setDelegate(delegate: PeoplePickerPresenterDelegate)
    func presentPeoplePickerWithParent(parent: UIViewController)
}

class PeoplePickerPresenterImpl: NSObject, PeoplePickerPresenter, ABPeoplePickerNavigationControllerDelegate {
    var delegate: PeoplePickerPresenterDelegate?
    
    func setDelegate(delegate: PeoplePickerPresenterDelegate) {
        self.delegate = delegate
    }

    func presentPeoplePickerWithParent(parent: UIViewController) {
        let peoplePicker = ABPeoplePickerNavigationController()
        peoplePicker.peoplePickerDelegate = self
        parent.presentViewController(peoplePicker, animated: true, completion: nil)
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecord!) {
        let name = ABRecordCopyCompositeName(person).takeRetainedValue() as String
        self.delegate?.peoplePicker(self, didSelectPerson: name)
    }
}
