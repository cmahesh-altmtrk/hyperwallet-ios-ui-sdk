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

extension UIView {
    /// Top Anchor
    var safeAreaTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return self.topAnchor
        }
    }

    /// Bottom Anchor
    var safeAreaBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.bottomAnchor
        }
    }
    /// Leading Anchor
    var safeAreaLeadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.leadingAnchor
        } else {
            return self.leadingAnchor
        }
    }

    /// Trailing Anchor
    var safeAreaTrailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.trailingAnchor
        } else {
            return self.trailingAnchor
        }
    }

    /// Add constraint based in Visual Format
    ///
    /// - parameter: format - The value should follow the visual format language
    /// - views
    public func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDict = [String: UIView]()

        for (index, view) in views.enumerated() {
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDict["v\(index)"] = view
        }

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format,
                                                      options: NSLayoutConstraint.FormatOptions(),
                                                      metrics: nil,
                                                      views: viewsDict))
    }

    /// Fill entire view to the super view
    public func addConstraintsFillEntireView(view: UIView) {
        addConstraintsWithFormat(format: "H:|[v0]|", views: view)
        addConstraintsWithFormat(format: "V:|[v0]|", views: view)
    }

    /// Defines fixed constraint validation to the attribute
    public func setConstraint(value: CGFloat, attribute: NSLayoutConstraint.Attribute) {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: attribute,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1 ,
                                            constant: value)
        addConstraint(constraint)
    }

    func setUpEmptyListLabel(text: String) -> UILabel {
        let emptyListLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 268, height: 20.5))
        emptyListLabel.text = text
        emptyListLabel.numberOfLines = 0
        emptyListLabel.lineBreakMode = .byWordWrapping
        emptyListLabel.textAlignment = .center
        emptyListLabel.accessibilityIdentifier = "EmptyListLabelAccessibilityIdentifier"

        self.addSubview(emptyListLabel)

        emptyListLabel.translatesAutoresizingMaskIntoConstraints = false

        let labelCenterXConstraint = NSLayoutConstraint(item: emptyListLabel,
                                                        attribute: .centerX,
                                                        relatedBy: .equal,
                                                        toItem: self,
                                                        attribute: .centerX,
                                                        multiplier: 1.0,
                                                        constant: 0.0)
        let labelCenterYConstraint = NSLayoutConstraint(item: emptyListLabel,
                                                        attribute: .centerY,
                                                        relatedBy: .equal,
                                                        toItem: self,
                                                        attribute: .centerY,
                                                        multiplier: 1.0,
                                                        constant: 0.0)

        let labelWidthConstraint = NSLayoutConstraint(item: emptyListLabel,
                                                      attribute: .width,
                                                      relatedBy: .equal,
                                                      toItem: nil,
                                                      attribute: .notAnAttribute,
                                                      multiplier: 1,
                                                      constant: 268)
        NSLayoutConstraint.activate([labelCenterXConstraint, labelCenterYConstraint, labelWidthConstraint])
        return emptyListLabel
    }

    func setUpEmptyListButton(text: String, firstItem: UIView) -> UIButton {
        let emptyListButton = UIButton(type: .system)
        emptyListButton.setTitle(text, for: .normal)
        emptyListButton.frame.size = CGSize(width: 90, height: 30)
        emptyListButton.accessibilityIdentifier = "emptyListButton"

        self.addSubview(emptyListButton)

        emptyListButton.translatesAutoresizingMaskIntoConstraints = false

        let buttonCenterXConstraint = NSLayoutConstraint(item: emptyListButton,
                                                         attribute: .centerX,
                                                         relatedBy: .equal,
                                                         toItem: self,
                                                         attribute: .centerX,
                                                         multiplier: 1.0,
                                                         constant: 0.0)
        let verticalConstraint = NSLayoutConstraint(item: firstItem,
                                                    attribute: .bottom,
                                                    relatedBy: .equal,
                                                    toItem: emptyListButton,
                                                    attribute: .top,
                                                    multiplier: 1,
                                                    constant: -8)
        NSLayoutConstraint.activate([buttonCenterXConstraint, verticalConstraint])
        return emptyListButton
    }
}
