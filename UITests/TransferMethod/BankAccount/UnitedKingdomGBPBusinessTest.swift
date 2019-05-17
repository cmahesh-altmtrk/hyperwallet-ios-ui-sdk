import XCTest

class UnitedKingdomGBPBusinessTest: AddTransferMethodBankAccountTest {
    override func setUp() {
        profileType = .business

        super.setUp()

        mockServer.setupGraphQLStubs(.unitedKingdomGBP, .business)
        setUpBankAccountScreen()
    }

    func testAddTransferMethod_displaysElementsOnTmcResponse() {
        XCTAssertTrue(app.navigationBars.staticTexts["Bank Account"].exists)
        XCTAssertTrue(app.staticTexts["Account Information - United Kingdom (GBP)"].exists )

        XCTAssertTrue(app.staticTexts["Branch Sorting Code"].exists)
        XCTAssertTrue(addTransferMethod.inputBankId.exists)

        XCTAssertTrue(app.staticTexts["Account Number"].exists)
        XCTAssertTrue(addTransferMethod.bankAccountIdInput.exists)

        XCTAssertTrue(app.staticTexts["First Name"].exists)
        XCTAssertTrue(addTransferMethod.inputFirstName.exists)

        XCTAssertTrue(app.staticTexts["Last Name"].exists)
        XCTAssertTrue(addTransferMethod.inputLastName.exists)

        XCTAssertTrue(app.staticTexts["Street"].exists)
        XCTAssertTrue(addTransferMethod.inputStreet.exists)

        XCTAssertTrue(app.staticTexts["City"].exists)
        XCTAssertTrue(addTransferMethod.inputCity.exists)

        XCTAssertTrue(app.staticTexts["Country"].exists)
        XCTAssertTrue(addTransferMethod.countrySelector.exists)

        XCTAssertTrue(app.staticTexts["State/Province"].exists)
        XCTAssertTrue(addTransferMethod.inputStateProvince.exists)

        XCTAssertTrue(app.staticTexts["Create Account"].exists)
    }

    func testAddTransferMethod_displaysFeeAndProcessingElementsOnTmcResponse() {
        var feesAndProcessingTime: String
        if #available(iOS 11.2, *) {
            feesAndProcessingTime = "Transaction Fees: GBP 1.50\nProcessing Time: 1 - 2 Business days"
        } else {
            feesAndProcessingTime = "Transaction Fees: GBP 1.50 Processing Time: 1 - 2 Business days"
        }
        XCTAssertTrue(addTransferMethod.addTMTableView.staticTexts[feesAndProcessingTime].exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidPattern() {
    }

    func testAddTransferMethod_returnsErrorOnInvalidPresence() {
        app.scrollToElement(element: addTransferMethod.createTransferMethodButton)
        addTransferMethod.clickCreateTransferMethodButton()

        XCTAssertTrue(addTransferMethod.addTMTableView.staticTexts["label_bankId_error"].exists)
        XCTAssertTrue(addTransferMethod.addTMTableView.staticTexts["label_bankAccountId_error"].exists)
        XCTAssertTrue(addTransferMethod.addTMTableView.staticTexts["label_firstName_error"].exists)
        XCTAssertTrue(addTransferMethod.addTMTableView.staticTexts["label_addressLine1_error"].exists)
        XCTAssertTrue(addTransferMethod.addTMTableView.staticTexts["label_city_error"].exists)
        XCTAssertTrue(addTransferMethod.addTMTableView.staticTexts["label_country_error"].exists)

        XCTAssertFalse(addTransferMethod.addTMTableView.staticTexts["label_lastName_error"].exists)
        XCTAssertFalse(addTransferMethod.addTMTableView.staticTexts["label_stateProvince_error"].exists)
        XCTAssertFalse(addTransferMethod.addTMTableView.staticTexts["label_postalCode_error"].exists)
    }

    func testAddTransferMethod_returnsErrorOnInvalidLength() {
        addTransferMethod.setTitle("Account Information - United Kingdom (GBP)")

        addTransferMethod.setBankId(bankId: "01234")
        XCTAssertTrue(addTransferMethod.addTMTableView.staticTexts["label_bankId_error"].exists)
        addTransferMethod.setBankId(bankId: "56")
        XCTAssertTrue(addTransferMethod.addTMTableView.staticTexts["label_bankId_error"].exists)

        addTransferMethod.setbankAccountId(accountNumber: "012345678")
        XCTAssertTrue(addTransferMethod.addTMTableView.staticTexts["label_bankAccountId_error"].exists)

        addTransferMethod.setFirstName(firstName: "123$%#$")
        XCTAssertTrue(addTransferMethod.addTMTableView.staticTexts["label_firstName_error"].exists)

        addTransferMethod.setAddress(address: String.random(length: 101))
        XCTAssertTrue(addTransferMethod.addTMTableView.staticTexts["label_addressLine1_error"].exists)

        addTransferMethod.setCity(city: String.random(length: 101))
        XCTAssertTrue(addTransferMethod.addTMTableView.staticTexts["label_city_error"].exists)
    }

    private func setUpBankAccountScreen() {
        app = XCUIApplication()

        selectTransferMethodType = SelectTransferMethodType(app: app)
        addTransferMethod = AddTransferMethod(app: app, for: .bankAccount)

        app.tables.cells.containing(.staticText, identifier: "Add Transfer Method").element(boundBy: 0).tap()
        spinner = app.activityIndicators["activityIndicator"]
        waitForNonExistence(spinner)

        selectTransferMethodType.selectCountry(country: "United Kingdom")
        selectTransferMethodType.selectCurrency(currency: "Pound Sterling")

        app.tables["transferMethodTableView"].staticTexts.element(matching: bankAccount).tap()
    }
}
