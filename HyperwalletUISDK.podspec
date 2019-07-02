Pod::Spec.new do |s|
    s.name                  = 'HyperwalletUISDK'
    s.version               = '1.0.0-beta02'
    s.summary               = 'Hyperwallet UI SDK for iOS to integrate with Hyperwallet Platform'
    s.homepage              = 'https://github.com/hyperwallet/hyperwallet-ios-ui-sdk'
    s.license               = { :type => 'MIT', :file => 'LICENSE' }
    s.author                = { 'Hyperwallet Systems Inc' => 'devsupport@hyperwallet.com' }
    s.platform              = :ios
    s.ios.deployment_target = '10.0'
    s.source                = { :git => 'https://github.com/hyperwallet/hyperwallet-ios-ui-sdk.git', :commit => "527c51aa0dd8c1f60c8bc679a0f04670b840d536"}
    s.requires_arc          = true
    s.swift_version         = '4.2'
##s.resources             = ['HyperwalletCommon/**/*.xcassets', 'HyperwalletCommon/**/*.ttf']
    s.dependency 'HyperwalletSDK', '1.0.0-beta02'
##s.dependency 'HyperwalletCommon', '1.0.0-beta02'

    s.subspec "HyperwalletCommon" do |s|
##s.resources = ['HyperwalletCommon/**/*.xcassets', 'HyperwalletCommon/**/*.ttf', 'HyperwalletCommon/**/*.xib', 'HyperwalletCommon/**/*.strings']
##s.source_files  = "HyperwalletCommon/**/*.{swift,h}"
        s.source_files  = "HyperwalletCommon/**/*.{swift,h,strings,xib}"
        s.resources = ['HyperwalletCommon/**/*.xcassets', 'HyperwalletCommon/**/*.ttf']
        s.frameworks = "HyperwalletCommon"
    end

    s.subspec "TransferMethod" do |s|
        s.source_files = "HyperwalletTransferMethod/**/*.{swift,h}"
        s.dependency "HyperwalletUISDK/HyperwalletCommon"
        s.exclude_files = "HyperwalletCommon/**"
    end

##s.subspec "Receipt" do |s|
##s.source_files = "HyperwalletReceipt/**/*.{swift,h}"
##s.dependency "HyperwalletUISDK/HyperwalletCommon"
##end

    s.test_spec 'Tests' do |ts|
        ts.source_files = 'Tests/**/*.swift'
        ts.resources = 'Tests/**/*.json'
        ts.dependency 'Hippolyte', '0.6.0'
    end

    s.test_spec 'UITests' do |ts|
        ts.requires_app_host = true
        ts.source_files = 'UITests/**/*.swift'
        ts.resources = 'UITests/**/*.json'
        ts.dependency 'Swifter', '1.4.6'
    end
end
