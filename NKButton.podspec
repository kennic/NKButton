#
# Be sure to run `pod lib lint NKButton.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NKButton'
  s.version          = '3.7'
  s.summary          = 'A fully customizable UIButton'
  s.description      = <<-DESC
A fully customizable button that fills all lacked functions from UIButton like:
        + setBackgroundColor:forState:
        + setBorderColor:forState 
        + setShadowColor:forState
		+ setGradientColor:forState
        + cornerRadius and isRoundedButton
        + imageAlignment (left, top, bottom, right)
        + set spacing between image and text
        + set loading state with loading animation from NVActivityIndicator
        + animate to circle shape while loading
        + a backgroundView to attach an UIVisualEffectView if you want
                       DESC

  s.homepage         = 'https://github.com/kennic/NKButton'
  # s.screenshots    = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nam Kennic' => 'namkennic@me.com' }
  s.source           = { :git => 'https://github.com/kennic/NKButton.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/namkennic'

  s.ios.deployment_target = '8.0'
  s.swift_version = '4.2'
  
  s.source_files = 'NKButton/Classes/*.swift'
  
  # s.resource_bundles = {
  #   'NKButton' => ['NKButton/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'FrameLayoutKit'
  s.dependency 'NVActivityIndicatorView/AppExtension'
  
end
