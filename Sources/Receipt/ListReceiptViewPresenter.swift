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

protocol ListReceiptView: class {
    func hideLoading()
    func loadReceipts()
    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?)
    func showLoading()
}

final class ListReceiptViewPresenter {
    private unowned let view: ListReceiptView
    private var transferMethods = [HyperwalletTransferMethod]()
    var sectionData: [Date: [HyperwalletReceipt]] = [:]
//    var sections = [ListReceiptSectionData]()
    var nextLink: URL?
    private var currentPage = 0
    private var limit = 10
    private var isFetchInProgress = false

    /// Initialize ListTransferMethodPresenter
    init(view: ListReceiptView) {
        self.view = view
    }

    func listTransactionReceipt() {
        // 1
        guard !isFetchInProgress else {
            return
        }

        // 2
        isFetchInProgress = true
        view.showLoading()
        let pagination = HyperwalletReceiptQueryParam()
        pagination.offset = currentPage
        pagination.limit = limit
        pagination.sortBy = .descendantCreatedOn
        Hyperwallet.shared.listTransactionReceipts(pagination: pagination, completion: listTransactionReceiptHandler())
    }

    private func getReceipt(at index: Int, in section: Int) -> HyperwalletReceipt? {
        let rowItems = Array(sectionData)[section].value
        return rowItems[index]
//        return sections[section].rowItems[index]
    }

    private func listTransactionReceiptHandler()
        -> (HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType?) -> Void {
            return { [weak self] (result, error) in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.isFetchInProgress = false
                    strongSelf.view.hideLoading()
                    if let error = error {
                        strongSelf.view.showError(error, { strongSelf.listTransactionReceipt() })
                        return
                    } else if let result = result {
                        strongSelf.currentPage += strongSelf.limit
                        strongSelf.groupTransactionsByMonth(result.data)
                        strongSelf.view.loadReceipts()
                    }
                }
            }
    }

    //swiftlint:disable force_cast
    private func groupTransactionsByMonth(_ receipts: [HyperwalletReceipt]) {
        //self.transferMethods.append(contentsOf: transferMethods)
        let currentSectionData = Dictionary(grouping: receipts, by: { (receipt) in
            firstDayOfMonth(date: parseDate(receipt.createdOn as! String))
        })

        for (date, receipts) in currentSectionData {
            if sectionData.keys.contains(date) {
                sectionData[date]?.append(contentsOf: receipts)
            } else {
                sectionData[date] = receipts
            }
        }
//        sectionData = [Date: [HyperwalletTransferMethod]](uniqueKeysWithValues: sectionData.reversed())
//        sectionData = [Date: [HyperwalletTransferMethod]](uniqueKeysWithValues: sectionData.sorted {
//            $0.key.compare($1.key) == .orderedDescending
//        })

        dump("SectionData: \(sectionData)")
//        sections = ListReceiptSectionData.group(rowItems: self.transferMethods, by: { (transferMethod) in
//            firstDayOfMonth(date: parseDate(transferMethod.getField(fieldName: .createdOn) as! String))
//        })

//        if sectionData.isEmpty {
//            sectionData = [sections.first?.sectionItem: sections.first?.rowItems] as! [Date: [HyperwalletTransferMethod]]
//        } else {
//
//        }
    }

    private func parseDate(_ stringDate: String) -> Date {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'H:mm:ss"
        return formatter.date(from: stringDate)!
    }

    private func firstDayOfMonth(date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }

    func getCellConfiguration(for receiptIndex: Int, in section: Int) -> ListReceiptCellConfiguration? {
        if let receipt = getReceipt(at: receiptIndex, in: section),
            let country = receipt.currency,
            let transactionType = receipt.type?.rawValue,
            let createdOn = receipt.createdOn {
            return ListReceiptCellConfiguration(
                transferMethodType: transactionType.lowercased().localized(),
                transferMethodCountry: country.localized(),
                createdOn: parseDate(createdOn),
                transferMethodIconFont: HyperwalletIcon.of(receipt.entry?.rawValue ?? "").rawValue)
        }
        return nil
    }

    private func getLastDigits(_ transferMethod: HyperwalletTransferMethod, number: Int) -> String? {
        var accountId: String?
        switch transferMethod.getField(fieldName: .type) as? String {
        case "BANK_ACCOUNT", "WIRE_ACCOUNT":
            accountId = transferMethod.getField(fieldName: .bankAccountId) as? String
        case "BANK_CARD":
            accountId = transferMethod.getField(fieldName: .cardNumber) as? String

        default:
            break
        }
        return accountId?.suffix(startAt: number)
    }
}
