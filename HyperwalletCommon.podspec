Pod::Spec.new do |s|
    s.name                  = 'HyperwalletCommon'
    s.version               = '1.0.0-beta02'
    s.summary               = 'Hyperwallet UI SDK for iOS to integrate with Hyperwallet Platform'
    s.homepage              = 'https://github.com/hyperwallet/hyperwallet-ios-ui-sdk'
    s.license               = { :type => 'MIT', :file => 'LICENSE' }
    s.author                = { 'Hyperwallet Systems Inc' => 'devsupport@hyperwallet.com' }
    s.platform              = :ios
    s.ios.deployment_target = '10.0'
    s.source                = { :git => 'https://github.com/hyperwallet/hyperwallet-ios-ui-sdk.git', :commit => "0ed14b87499751d04233e1e9dd3c0868cbff5eb4"}
    s.requires_arc          = true
    s.swift_version         = '4.2'
    s.source_files  = "HyperwalletCommon/**/*.{swift,h,strings,xib}"
    s.resources = ['HyperwalletCommon/**/*.xcassets', 'HyperwalletCommon/**/*.ttf']
    s.module_name = "HyperwalletCommon"
    s.dependency 'HyperwalletSDK', '1.0.0-beta02'
end
