Pod::Spec.new do |s|
s.name = 'UPYUNFusion'
s.version = '1.0.1'
s.license = { :type => 'MIT', :text => <<-LICENSE
                   Copyright (c) 2016年 UPYUN. All rights reserved.
                 LICENSE
               }
s.summary = 'UPYUN Upload SDK For iOS.'
s.homepage = 'https://github.com/upyun/ios-fusion-sdk'
s.authors = { 'UPYUN' => 'iOSTeam@upyun.com' }
s.source = { :git => 'https://github.com/upyun/ios-fusion-sdk.git', :tag => "v" + s.version.to_s }
s.requires_arc = true
s.ios.deployment_target = '7.0'
s.source_files = ['UpYunSDK/*.{h,m}', 'UpYunSDK/Utils/*.{h,m}', 'UpYunSDK/Utils/**/*.{h,m}']
s.resources = 'UpYunFusionSDKDemo/*.{jpg,png,xib}'
s.dependency "AliyunOSSiOS", "~> 2.2.0"
end