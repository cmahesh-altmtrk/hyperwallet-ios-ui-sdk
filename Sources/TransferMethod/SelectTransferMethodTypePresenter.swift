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

#if !COCOAPODS
import TransferMethodRepository
import UserRepository
#endif

protocol SelectTransferMethodTypeView: class {
    typealias SelectItemHandler = (_ value: GenericCellConfiguration) -> Void
    typealias MarkCellHandler = (_ value: GenericCellConfiguration) -> Bool
    typealias FilterContentHandler = ((_ items: [GenericCellConfiguration],
        _ searchText: String) -> [GenericCellConfiguration])

    func showGenericTableView(items: [GenericCellConfiguration],
                              title: String,
                              selectItemHandler: @escaping SelectItemHandler,
                              markCellHandler: @escaping MarkCellHandler,
                              filterContentHandler: @escaping FilterContentHandler)

    func navigateToAddTransferMethodController(country: String,
                                               currency: String,
                                               profileType: String,
                                               transferMethodTypeCode: String)
    func showAlert(message: String?)
    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?)
    func showLoading()
    func hideLoading()
    func transferMethodTypeTableViewReloadData()
    func countryCurrencyTableViewReloadData()
}

final class SelectTransferMethodTypePresenter {
    // MARK: properties
    private unowned let view: SelectTransferMethodTypeView
    private (set) var countryCurrencySectionData = [String]()
    private (set) var selectedCountry = ""
    private (set) var selectedCurrency = ""

    private var transferMethodConfigurationRepository: TransferMethodConfigurationRepository {
        return TransferMethodRepositoryFactory.shared.transferMethodConfigurationRepository()
    }

    private lazy var userRepository: UserRepository = {
        UserRepositoryFactory.shared.userRepository()
    }()

    var sectionData = [HyperwalletTransferMethodType]()

    /// Initialize SelectTransferMethodPresenter
    init(_ view: SelectTransferMethodTypeView) {
        self.view = view
    }

    /// Return the `SelectTransferMethodTypeConfiguration` based on the index
    func getCellConfiguration(indexPath: IndexPath) -> SelectTransferMethodTypeConfiguration? {
        guard let transferMethodType = sectionData[safe: indexPath.row] else {
            return nil
        }

        let feesProcessingTime = transferMethodType.formatFeesProcessingTime()
        let transferMethodIcon = HyperwalletIcon.of(transferMethodType.code!).rawValue

        return SelectTransferMethodTypeConfiguration(
            transferMethodTypeCode: transferMethodType.code,
            transferMethodTypeName: transferMethodType.name,
            feesProcessingTime: feesProcessingTime,
            transferMethodIconFont: transferMethodIcon)
    }

    /// Return the countryCurrency item composed by the tuple (title and value)
    func getCountryCurrencyConfiguration(indexPath: IndexPath) -> GenericCellConfiguration? {
        guard let title = countryCurrencySectionData[safe: indexPath.row] else {
            return nil
        }
        return SelectedContryCurrencyCellConfiguration(title: title.localized(),
                                                       value: countryCurrencyValues(at: indexPath.row))
    }

    /// Display all the select Country or Currency based on the index
    func performShowSelectCountryOrCurrencyView(index: Int) {
        transferMethodConfigurationRepository.getKeys(completion: self.getKeysHandler({ (result) in
            if index == 0 {
                self.showSelectCountryView(result?.countries())
            } else {
                guard !self.selectedCountry.isEmpty else {
                    self.view.showAlert(message: "select_a_country_message".localized())
                    return
                }
                self.showSelectCurrencyView(result?.currencies(from: self.selectedCountry))
            }
        }))
    }

    /// Loads the transferMethodKeys from core SDK and display the default transfer methods
    ///
    /// - Parameter forceUpdate: Forces to refresh the data manager
    func loadTransferMethodKeys(_ forceUpdate: Bool = false) {
        view.showLoading()

        if forceUpdate {
            userRepository.refreshUser()
            transferMethodConfigurationRepository.refreshKeys()
        }

        userRepository.getUser { [weak self] getUserResult in
            guard let strongSelf = self else {
                return
            }

            switch getUserResult {
            case .failure(let error):
                strongSelf.view.hideLoading()
                strongSelf.view.showError(error, { () -> Void in
                    strongSelf.loadTransferMethodKeys()
                })

            case .success(let user):
                strongSelf.transferMethodConfigurationRepository
                    .getKeys(completion: strongSelf.getKeysHandler({ (result) in
                        strongSelf.countryCurrencySectionData = ["Country", "Currency"]
                        strongSelf.loadSelectedCountry(result?.countries(), with: user?.country)
                        strongSelf.loadSelectedCurrency(result?.currencies(from: strongSelf.selectedCountry))
                        strongSelf.loadTransferMethodTypes(
                            result?.transferMethodTypes(countryCode: strongSelf.selectedCountry,
                                                        currencyCode: strongSelf.selectedCurrency))
                    }, { strongSelf.loadTransferMethodKeys() }))
            }
        }
    }

    /// Navigate to AddTransferMethodController
    func navigateToAddTransferMethod(_ index: Int) {
        userRepository.getUser {[weak self] (getUserResult) in
            guard let strongSelf = self else {
                return
            }

            if case let .success(user) = getUserResult,
                let profileType = user?.profileType?.rawValue {
                let transferMethodTypeCode = strongSelf.sectionData[index].code!
                strongSelf.view.navigateToAddTransferMethodController(country: strongSelf.selectedCountry,
                                                                      currency: strongSelf.selectedCurrency,
                                                                      profileType: profileType,
                                                                      transferMethodTypeCode: transferMethodTypeCode)
            }
        }
    }

