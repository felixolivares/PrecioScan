# Uncomment the next line to define a global platform for your project
 platform :ios, '12.0'

target 'PrecioScan' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PrecioScan
  pod 'IQKeyboardManagerSwift'
  pod 'ChameleonFramework/Swift', :git => 'https://github.com/wowansm/Chameleon', :branch => 'swift5'
  pod 'Alamofire', '~> 4.5'
  pod 'JSQCoreDataKit', '~> 9.0.0'
  pod 'MKDropdownMenu'
  pod 'PopupDialog', '~> 0.6'
  pod 'PMSuperButton'
  pod "PromiseKit", "~> 6.8"
  pod "GMStepper", :git => 'https://github.com/gmertk/GMStepper.git', :branch => 'swift4'
  pod 'IQKeyboardManagerSwift'
  pod 'InteractiveSideMenu'
  pod "PWSwitch"
  pod 'TableViewReloadAnimation', '~> 0.0.5'
  pod 'SwipeCellKit', :git => 'https://github.com/SwipeCellKit/SwipeCellKit.git', :branch => 'develop'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'TransitionButton'
  pod 'ALCameraViewController'
  pod 'AXPhotoViewer'
  pod 'SwiftyStoreKit'
  pod 'SwiftyOnboard'
  pod 'Google-Mobile-Ads-SDK'
  pod 'FBSDKCoreKit/Swift'
  pod 'FBSDKLoginKit/Swift'
  pod 'FBSDKShareKit/Swift'
  pod 'SwiftySound'
  pod 'AlamofireImage', '~> 3.5'
  
  target 'PrecioScanTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'PrecioScanUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
	   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
            config.build_settings.delete('CODE_SIGNING_ALLOWED')
            config.build_settings.delete('CODE_SIGNING_REQUIRED')
        end
    end
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
