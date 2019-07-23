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

#if !COCOAPODS
import Common
#endif
import HyperwalletSDK
import UIKit

/// Lists the user's transfer methods (bank account, bank card, PayPal account, prepaid card, paper check).
///
/// The user can deactivate and add a new transfer method.
public final class CreateTransferTableViewController: UITableViewController {
    typealias SelectItemHandler = (_ value: HyperwalletTransferMethod) -> Void
    typealias MarkCellHandler = (_ value: HyperwalletTransferMethod) -> Bool
    private var presenter: CreateTransferPresenter!
    private var spinnerView: SpinnerView?
    private var sourceToken: String?
    private var clientTransferId: String
    private var transferAmount: String?
    private var transferDescription: String?
    private var didSelectAddAccountCell = false

    private let registeredCells: [(type: AnyClass, id: String)] = [
        (AddAccountTableViewCell.self, AddAccountTableViewCell.reuseIdentifier),
        (CreateTransferSelectDestinationCell.self, CreateTransferSelectDestinationCell.reuseIdentifier),
        (CreateTransferUserInputCell.self, CreateTransferUserInputCell.reuseIdentifier),
        (CreateTransferButtonCell.self, CreateTransferButtonCell.reuseIdentifier),
        (CreateTransferNotesTableViewCell.self, CreateTransferNotesTableViewCell.reuseIdentifier)
    ]

    init(clientTransferId: String, sourceToken: String? = nil) {
        self.sourceToken = sourceToken
        self.clientTransferId = clientTransferId
        super.init(nibName: nil, bundle: nil)
    }

    // swiftlint:disable unavailable_function
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "transfer_funds".localized()
        largeTitle()
        setViewBackgroundColor()
        navigationItem.backBarButtonItem = UIBarButtonItem.back

        // setup table view
        setUpCreateTransferTableView()
        hideKeyboardWhenTappedAround()

        presenter = CreateTransferPresenter(clientTransferId, sourceToken, view: self)
        presenter.loadCreateTransfer()
    }

    private func setUpCreateTransferTableView() {
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.accessibilityIdentifier = "createTransferTableView"
        registeredCells.forEach {
            tableView.register($0.type, forCellReuseIdentifier: $0.id)
        }
    }
}

// MARK: - Create transfer table view dataSource
extension CreateTransferTableViewController {
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.sectionData.count
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.sectionData[section].rowCount
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCellConfiguration(indexPath)
    }

    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.sectionData[section].title
    }

    override public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let transferSection = presenter.sectionData[section] as? CreateTransferSectionTransferData {
            return transferSection.footer
        }

        return nil
    }

    private func getCellConfiguration(_ indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = presenter.sectionData[indexPath.section].cellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let section = presenter.sectionData[indexPath.section]
        switch section.createTransferSectionHeader {
        case .destination:
            getDestinationSectionCellConfiguration(cell)

        case .transfer:
            getTransferSectionCellConfiguration(cell, indexPath)

        case .notes:
            getNotesSectionCellConfiguration(cell)

        case .button:
            getButtonSectionCellConfiguration(cell)
        }
        return cell
    }

    private func getDestinationSectionCellConfiguration(_ cell: UITableViewCell) {
        if let tableViewCell = cell as? CreateTransferSelectDestinationCell,
            let transferMethod = presenter.selectedTransferMethod {
            tableViewCell.accessoryType = .disclosureIndicator
            tableViewCell.configure(transferMethod: transferMethod)
        } else if let tableViewCell = cell as? AddAccountTableViewCell {
            tableViewCell.configure()
        }
    }

    private func getTransferSectionCellConfiguration(_ cell: UITableViewCell, _ indexPath: IndexPath) {
        var transferAllFundSwitchOn = false
        if let tableViewCell = cell as? CreateTransferUserInputCell {
            tableViewCell.selectionStyle = UITableViewCell.SelectionStyle.none
            tableViewCell.configure(currency: presenter.selectedTransferMethod?.transferMethodCurrency, at: indexPath.row)
            tableViewCell.transferAllSwitchOn = { transferAllSwitch in
                transferAllFundSwitchOn = transferAllSwitch
            }
            tableViewCell.enteredAmount = { amount in
                if !transferAllFundSwitchOn {
                    self.transferAmount = amount
                }
            }
        }
    }

    private func getNotesSectionCellConfiguration(_ cell: UITableViewCell) {
        if let tableViewCell = cell as? CreateTransferNotesTableViewCell {
            tableViewCell.configure()
            tableViewCell.enteredNote = { note in
                self.transferDescription = note
            }
        }
    }

    private func getButtonSectionCellConfiguration(_ cell: UITableViewCell) {
        if let tableViewCell = cell as? CreateTransferButtonCell {
            tableViewCell.configure()
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapNext(sender:)))
            tableViewCell.addGestureRecognizer(tap)
        }
    }

    @objc
    private func didTapNext(sender: UITapGestureRecognizer) {
        presenter.createTransfer(amount: transferAmount, notes: transferDescription)
    }
}

