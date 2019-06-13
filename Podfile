use_frameworks!
inhibit_all_warnings!

platform :ios, '10.0'

target 'GithubViewer' do
    #Network
    pod 'Kingfisher', '5.3.0'
    pod 'Alamofire', '4.8.2'

    #Utils
    pod 'DITranquillity', '3.6.3'
    pod 'RxSwift', '5.0.0'
    pod 'RxCocoa', '5.0.0'

    #UI
    pod 'IGListKit', '3.4.0'
    pod 'PinLayout', '1.8.7'
    
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '5'
            end
        end
    end
end
