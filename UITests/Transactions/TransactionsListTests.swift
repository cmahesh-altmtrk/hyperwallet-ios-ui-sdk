import XCTest

class TransactionsListTests: BaseTests {
    var selectTransferMethodType: SelectTransferMethodType!
    let debitCard = NSPredicate(format: "label CONTAINS[c] 'Debit Card'")

    override func setUp() {
        super.setUp()

        mockServer.setupStub(url: "/rest/v3/users/usr-token/receipts", filename: "Transactions", method: HTTPMethod.get)
        app.tables.cells.containing(.staticText, identifier: "List Receipts").element(boundBy: 0).tap()
    }

    override func tearDown() {
        mockServer.tearDown()
    }

    func testTransactionsList_verifyTransactionsOrder() {
        verifyCell(with: "Payment May 4, 2019", by: 0)
        verifyCell(with: "Bank Account May 12, 2019", by: 1)
        verifyCell(with: "Payment May 24, 2019", by: 2)
        verifyCell(with: "Bank Account Apr 14, 2019", by: 3)
        verifyCell(with: "Payment Apr 19, 2019", by: 4)
        verifyCell(with: "Payment Apr 27, 2019", by: 5)
        verifyCell(with: "Payment Mar 18, 2019", by: 6)
        verifyCell(with: "Payment Mar 25, 2019", by: 7)
    }

    func testTransactionsList_verifySectionHeaders() {
        XCTAssertTrue(app.tables.staticTexts["May 2019"].exists)
        XCTAssertTrue(app.tables.staticTexts["April 2019"].exists)
        XCTAssertTrue(app.tables.staticTexts["March 2019"].exists)

        XCTAssertFalse(app.tables.cells.containing(.staticText, identifier: "May 2019").element.exists)
        XCTAssertFalse(app.tables.cells.containing(.staticText, identifier: "April 2019").element.exists)
        XCTAssertFalse(app.tables.cells.containing(.staticText, identifier: "March 2019").element.exists)
    }

    func testTransactionsList_verifyNumberOfTransactions() {
        let expectedNumberOfCells = 8
        XCTAssertEqual(app.tables.cells.count, expectedNumberOfCells)
    }

    private func verifyCell(with text: String, by index: Int) {
        XCTAssertTrue(app.cells.element(boundBy: index).staticTexts[text].exists)
    }
}
