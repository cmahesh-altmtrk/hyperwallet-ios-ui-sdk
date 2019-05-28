import XCTest

class BaseIndividualTests: XCTestCase {
    var app: XCUIApplication!
    var mockServer: HyperwalletMockWebServer!
    var spinner: XCUIElement!

    override func setUp() {
        continueAfterFailure = false

        mockServer = HyperwalletMockWebServer()
        mockServer.setUp()

        mockServer.setupStub(url: "/rest/v3/users/usr-token/authentication-token",
                             filename: "AuthenticationTokenResponse",
                             method: HTTPMethod.post)

        mockServer.setupStub(url: "/rest/v3/users/usr-token",
                             filename: "UserIndividualResponse",
                             method: HTTPMethod.get)

        mockServer.setupGraphQLIndividualStubs()

        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        mockServer.tearDown()
    }

    func stubGetUserDetailsResponse() -> String {
        return "UserIndividualResponse"
    }
}
