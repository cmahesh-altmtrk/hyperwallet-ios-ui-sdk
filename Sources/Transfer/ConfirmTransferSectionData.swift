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

enum ConfirmTransferSectionHeader: String {
    case destination, foreignExchange, summary, notes, button
}

protocol ConfirmTransferSectionData {
    var confirmTransferSectionHeader: ConfirmTransferSectionHeader { get }
    var rowCount: Int { get }
    var title: String? { get }
    var cellIdentifier: String { get }
}

extension ConfirmTransferSectionData {
    var rowCount: Int { return 1 }
    var title: String? { return confirmTransferSectionHeader != ConfirmTransferSectionHeader.button ? "confirm_transfer_section_header_\(confirmTransferSectionHeader.rawValue)".localized() : nil }
}

struct ConfirmTransferDestinationData: ConfirmTransferSectionData {
    var confirmTransferSectionHeader: ConfirmTransferSectionHeader { return .destination }
    var cellIdentifier: String { return ListTransferMethodTableViewCell.reuseIdentifier }
    var configuration: ListTransferMethodCellConfiguration?
    var transferMethod: HyperwalletTransferMethod

    init(transferMethod: HyperwalletTransferMethod) {
        self.transferMethod = transferMethod
        setUpCellConfiguration(transferMethod: transferMethod)
    }

    mutating func setUpCellConfiguration(transferMethod: HyperwalletTransferMethod) {
        if let country = transferMethod.getField(fieldName: .transferMethodCountry) as? String,
            let transferMethodType = transferMethod.getField(fieldName: .type) as? String {
            configuration = ListTransferMethodCellConfiguration(
                transferMethodType: transferMethodType.lowercased().localized(),
                transferMethodCountry: country.localized(),
                additionalInfo: getAdditionalInfo(transferMethod),
                transferMethodIconFont: HyperwalletIcon.of(transferMethodType).rawValue,
                transferMethodToken: transferMethod.getField(fieldName: .token) as? String ?? "")
        }
    }

    private func getAdditionalInfo(_ transferMethod: HyperwalletTransferMethod) -> String? {
        var additionlInfo: String?
        switch transferMethod.getField(fieldName: .type) as? String {
        case "BANK_ACCOUNT", "WIRE_ACCOUNT":
            additionlInfo = transferMethod.getField(fieldName: .bankAccountId) as? String
            additionlInfo = String(format: "%@%@",
                                   "transfer_method_list_item_description".localized(),
                                   additionlInfo?.suffix(startAt: 4) ?? "")
        case "BANK_CARD":
            additionlInfo = transferMethod.getField(fieldName: .cardNumber) as? String
            additionlInfo = String(format: "%@%@",
                                   "transfer_method_list_item_description".localized(),
                                   additionlInfo?.suffix(startAt: 4) ?? "")
        case "PAYPAL_ACCOUNT":
            additionlInfo = transferMethod.getField(fieldName: .email) as? String

        default:
            break
        }
        return additionlInfo
    }
}

struct ConfirmTransferForeignExchangeData: ConfirmTransferSectionData {
    var rows = [(title: String, value: String)]()
    var confirmTransferSectionHeader: ConfirmTransferSectionHeader { return .foreignExchange }
    var rowCount: Int { return rows.count }
    var cellIdentifier: String { return ConfirmTransferForeignExchangeCell.reuseIdentifier }
    var foreignExchanges: [HyperwalletForeignExchange]

    init(foreignExchanges: [HyperwalletForeignExchange]) {
        self.foreignExchanges = foreignExchanges

        for foreignExchange in foreignExchanges {
            let souceAmount = String(format: "%@ %@",
                                     foreignExchange.sourceAmount!,
                                     foreignExchange.sourceCurrency!)
            let destinationAmount = String(format: "%@ %@",
                                           foreignExchange.destinationAmount!,
                                           foreignExchange.destinationCurrency!)
            let rate = String(format: "1 %@ = %@ %@",
                              foreignExchange.sourceCurrency!,
                              foreignExchange.rate!,
                              foreignExchange.destinationCurrency!)

            rows.append((title: "You sell:", value:souceAmount))
            rows.append((title: "You buy:", value: destinationAmount))
            rows.append((title: "Exchange Rate:", value: rate))
        }
    }
}

struct ConfirmTransferSummaryData: ConfirmTransferSectionData {
    var rows = [(title: String, value: String)]()
    var confirmTransferSectionHeader: ConfirmTransferSectionHeader { return .foreignExchange }
    var rowCount: Int { return 3 }
    var cellIdentifier: String { return ConfirmTransferButtonCell.reuseIdentifier }
    var foreignExchanges: [HyperwalletForeignExchange]

    init(foreignExchanges: [HyperwalletForeignExchange]) {
        self.foreignExchanges = foreignExchanges
        for foreignExchange in foreignExchanges {
            rows.append((title: "You sell:", value: foreignExchange.sourceAmount! + foreignExchange.sourceCurrency!))
            rows.append((title: "You buy:", value: foreignExchange.destinationAmount! + foreignExchange.destinationCurrency!))
        }
    }
}

struct ConfirmTransferButtonData: ConfirmTransferSectionData {
    var confirmTransferSectionHeader: ConfirmTransferSectionHeader { return .button }
    var cellIdentifier: String { return ConfirmTransferButtonCell.reuseIdentifier }
}
