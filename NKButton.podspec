Pod::Spec.new do |s|
  s.name             = 'NKButton'
  s.version          = '4.7.1'
  s.summary          = 'A fully customizable UIButton'
  s.description      = <<-DESC
A fully customizable button that fills all lacked functions from UIButton like:
        + setBackgroundColor:forState:
        + setBorderColor:forState 
        + setShadowColor:forState
		+ setGradientColor:forState
        + cornerRadius and isRoundedButton
        + imageAlignment (top, left, bottom, right, topEdge, leftEdge, bottomEdge, rightEdge)
        + set spacing between image and text
        + set loading state with loading animation from NVActivityIndicator
        + a backgroundView to attach an UIVisualEffectView if you want
        + flash effect
        + hover gesture
                       DESC

  s.homepage         = 'https://github.com/kennic/NKButton'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nam Kennic' => 'namkennic@me.com' }
  s.source           = { :git => 'https://github.com/kennic/NKButton.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/namkennic'
  s.platform          = :ios, '9.0'
  s.ios.deployment_target = '9.0'
  s.swift_version = '5.2'
  
  s.source_files = 'NKButton/Classes/*.swift'
  s.frameworks = 'UIKit'
  s.dependency 'FrameLayoutKit'
  s.dependency 'NVActivityIndicatorView/AppExtension'
  
end
