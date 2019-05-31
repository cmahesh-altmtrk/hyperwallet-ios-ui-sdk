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

public class SelectReceiptTypeViewController: UITableViewController {
    private var spinnerView: SpinnerView?
    private var presenter: SelectReceiptTypeViewPresenter!
    private let receiptTypeCellIdentifier = "receiptTypeCellIdentifier"

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "title_receipts".localized()
        largeTitle()
        setViewBackgroundColor()

        navigationItem.backBarButtonItem = UIBarButtonItem.back

        presenter = SelectReceiptTypeViewPresenter(view: self)
        presenter.listReceiptTypes()
        setupReceiptTypeTableView()
    }

    // MARK: - Table view data source

    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return presenter.numberOfCells
    }

    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Theme.Cell.smallHeight
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: receiptTypeCellIdentifier, for: indexPath)
        if let receiptTypeCell = cell as? SelectTypeTableViewCell {
            receiptTypeCell.configure(configuration: presenter.getCellConfiguration(for: indexPath.row))
        }
        return cell
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var controller: ListReceiptViewController
        switch indexPath.row {
        case 0:
            controller = ListReceiptViewController()

        default:
            let prepaidCard = presenter.getPrepaidCard(at: indexPath.row - 1)
            guard let token = prepaidCard.getField(fieldName: .token) as? String else {
                return
            }
            controller = ListReceiptViewController(prepaidCardToken: token)
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: set up list receipt table view
    private func setupReceiptTypeTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.tableFooterView = UIView()
        tableView.register(SelectTypeTableViewCell.self,
                           forCellReuseIdentifier: receiptTypeCellIdentifier)
    }
}

extension SelectReceiptTypeViewController: SelectReceiptTypeView {
    func loadReceiptTypes() {
        tableView.reloadData()
    }

    func showLoading() {
        if let view = self.navigationController?.view {
            spinnerView = HyperwalletUtilViews.showSpinner(view: view)
        }
    }

    func hideLoading() {
        if let spinnerView = self.spinnerView {
            HyperwalletUtilViews.removeSpinner(spinnerView)
        }
    }

    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?) {
        let errorView = ErrorView(viewController: self, error: error)
        errorView.show(retry)
    }
}
