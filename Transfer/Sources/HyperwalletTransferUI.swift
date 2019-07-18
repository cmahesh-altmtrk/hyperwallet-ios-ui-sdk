//
// Copyright 2018 - Present Hyperwallet
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import HyperwalletSDK

public final class HyperwalletTransferUI {
    private static var instance: HyperwalletTransferUI?

    /// Returns the previously initialized instance of the Hyperwallet UI SDK interface object
    public static var shared: HyperwalletTransferUI {
        guard let instance = instance else {
            fatalError("Call HyperwalletUI.setup(_:) before accessing HyperwalletUI.shared")
        }
        return instance
    }

    /// Creates a new instance of the Hyperwallet UI SDK interface object. If a previously created instance exists,
    /// it will be replaced.
    ///
    /// - Parameter provider: a provider of Hyperwallet authentication tokens.
    public class func setup(_ provider: HyperwalletAuthenticationTokenProvider) {
        instance = HyperwalletTransferUI(provider)
    }

    private init(_ provider: HyperwalletAuthenticationTokenProvider) {
        Hyperwallet.setup(provider)
    }

    public func createTransferFromUserTableViewController(clientTransferId: String)
        -> CreateTransferTableViewController {
            return CreateTransferTableViewController(clientTransferId: clientTransferId)
    }

    public func createTransferFromPrepaidCardTableViewController(clientTransferId: String,
                                                                 sourceToken: String)
        -> CreateTransferTableViewController {
            return CreateTransferTableViewController(clientTransferId: clientTransferId, sourceToken: sourceToken)
    }

}