    private func countryCurrencyValues(at index: Int) -> String {
        return (index == 0 ? selectedCountry.localized() : selectedCurrency)
    }

    private func getKeysHandler(
        _ successHandler: @escaping ((HyperwalletTransferMethodConfigurationKey?) -> Void),
        _ failureHandler: (() -> Void)? = nil)
        -> (Result<HyperwalletTransferMethodConfigurationKey?, HyperwalletErrorType>) -> Void {
        return { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.view.hideLoading()

            switch result {
            case .failure(let error):
                strongSelf.view.showError(error, failureHandler)

            case .success(let keyResult):
                successHandler(keyResult)
            }
        }
    }

    /// Shows the Select Country View
    private func showSelectCountryView(_ countries: [GenericCellConfiguration]?) {
        guard let countries = countries else {
            view.showAlert(message: "no_country_available_error_message".localized())
            return
        }

        view.showGenericTableView(items: countries,
                                  title: "select_transfer_method_country".localized(),
                                  selectItemHandler: selectCountryHandler(),
                                  markCellHandler: countryMarkCellHandler(),
                                  filterContentHandler: filterContentHandler())
    }

    /// Shows the Select Currency View
    private func showSelectCurrencyView(_ currencies: [GenericCellConfiguration]?) {
        guard let currencies = currencies  else {
            view.showAlert(message: String(format: "no_currency_available_error_message".localized(),
                                           selectedCountry.localized()))
            return
        }

        view.showGenericTableView(items: currencies,
                                  title: "select_transfer_method_currency".localized(),
                                  selectItemHandler: selectCurrencyHandler(),
                                  markCellHandler: currencyMarkCellHandler(),
                                  filterContentHandler: filterContentHandler())
    }

    private func selectCountryHandler() -> SelectTransferMethodTypeView.SelectItemHandler {
        return { [weak self] (country) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.selectedCountry = country.value

            strongSelf.transferMethodConfigurationRepository
                .getKeys(completion: strongSelf.getKeysHandler({ (result) in
                    strongSelf.loadSelectedCurrency(result?.currencies(from: strongSelf.selectedCountry))
                    strongSelf.loadTransferMethodTypes(
                        result?.transferMethodTypes(countryCode: strongSelf.selectedCountry,
                                                    currencyCode: strongSelf.selectedCurrency))
            }))
        }
    }

    private func selectCurrencyHandler() -> SelectTransferMethodTypeView.SelectItemHandler {
        return { [weak self]  (currency) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.selectedCurrency = currency.value
            strongSelf.transferMethodConfigurationRepository
                .getKeys(completion: strongSelf.getKeysHandler({ (result) in
                    strongSelf.loadTransferMethodTypes(
                        result?.transferMethodTypes(countryCode: strongSelf.selectedCountry,
                                                    currencyCode: strongSelf.selectedCurrency))
                    strongSelf.view.countryCurrencyTableViewReloadData()
            }))
        }
    }

    private func filterContentHandler() -> SelectTransferMethodTypeView.FilterContentHandler {
        return {(items, searchText) in
            items.filter {
                // search by description
                $0.title.lowercased().contains(searchText.lowercased()) ||
                    //or code
                    $0.value.lowercased().contains(searchText.lowercased())
            }
        }
    }

    private func countryMarkCellHandler() -> SelectTransferMethodTypeView.MarkCellHandler {
        return { [weak self] item in
            self?.selectedCountry == item.value
        }
    }

    private func currencyMarkCellHandler() -> SelectTransferMethodTypeView.MarkCellHandler {
        return { [weak self] item in
            self?.selectedCurrency == item.value
        }
    }

    private func loadSelectedCountry(_ countries: [HyperwalletCountry]?,
                                     with userCountry: String?) {
        guard let countries = countries else {
            view.showAlert(message: "no_country_available_error_message".localized())
            return
        }

        if let userCountry = userCountry, countries.contains(where: { $0.value == userCountry }) {
            selectedCountry = userCountry
        } else if let country = countries.first {
            selectedCountry = country.value
        }
    }

    private func loadSelectedCurrency(_ currencies: [HyperwalletCurrency]?) {
        guard let firstCurrency = currencies?.min(by: { $0.name < $1.name }) else {
            view.showAlert(message: String(format: "no_currency_available_error_message".localized(),
                                           selectedCountry.localized()))
            selectedCurrency = ""
            view.countryCurrencyTableViewReloadData()
            return
        }
        selectedCurrency = firstCurrency.code
        view.countryCurrencyTableViewReloadData()
    }

    private func loadTransferMethodTypes(_ transferMethodTypes: [HyperwalletTransferMethodType]?) {
        guard let transferMethodTypes = transferMethodTypes, transferMethodTypes.isNotEmpty()  else {
                sectionData = [HyperwalletTransferMethodType]()
                view.showAlert(message: String(format: "no_transfer_method_available_error_message".localized(),
                                               selectedCountry,
                                               selectedCurrency))
                return
        }

        sectionData = transferMethodTypes
        view.transferMethodTypeTableViewReloadData()
    }
}
