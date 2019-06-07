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

    private var offset = 0
    private let limit = 20
    private var prepaidCardReceiptCreatedAfter = Calendar.current.date(byAdding: .year, value: -1, to: Date())

    private var prepaidCardToken: String?
    private var isFetchInProgress = false
    private(set) var isFetchCompleted = true
    private(set) var groupedSectionArray = [(key: Date, value: [HyperwalletReceipt])]()

    private enum SortOrder: String {
        case asc
        case desc
    }

    /// Initialize ListTransferMethodPresenter
    init(view: ListReceiptView, prepaidCardToken: String? = nil) {
        self.view = view
        self.prepaidCardToken = prepaidCardToken
    }

    func listReceipts() {
        if let prepaidCardToken = prepaidCardToken {
            listPrepaidCardReceipts(prepaidCardToken)
        } else {
            listUserReceipts()
        }
    }

    func getCellConfiguration(for receiptIndex: Int, in section: Int) -> ListReceiptCellConfiguration? {
        let receipt = groupedSectionArray[section].value[receiptIndex]
        let currency = receipt.currency
        let type = receipt.type.rawValue
        let entry = receipt.entry.rawValue
        let createdOn = ISO8601DateFormatter
            .ignoreTimeZone
            .date(from: receipt.createdOn)!
            .format(for: .date)
        return ListReceiptCellConfiguration(
            type: type.lowercased().localized(),
            entry: entry,
            amount: receipt.amount,
            currency: currency,
            createdOn: createdOn,
            iconFont: HyperwalletIcon.of(receipt.entry.rawValue).rawValue)
    }

    private func setUpUserQueryParam() -> HyperwalletReceiptQueryParam {
        let queryParam = HyperwalletReceiptQueryParam()
        queryParam.offset = offset
        queryParam.limit = limit
        queryParam.sortBy = .descendantCreatedOn
        queryParam.createdAfter = Calendar.current.date(byAdding: .year, value: -1, to: Date())
        return queryParam
    }

    private func setUpPrepaidCardQueryParam() -> HyperwalletReceiptQueryParam {
        let queryParam = HyperwalletReceiptQueryParam()
//        queryParam.createdBefore = prepaidCardReceiptCreatedBefore
        queryParam.createdAfter = prepaidCardReceiptCreatedAfter
        return queryParam
    }

    private func listUserReceipts() {
        guard !isFetchInProgress else {
            return
        }

        isFetchInProgress = true
        view.showLoading()
        Hyperwallet.shared.listUserReceipts(queryParam: setUpUserQueryParam(), completion: listUserReceiptHandler())
    }

    private func listPrepaidCardReceipts(_ prepaidCardToken: String) {
        guard !isFetchInProgress else {
            return
        }

        isFetchInProgress = true
        view.showLoading()
        Hyperwallet.shared.listUserReceipts(queryParam: setUpPrepaidCardQueryParam(), completion: listPrepaidCardReceiptHandler())
    }

    private func listUserReceiptHandler()
        -> (HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType?) -> Void {
            return { [weak self] (result, error) in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.isFetchInProgress = false
                    strongSelf.view.hideLoading()
                    if let error = error {
                        strongSelf.view.showError(error, { strongSelf.listReceipts() })
                        return
                    } else if let result = result {
                        print("For User receipts: \(result.data.count)")
                        strongSelf.groupReceiptsByMonth(result.data, sortOrder: .desc)
                        strongSelf.isFetchCompleted = result.data.count < strongSelf.limit ? true : false
                        strongSelf.offset += result.data.count
                    }
                    strongSelf.view.loadReceipts()
                }
            }
    }

    private func listPrepaidCardReceiptHandler()
        -> (HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType?) -> Void {
            return { [weak self] (result, error) in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.isFetchInProgress = false
                    strongSelf.view.hideLoading()
                    if let error = error {
                        strongSelf.view.showError(error, { strongSelf.listReceipts() })
                        return
                    } else if let result = result {
                        print("For prepaid card receipts: \(result.data.count)")
                        strongSelf.groupReceiptsByMonth(result.data, sortOrder: SortOrder.asc)
                        strongSelf.isFetchCompleted = result.data.count < 10 ? true : false
                        print("prepaidCardReceiptCreatedAfter: \(strongSelf.prepaidCardReceiptCreatedAfter)")
                        print("result.data.last?.createdOn: \(result.data.last?.createdOn)")
                        if let createdOn = result.data.last?.createdOn,
                            let date = ISO8601DateFormatter.ignoreTimeZone.date(from: createdOn) {
                            strongSelf.prepaidCardReceiptCreatedAfter =
                                Calendar.current.date(byAdding: .second, value: 1, to: date)
                                ?? strongSelf.prepaidCardReceiptCreatedAfter
                        }
                    }
                    strongSelf.view.loadReceipts()
                }
            }
    }

    private func groupReceiptsByMonth(_ receipts: [HyperwalletReceipt], sortOrder: SortOrder) {
        let groupedSections = Dictionary(grouping: receipts,
                                         by: {
                                            ISO8601DateFormatter
                                                .ignoreTimeZone
                                                .date(from: $0.createdOn)!
                                                .firstDayOfMonth()
        })

        for section in groupedSections {
            if let sectionIndex = groupedSectionArray.firstIndex(where: { $0.key == section.key }) {
                groupedSectionArray[sectionIndex].value.append(contentsOf: section.value)
            } else {
                groupedSectionArray.append(section)
            }
        }
        groupedSectionArray = groupedSectionArray.sorted(by: sortOrder == SortOrder.desc ? { $0.key > $1.key }: { $1.key > $0.key })
    }
}
