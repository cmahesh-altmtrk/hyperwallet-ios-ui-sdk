import XCTest

class TransactionDetails {
    var navigationBar: XCUIElement
    var receiptdetailtableviewTable: XCUIElement
    var detailSection: XCUIElement
    var feeSection: XCUIElement
    var transactionSection: XCUIElement
    var cellTextLabel: XCUIElement
    var detailTextLabel: XCUIElement
    var detailHeaderTitle: XCUIElement
    // Detail
    var receiptIdLabel: XCUIElement
    var dateLabel: XCUIElement
    var clientTransactionIdLabel: XCUIElement
    var charityNameLabel: XCUIElement
    var checkNumLabel: XCUIElement
    var promoWebSiteLabel: XCUIElement
    // Fee
    var amountLabel: XCUIElement
    var feeLabel: XCUIElement
    var transactionLabel: XCUIElement
    // Note
    var noteSectionLabel: XCUIElement
    // Back button
    var backButton: XCUIElement

    var app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
        navigationBar = app.navigationBars["Transaction Details"]
        detailHeaderTitle = app.navigationBars["Transaction Details"].otherElements["Transaction Details"]
        receiptdetailtableviewTable = app.tables["receiptDetailTableView"]
        cellTextLabel = receiptdetailtableviewTable.staticTexts["ListReceiptTableViewCellTextLabel"]
        detailTextLabel = receiptdetailtableviewTable.staticTexts["ListReceiptTableViewDetailTextLabel"]
        detailSection = receiptdetailtableviewTable.staticTexts["Details"]
        feeSection = receiptdetailtableviewTable.staticTexts["Fee Specification"]
        transactionSection = receiptdetailtableviewTable.staticTexts["Transaction"]
        receiptIdLabel = receiptdetailtableviewTable.staticTexts["Receipt ID:"]
        dateLabel = receiptdetailtableviewTable.staticTexts["Date:"]
        clientTransactionIdLabel = receiptdetailtableviewTable.staticTexts["Client Transaction ID:"]
        charityNameLabel = receiptdetailtableviewTable.staticTexts["Charity Name:"]
        checkNumLabel = receiptdetailtableviewTable.staticTexts["Check Number:"]
        promoWebSiteLabel = receiptdetailtableviewTable.staticTexts["Promo Website:"]
        noteSectionLabel = receiptdetailtableviewTable.staticTexts["Notes"]
        amountLabel = receiptdetailtableviewTable.staticTexts["Amount:"]
        feeLabel = receiptdetailtableviewTable.staticTexts["Fee:"]
        transactionLabel = receiptdetailtableviewTable.staticTexts["Transaction:"]
        backButton = navigationBar.children(matching: .button).matching(identifier: "Back").element(boundBy: 0)
    }

    func openReceipt(row: Int) {
        let row = app.tables.element.children(matching: .cell).element(boundBy: row)
        if row.exists {
            row.tap()
        }
    }
}
