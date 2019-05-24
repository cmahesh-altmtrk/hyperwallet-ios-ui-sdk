import XCTest

class BaseBusinessTests: XCTestCase {
    var app: XCUIApplication!
    var mockServer: HyperwalletMockWebServer!
    var spinner: XCUIElement!

    override func setUp() {
        continueAfterFailure = false

        mockServer = HyperwalletMockWebServer()
        mockServer.setUp()

        mockServer.setupStub(url: "/rest/v3/users/usr-token/authentication-token",
                             filename: "AuthenticationTokenBusinessResponse",
                             method: HTTPMethod.post)

        mockServer.setupStub(url: "/rest/v3/users/usr-token",
                             filename: "UserBusinessResponse",
                             method: HTTPMethod.get)

        mockServer.setupGraphQLBusinessStubs()

        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        mockServer.tearDown()
    }
}
