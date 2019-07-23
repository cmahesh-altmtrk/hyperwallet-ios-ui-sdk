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

public enum HyperwalletFlow: String {
    case addSelectTransferMethod
    case addTransferMethod
}

public class HyperwalletFlowCoordinator {
    public static var flows = [HyperwalletFlow: NSObject.Type]()

    public static func isFlowInitialized(flow: HyperwalletFlow) -> Bool {
        return flows[flow] != nil
    }

    public static func navigateToFlow(flow: HyperwalletFlow,
                                      fromViewController: UIViewController,
                                      initializationData: [String: Any]? = nil) {
        if let toViewController = flows[flow],
            let initializedToViewController = toViewController.init() as? UIViewController {
            initializedToViewController.hyperwalletFlowDelegate = fromViewController
            if let initializationData = initializationData {
                initializedToViewController.initializationData = initializationData
            }
            fromViewController.navigationController?.pushViewController(initializedToViewController,
                                                                        animated: true)
        }
    }
}
