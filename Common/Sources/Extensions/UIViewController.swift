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

import UIKit

public extension UIViewController {
    func largeTitle() {
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
    }

    func titleDisplayMode(_ mode: UINavigationItem.LargeTitleDisplayMode) {
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = mode
        }
    }

    func setViewBackgroundColor() {
        view.backgroundColor = Theme.ViewController.backgroundColor
    }

    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc
    func dismissKeyboard() {
        view.endEditing(true)
    }

    var stringClassName: String {
        return String(describing: self)
    }
}

extension UIViewController: HyperwalletFlowDelegate {
    @objc
    open func isComplete(response: HyperwalletModel) {
    }

    struct Holder {
        static var _hyperwalletFlowDelegate: HyperwalletFlowDelegate?
    }
    public weak var hyperwalletFlowDelegate: HyperwalletFlowDelegate? {
        get {
            return Holder._hyperwalletFlowDelegate
        }
        set(newValue) {
            Holder._hyperwalletFlowDelegate = newValue
        }
    }

//    public weak var hyperwalletFlowDelegate: HyperwalletFlowDelegate? {
//        get {
//            return self
//        }
//        set(newValue) {
//            self.hyperwalletFlowDelegate = newValue
//        }
//    }
}
