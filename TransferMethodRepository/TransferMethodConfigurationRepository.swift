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

import Foundation
import HyperwalletSDK

public protocol TransferMethodConfigurationRepository {
    func getKeys(completion: @escaping (HyperwalletTransferMethodConfigurationKey?, HyperwalletErrorType?) -> Void)
    func getFields(country: String,
                   currency: String,
                   transferMethodType: String,
                   transferMethodProfileType: String,
                   completion: @escaping (HyperwalletTransferMethodConfigurationField?, HyperwalletErrorType?) -> Void)
    func refreshKeys()
    func refreshFields()
}

public class TransferMethodConfigurationRepositoryImpl: TransferMethodConfigurationRepository {
    private var transferMethodConfigurationKeys: HyperwalletTransferMethodConfigurationKey?
    private var transferMethodConfigurationFields: HyperwalletTransferMethodConfigurationField?

    public func getKeys(completion: @escaping (HyperwalletTransferMethodConfigurationKey?, HyperwalletErrorType?) -> Void) {
        guard let transferMethodConfigurationKeys = transferMethodConfigurationKeys else {
            Hyperwallet.shared.retrieveTransferMethodConfigurationKeys(
                request: HyperwalletTransferMethodConfigurationKeysQuery(),
                completion: { [weak self] (result, error) in
                    guard let strongSelf = self else {
                        return
                    }
                    if let error = error {
                        completion(nil, error)
                    } else if let result = result {
                        strongSelf.transferMethodConfigurationKeys = result
                        completion(result, nil)
                    }
                })
            return
        }
        completion(transferMethodConfigurationKeys, nil)
    }

    public func getFields(country: String,
                          currency: String,
                          transferMethodType: String,
                          transferMethodProfileType: String,
                          completion: @escaping (HyperwalletTransferMethodConfigurationField?,
        HyperwalletErrorType?) -> Void) {
        guard let transferMethodConfigurationFields = transferMethodConfigurationFields else {
            let fieldsQuery = HyperwalletTransferMethodConfigurationFieldQuery(
                country: country,
                currency: currency,
                transferMethodType: transferMethodType,
                profile: transferMethodProfileType
            )

            Hyperwallet.shared.retrieveTransferMethodConfigurationFields(
                request: fieldsQuery,
                completion: { [weak self] (result, error) in
                    guard let strongSelf = self else {
                        return
                    }
                    if let error = error {
                        completion(nil, error)
                    } else if let result = result {
                        strongSelf.transferMethodConfigurationFields = result
                        completion(result, nil)
                    }
                })
            return
        }
        completion(transferMethodConfigurationFields, nil)
    }

    public func refreshKeys() {
        transferMethodConfigurationKeys = nil
    }

    public func refreshFields() {
        transferMethodConfigurationFields = nil
    }
}
