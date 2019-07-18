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
    case addTransferMethod
}

public class HyperwalletFlowListener {
    public static var flowDictionary = [HyperwalletFlow: NSObject.Type]()

    public init() {

    }

    public static func isFlowInitialized(flow: HyperwalletFlow) -> Bool {
        return flowDictionary[flow] != nil
    }

    public static func navigateToFlow(flow: HyperwalletFlow, viewController: UIViewController) {
        if let flowClass = flowDictionary[flow], let viewCont = flowClass.init() as? UIViewController {
            viewCont.hyperwalletFlowDelegate = viewController
            viewController.navigationController?.pushViewController(viewCont,
                                                                    animated: true)
        }
    }
}
