import XCTest

class BaseTests: XCTestCase {
    var app: XCUIApplication!
    var mockServer: HyperwalletMockWebServer!
    var spinner: XCUIElement!
    var profileType: UserProfileType!

    override func setUp() {
        continueAfterFailure = false

        mockServer = HyperwalletMockWebServer()
        mockServer.setUp()

        mockServer.setupStub(url: "/rest/v3/users/usr-token/authentication-token",
                             filename: profileType.authenticationTokenResponseFileName,
                             method: HTTPMethod.post)

        mockServer.setupStub(url: "/rest/v3/users/usr-token",
                             filename: profileType.userProfileResponseFileName,
                             method: HTTPMethod.get)

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
