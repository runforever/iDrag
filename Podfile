# Uncomment this line to define a global platform for your project
platform :osx, '10.13'

target 'iDrag' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for iDrag
  pod "Qiniu", "~> 7.1"
  pod "CryptoSwift"
  pod "SwiftyJSON"
  pod "PromiseKit", "~> 4.0"
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.0'
    end
  end
end
