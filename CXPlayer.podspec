#
# Be sure to run `pod lib lint CXPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CXPlayer'
  s.version          = '0.1.4'
  s.summary          = 'CXPlayer'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = '视频播放器封装'

  s.homepage         = 'https://github.com/caixiang305621856/CXPlayer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'caixiang' => 'yanyan305621856@sina.com' }
  s.source           = { :git => 'https://github.com/caixiang305621856/CXPlayer.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'CXPlayer/Classes/**/*'
  
   s.resource_bundles = {
     'CXPlayer' => ['CXPlayer/Assets/*.png']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
