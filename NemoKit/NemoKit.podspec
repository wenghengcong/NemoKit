#
# Be sure to run `pod lib lint NemoKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NemoKit'
  s.version          = '0.0.1'
  s.summary          = 'Objective-C Developement Kit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/wenghengcong/NemoKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wenghengcong' => 'wenghengcong@icoud.com' }
  s.source           = { :git => 'https://github.com/wenghengcong/NemoKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.libraries = 'z', 'sqlite3'
  s.frameworks = 'UIKit', 'CoreFoundation', 'CoreText', 'CoreGraphics', 'CoreImage', 'QuartzCore', 'ImageIO', 'AssetsLibrary', 'Accelerate', 'MobileCoreServices', 'SystemConfiguration','AudioToolbox'
  s.source_files = 'NemoKit/**/*.{h,m}'
  s.public_header_files = 'NemoKit/**/*.{h}'
  s.resources="NemoKit/Assets/*.{xcassets,plist,png}"

#   s.resource_bundles = {
#     'NemoKit' => ['NemoKit/Assets/*.png']
#   }

  # s.dependency 'AFNetworking', '~> 2.3'
end
