#wallet demo

[![Build Status](https://travis-ci.org/mirkokiefer/wallet.png?branch=master)](https://travis-ci.org/mirkokiefer/wallet)

A simple wallet demo to demonstrate iOS testing with Swift and XCTest.

To run the tests:

```
xcodebuild test -workspace wallet.xcworkspace -scheme wallet -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO
```

##Testing approach
Testing the actual user interface is brittle and very expensive to maintain.
Small changes to the user interface usually require changing the tests, which defeats the very purpose of automated testing.

So I resorted to testing the layer right underneath the user interface.  
Problematic are cases where the app has to make use of exisiting framework objects.
In these cases I created small proxy objects like the `PeoplePickerPresenter` or `CurrencyPickerPresenter` that wrap those framework objects.
These could then be mocked in the unit tests which allows us to test if the general workflows of the app are working.

Important is to separate the view interaction and user workflow logic.
In the unit tests we can not rely on IBOutlets to be set, so the user workflow logic should not interact with these directly.
