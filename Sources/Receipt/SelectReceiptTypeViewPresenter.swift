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

protocol SelectReceiptTypeView: class {
    func hideLoading()
    func loadReceiptTypes()
    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?)
    func showLoading()
}

final class SelectReceiptTypeViewPresenter {
    private unowned let view: SelectReceiptTypeView
    private var prepaidCards = [HyperwalletBankAccount]()

    /// Initialize ListTransferMethodPresenter
    init(view: SelectReceiptTypeView) {
        self.view = view
    }

    var numberOfCells: Int {
        return prepaidCards.count + 1
    }

    func listReceiptTypes() {
        view.showLoading()
        listPrepaidCards()
    }

    func getPrepaidCard(at index: Int) -> HyperwalletBankAccount {
        return prepaidCards[index]
    }

    func getCellConfiguration(for receiptIndex: Int) -> SelectTypeCellConfiguration? {
        switch receiptIndex {
        case 0:
            return SelectTypeCellConfiguration(title: "account".localized(), value: nil)

        default:
            let prepaidCard = getPrepaidCard(at: receiptIndex - 1)
            var additionlInfo = prepaidCard.getField(fieldName: .bankAccountId) as? String
            additionlInfo = String(format: "%@%@",
                                   "transfer_method_list_item_description".localized(),
                                   additionlInfo?.suffix(startAt: 4) ?? "")
            return SelectTypeCellConfiguration(title: "card".localized(), value: additionlInfo)
        }
    }

    private func listPrepaidCards() {
        let bankAccountQueryParam = HyperwalletBankAccountQueryParam()
        bankAccountQueryParam.type = .bankAccount
        bankAccountQueryParam.sortBy = .descendantCreatedOn
        Hyperwallet.shared.listBankAccounts(queryParam: bankAccountQueryParam, completion: listPrepaidCardsHandler())
    }

    private func listPrepaidCardsHandler()
        -> (HyperwalletPageList<HyperwalletBankAccount>?, HyperwalletErrorType?) -> Void {
            return { [weak self] (result, error) in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.view.hideLoading()
                    if let error = error {
                        strongSelf.view.showError(error, { strongSelf.listReceiptTypes() })
                        return
                    } else if let result = result {
                        strongSelf.prepaidCards = result.data
                        strongSelf.view.loadReceiptTypes()
                    }
                }
            }
    }
}
