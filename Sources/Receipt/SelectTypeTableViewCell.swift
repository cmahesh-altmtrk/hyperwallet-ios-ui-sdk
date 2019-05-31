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

import HyperwalletSDK
import UIKit

struct SelectTypeCellConfiguration {
    let title: String
    let value: String?

    var identifier: String {
        return "cell\(title)"
    }
}

final class SelectTypeTableViewCell: UITableViewCell {
    private var iconColor: UIColor!
    private var iconBackgroundColor: UIColor!
    // MARK: Life cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Theme manager's proxy properties
    @objc dynamic var titleLabelFont: UIFont! {
        get { return textLabel?.font }
        set { textLabel?.font = newValue }
    }

    @objc dynamic var titleLabelColor: UIColor! {
        get { return textLabel?.textColor }
        set { textLabel?.textColor = newValue }
    }

    @objc dynamic var subTitleLabelFont: UIFont! {
        get { return detailTextLabel?.font }
        set { detailTextLabel?.font = newValue
            detailTextLabel?.font = newValue }
    }

    @objc dynamic var subTitleLabelColor: UIColor! {
        get { return detailTextLabel?.textColor }
        set { detailTextLabel?.textColor = newValue }
    }
}

extension SelectTypeTableViewCell {
    func configure(configuration: SelectTypeCellConfiguration?) {
        if let configuration = configuration {
            textLabel?.attributedText = formatTextLabel(title: configuration.title)
            if let value = configuration.value {
                detailTextLabel?.attributedText = formatDetailTextLabel(value: value)
            }
            textLabel?.numberOfLines = 0
            textLabel?.lineBreakMode = .byWordWrapping
            detailTextLabel?.numberOfLines = 0
            detailTextLabel?.lineBreakMode = .byWordWrapping
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        imageView?.backgroundColor = iconBackgroundColor
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        imageView?.backgroundColor = iconBackgroundColor
    }

    private func formatTextLabel(title: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString()
        attributedText.append(value: title, font: titleLabelFont, color: titleLabelColor)
        return attributedText
    }

    private func formatDetailTextLabel(value: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString()
        attributedText.append(value: value, font: Theme.Label.captionOne, color: Theme.Label.subTitleColor )
        return attributedText
    }
}
