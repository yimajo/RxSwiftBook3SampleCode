# Uncomment the next line to define a global platform for your project

def install_test_pods
    pod 'RxTest'
    pod 'RxBlocking'
    pod 'Quick'
    pod 'Nimble'
end

abstract_target 'Sample' do

  platform :ios, '12.0'
  use_frameworks!

  pod 'RxSwift'
  pod 'RxCocoa'

  target 'RxSwiftBook3SampleCode' do
  end

  target 'Library' do
  end

  target 'SergdortStyle' do  
    target 'SergdortStyleTests' do
      inherit! :search_paths
      install_test_pods
    end
  end

  target 'KickstarterStyle' do
    target 'KickstarterStyleTests' do
      inherit! :search_paths
      install_test_pods
    end
  end
end

