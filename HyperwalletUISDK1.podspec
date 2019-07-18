Pod::Spec.new do |s|
    s.name                  = 'HyperwalletUISDK1'
    s.version               = '1.0.0-beta02'
    s.summary               = 'Hyperwallet UI SDK for iOS to integrate with Hyperwallet Platform'
    s.homepage              = 'https://github.com/hyperwallet/hyperwallet-ios-ui-sdk'
    s.license               = { :type => 'MIT', :file => 'LICENSE' }
    s.author                = { 'Hyperwallet Systems Inc' => 'devsupport@hyperwallet.com' }
    s.platform              = :ios
    s.ios.deployment_target = '10.0'
    s.source                = { :git => 'https://github.com/hyperwallet/hyperwallet-ios-ui-sdk.git', :branch => "poc/modularization-poc"}
    s.requires_arc          = true
    s.swift_version         = '4.2'
    s.dependency 'HyperwalletSDK', '1.0.0-beta02'

    s.subspec "HyperwalletCommon" do |common|
        common.resources = ['HyperwalletCommon/**/*.xcassets', 'HyperwalletCommon/**/*.ttf', 'HyperwalletCommon/**/*.xib', 'HyperwalletCommon/**/*.strings']
        common.source_files  = "HyperwalletCommon/**/*.{swift,h}"
    end

    s.subspec "TransferMethodRepository" do |transferMethodRepository|
        transferMethodRepository.source_files = "TransferMethodRepository/Sources/**/*.{swift,h}"
    end

    s.subspec "TransferMethod" do |transferMethod|
        transferMethod.source_files = "HyperwalletTransferMethod/Sources/**/*.{swift,h}"
        transferMethod.dependency "HyperwalletUISDK/HyperwalletCommon"
        transferMethod.dependency "HyperwalletUISDK/TransferMethodRepository"
    end

    s.subspec "Receipt" do |receipt|
        receipt.source_files = "HyperwalletReceipt/Sources/**/*.{swift,h}"
        receipt.dependency 'HyperwalletUISDK/HyperwalletCommon'
    end

    s.subspec "Transfer" do |transfer|
        transfer.source_files = "Transfer/Sources/**/*.{swift,h}"
        transfer.dependency 'HyperwalletUISDK/HyperwalletCommon'
        transfer.dependency 'HyperwalletUISDK/TransferMethod'
    end

    s.test_spec 'Tests' do |ts|
        ts.source_files = '/*/Tests/**/*.swift'
        ts.resources = '/*/Tests/**/*.json'
        ts.dependency 'Hippolyte', '0.6.0'
    end

    s.test_spec 'UITests' do |ts|
        ts.requires_app_host = true
        ts.source_files = 'UITests/**/*.swift'
        ts.resources = 'UITests/**/*.json'
        ts.dependency 'Swifter', '1.4.6'
    end
end