// MARK: - Create transfer table view delegate
extension CreateTransferTableViewController {
    override public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        // TODO error will display here
        return nil
    }

    override public func tableView(_ tableView: UITableView,
                                   estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(Theme.Cell.headerHeight)
    }

    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return Theme.Cell.largeHeight

        default:
            return Theme.Cell.smallHeight
        }
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if presenter.sectionData[indexPath.section].createTransferSectionHeader
            == CreateTransferSectionHeader.destination,
        let sectionData = presenter.sectionData[indexPath.section] as? CreateTransferSectionDestinationData {
            if sectionData.isTransferMethodAvailable {
                didSelectAddAccountCell = false
                presenter.showSelectDestinationAccountView()
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
//                addTransferMethod()
                didSelectAddAccountCell = true
                navigateToAddTransferMethodFlow()
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}

// MARK: - CreateTransferView implementation
extension CreateTransferTableViewController: CreateTransferView {
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

    func showBusinessError(_ error: HyperwalletErrorType, _ handler: @escaping () -> Void) {
        // TODO show business error in footer 
    }

    func showCreateTransfer() {
        presenter.initializeSections()
        tableView.reloadData()
    }

    func showGenericTableView(items: [HyperwalletTransferMethod],
                              title: String,
                              selectItemHandler: @escaping SelectItemHandler,
                              markCellHandler: @escaping MarkCellHandler) {
        let genericTableView = GenericController < CreateTransferSelectDestinationCell,
            HyperwalletTransferMethod> ()

        genericTableView.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                             target: self,
                                                                             action: #selector(didTapAddButton))

        genericTableView.title = title
        genericTableView.items = items
        genericTableView.selectedHandler = selectItemHandler
        genericTableView.shouldMarkCellAction = markCellHandler
        show(genericTableView, sender: self)
    }

    @objc
    private func didTapAddButton(sender: AnyObject) {
//        addTransferMethod()
        navigateToAddTransferMethodFlow()
    }

    func navigateToAddTransferMethodFlow() {
        if HyperwalletFlowCoordinator.isFlowInitialized(flow: HyperwalletFlow.addTransferMethod) {
            HyperwalletFlowCoordinator.navigateToFlow(flow: HyperwalletFlow.addTransferMethod, fromViewController: self)
        } else {
            HyperwalletUtilViews.showAlert(self, title: "Error", message: "No Transfer Method module initialized")
        }
    }

//    private func addTransferMethod() {
//        let controller = SelectTransferMethodTypeTableViewController()
//        controller.largeTitle()
//        controller.createTransferMethodHandler = {
//            [weak self] (transferMethod: HyperwalletTransferMethod) -> Void in
//            // refresh transfer method list
//            self?.navigationController?.popViewController(animated: true)
//            self?.presenter.selectedTransferMethod = transferMethod
//            self?.presenter.loadCreateTransfer()
//        }
//        navigationController?.pushViewController(controller, animated: true)
//    }

    func showScheduleTransfer(_ transfer: HyperwalletTransfer, _ selectedTransferMethod: HyperwalletTransferMethod) {
        let scheduleTransferController = ScheduleTransferTableViewController(transferMethod: selectedTransferMethod,
                                                                             transfer: transfer)
        navigationController?.pushViewController(scheduleTransferController, animated: true)
    }

    func notifyTransferCreated(_ transfer: HyperwalletTransfer) {
        DispatchQueue.global(qos: .background).async {
            NotificationCenter.default.post(name: .transferCreated,
                                            object: self,
                                            userInfo: [UserInfo.transferCreated: transfer])
        }
    }
}

extension CreateTransferTableViewController {
    override public func didFlowComplete(with response: HyperwalletModel) {
        if !didSelectAddAccountCell {
            navigationController?.popViewController(animated: true)
        }
        presenter.selectedTransferMethod = response as? HyperwalletTransferMethod
        presenter.loadCreateTransfer()
    }
}
