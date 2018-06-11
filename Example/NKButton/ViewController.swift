//
//  ViewController.swift
//  NKButton
//
//  Created by Nam Kennic on 03/10/2018.
//  Copyright (c) 2018 Nam Kennic. All rights reserved.
//

import UIKit
import NKButton
import NKFrameLayoutKit

extension NKButton {
	
	class func DefaultButton(title:String, color:UIColor) -> NKButton {
		let button: NKButton = NKButton(title: title, color: color)
		button.title = title
		button.titleLabel?.font = UIFont(name: "Helvetica", size: 14)
		
		button.setBackgroundColor(color, for: .normal)
		button.setShadowColor(color, for: .normal)
		
		button.shadowOffset = CGSize(width: 0, height: 5)
		button.shadowOpacity = 0.6
		button.shadowRadius = 10
		
		button.isRoundedButton = true
		
		return button
	}
	
}

class ViewController: UIViewController {
	var loginButton: NKButton!
	var facebookButton: NKButton!
	var twitterButton: NKButton!
	var forgotButton: NKButton!
	var frameLayout: NKGridFrameLayout!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		loginButton = NKButton.DefaultButton(title: "SIGN IN", color: UIColor(red:0.90, green:0.18, blue:0.15, alpha:1.00))
		loginButton.setImage(#imageLiteral(resourceName: "login"), for: .normal)
		loginButton.transitionToCircleWhenLoading = true
		loginButton.loadingIndicatorStyle = .ballScaleRippleMultiple
		loginButton.loadingIndicatorAlignment = .center
		loginButton.underlineTitleDisabled = true
		loginButton.spacing = 10.0 // space between icon and title
		loginButton.extendSize = CGSize(width: 50, height: 20)
		loginButton.imageAlignment = .right(toEdge: false)
		
		let facebookIcon = #imageLiteral(resourceName: "facebook")
		facebookButton = NKButton.DefaultButton(title: "FACEBOOK", color: UIColor(red:0.25, green:0.39, blue:0.80, alpha:1.00))
		facebookButton.setImage(facebookIcon, for: .normal)
		facebookButton.setImage(facebookIcon, for: .highlighted)
		facebookButton.setBackgroundColor(UIColor(red:0.45, green:0.59, blue:1.0, alpha:1.00), for: .highlighted)
		facebookButton.spacing = 10.0 // space between icon and title
//		facebookButton.transitionToCircleWhenLoading = true
		facebookButton.loadingIndicatorAlignment = .right
		facebookButton.underlineTitleDisabled = true
		facebookButton.loadingIndicatorStyle = .ballClipRotatePulse
		facebookButton.extendSize = CGSize(width: 50, height: 20)
		
		let twitterIcon = #imageLiteral(resourceName: "twitter")
		twitterButton = NKButton.DefaultButton(title: "TWITTER", color: UIColor(red:0.42, green:0.67, blue:0.91, alpha:1.00))
		twitterButton.setImage(twitterIcon, for: .normal)
		twitterButton.setImage(twitterIcon, for: .highlighted)
		twitterButton.setBackgroundColor(UIColor(red:0.45, green:0.59, blue:1.0, alpha:1.00), for: .highlighted)
		twitterButton.spacing = 10.0 // space between icon and title
		twitterButton.transitionToCircleWhenLoading = false
		twitterButton.imageAlignment = .top(toEdge: false)
		twitterButton.loadingIndicatorAlignment = .atImage
		twitterButton.hideImageWhileLoading = true
		twitterButton.hideTitleWhileLoading = false
		twitterButton.underlineTitleDisabled = true
		twitterButton.loadingIndicatorStyle = .ballBeat
		twitterButton.isRoundedButton = false
		twitterButton.cornerRadius = 10.0
		twitterButton.extendSize = CGSize(width: 50, height: 20)
		
		forgotButton = NKButton(title: "Forgot Password?", color: .clear)
		forgotButton.setImage(#imageLiteral(resourceName: "key"), for: .normal)
		forgotButton.setTitleColor(.gray, for: .normal)
		forgotButton.setTitleColor(.gray, for: .highlighted)
		forgotButton.setTitleColor(.gray, for: .disabled)
		forgotButton.showsTouchWhenHighlighted = true
		forgotButton.titleLabel?.font = UIFont(name: "Helvetica", size: 14)
		forgotButton.spacing = 5.0 // space between icon and title
		forgotButton.autoSetDisableColor = false
		forgotButton.extendSize = CGSize(width: 50, height: 20)
		
		loginButton.addTarget(self, action: #selector(onButtonSelected(_:)), for: .touchUpInside)
		facebookButton.addTarget(self, action: #selector(onButtonSelected(_:)), for: .touchUpInside)
		twitterButton.addTarget(self, action: #selector(onButtonSelected(_:)), for: .touchUpInside)
		forgotButton.addTarget(self, action: #selector(onButtonSelected(_:)), for: .touchUpInside)
		
		frameLayout = NKGridFrameLayout(direction: .vertical, andViews: [loginButton, facebookButton, twitterButton, forgotButton])
		frameLayout.layoutAlignment = .top
		frameLayout.intrinsicSizeEnabled = true
		frameLayout.spacing = 40
//		frameLayout.showFrameDebug = true // uncomment this to see how frameLayout layout its contents
		
		self.view.addSubview(loginButton)
		self.view.addSubview(facebookButton)
		self.view.addSubview(twitterButton)
		self.view.addSubview(forgotButton)
		self.view.addSubview(frameLayout)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
			self.viewDidLayoutSubviews()
		}
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let viewSize = self.view.bounds.size
		let contentSize = frameLayout.sizeThatFits(CGSize(width: viewSize.width * 0.9, height: viewSize.height))
		frameLayout.frame = CGRect(x: (viewSize.width - contentSize.width)/2, y: (viewSize.height - contentSize.height)/2, width: contentSize.width, height: contentSize.height)
	}
	
	@objc func onButtonSelected(_ button: NKButton) {
		print("Button Selected")
		
		button.isLoading = true
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
			button.isLoading = false
			
			/*
			button.expandFullscreen(duration: 0.5, completionBlock: { (sender) in
				UIView.animate(withDuration: 0.25, animations: {
					button.alpha = 0.0
				})
			})
			*/
		}
	}

}

