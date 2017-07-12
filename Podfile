platform :ios, ’10.0’
use_frameworks!

def shared
    pod 'BNKit', :git => 'https://github.com/beeth0ven/BNKit.git', :branch => 'master'
    pod 'RxDataSources', '~> 1.0.0'
    pod 'Action'
    #    pod 'BNKit', :git => 'https://github.com/beeth0ven/BNKit.git', :commit => '8a46dc6'
end

target 'Internal' do
    shared
end

target 'QRCoder' do
    shared
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2.0'
            config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.10'
        end
    end
end

#   pod update --no-repo-update
#   The Podfile: http://guides.cocoapods.org/using/the-podfile.html
