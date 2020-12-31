//
//  ViewController.swift
//  NKButton
//
//  Created by Nam Kennic on 03/10/2018.
//  Copyright (c) 2018 Nam Kennic. All rights reserved.
//

import UIKit
import NKButton
import FrameLayoutKit
#if canImport(NVActivityIndicatorView)
import NVActivityIndicatorView
#endif

extension NKButton {
	
	class func DefaultButton(title: String, color: UIColor) -> NKButton {
		let button = NKButton(title: title, buttonColor: color, shadowColor: color)
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
	let loginButton = NKButton.DefaultButton(title: "SIGN IN", color: UIColor(red:0.10, green:0.58, blue:0.15, alpha:1.00))
	let facebookButton = NKButton.DefaultButton(title: "FACEBOOK", color: UIColor(red:0.25, green:0.39, blue:0.80, alpha:1.00))
	let twitterButton = NKButton.DefaultButton(title: "TWITTER", color: UIColor(red:0.42, green:0.67, blue:0.91, alpha:1.00))
	let forgotButton = NKButton(title: "Forgot Password?", buttonColor: .clear)
	let flashButton = NKButton.DefaultButton(title: "TAP TO FLASH", color: UIColor(red:0.61, green:0.11, blue:0.08, alpha:1.00))
	var frameLayout: StackFrameLayout!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		loginButton.setImage(#imageLiteral(resourceName: "login"), for: .normal)
		#if canImport(NVActivityIndicatorView)
		loginButton.loadingIndicatorStyle = .ballScaleRippleMultiple
		#endif
		loginButton.loadingIndicatorAlignment = .center
		loginButton.underlineTitleDisabled = true
		loginButton.spacing = 10.0 // space between icon and title
		loginButton.extendSize = CGSize(width: 0, height: 20)
		loginButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
		loginButton.imageAlignment = .rightEdge(spacing: 10)
		loginButton.textAlignment = (.center, .right)
		loginButton.isRoundedButton = false
		loginButton.transitionToCircleWhenLoading = true
		
		let facebookIcon = #imageLiteral(resourceName: "facebook")
		facebookButton.setImage(facebookIcon, for: .normal)
		facebookButton.setImage(facebookIcon, for: .highlighted)
		facebookButton.setBackgroundColor(UIColor(red:0.45, green:0.59, blue:1.0, alpha:1.00), for: .highlighted)
		facebookButton.spacing = 10.0 // space between icon and title
		facebookButton.loadingIndicatorAlignment = .atImage
		facebookButton.underlineTitleDisabled = true
		#if canImport(NVActivityIndicatorView)
		facebookButton.loadingIndicatorStyle = .ballClipRotatePulse
		#endif
		facebookButton.extendSize = CGSize(width: 0, height: 20)
		facebookButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
		facebookButton.imageAlignment = .leftEdge(spacing: 0)
		facebookButton.isRoundedButton = false
		
		let twitterIcon = #imageLiteral(resourceName: "twitter")
		twitterButton.setImage(twitterIcon, for: .normal)
		twitterButton.setImage(twitterIcon, for: .highlighted)
		twitterButton.setBackgroundColor(UIColor(red:0.45, green:0.59, blue:1.0, alpha:1.00), for: .highlighted)
		twitterButton.setGradientColor([UIColor(white: 1.0, alpha: 0.5), UIColor(white: 1.0, alpha: 0.0)], for: .normal)
		twitterButton.setGradientColor([UIColor(white: 1.0, alpha: 0.0), UIColor(white: 1.0, alpha: 0.5)], for: .highlighted)
		twitterButton.spacing = 10.0 // space between icon and title
		twitterButton.imageAlignment = .top
		twitterButton.titleLabel?.textAlignment = .center
		twitterButton.loadingIndicatorAlignment = .atImage
		twitterButton.hideImageWhileLoading = true
		twitterButton.hideTitleWhileLoading = false
		twitterButton.underlineTitleDisabled = true
		#if canImport(NVActivityIndicatorView)
		twitterButton.loadingIndicatorStyle = .ballBeat
		#endif
		twitterButton.isRoundedButton = false
		twitterButton.cornerRadius = 10.0
		twitterButton.extendSize = CGSize(width: 50, height: 20)
		
		forgotButton.setImage(#imageLiteral(resourceName: "key"), for: .normal)
		forgotButton.setTitleColor(.gray, for: .normal)
		forgotButton.setTitleColor(.gray, for: .highlighted)
		forgotButton.setTitleColor(.gray, for: .disabled)
		forgotButton.showsTouchWhenHighlighted = true
		forgotButton.titleLabel?.font = UIFont(name: "Helvetica", size: 14)
		forgotButton.spacing = 5.0 // space between icon and title
		forgotButton.autoSetDisableColor = false
		forgotButton.isRoundedButton = true
		forgotButton.extendSize = CGSize(width: 20, height: 20)
		#if !canImport(NVActivityIndicatorView)
		forgotButton.loadingIndicatorStyle = .gray
		#endif
		forgotButton.borderSizes[.normal] = 1
		forgotButton.borderColors[.normal] = .gray
		forgotButton.borderDashPatterns[.normal] = [2, 2]
		
		flashButton.flashColor = .red
		flashButton.underlineTitleDisabled = true
		flashButton.extendSize = CGSize(width: 0, height: 20)
		
		let allButtons = [loginButton, facebookButton, twitterButton, forgotButton, flashButton]
		allButtons.forEach { (button) in
			button.addTarget(self, action: #selector(onButtonSelected), for: .touchUpInside)
			button.backgroundColors[.hovered] = .red
			if #available(iOS 13.4, *) {
				button.enablePointerInteraction()
			}
		}
		
		frameLayout = StackFrameLayout(axis: .vertical, distribution: .top, views: allButtons)
		frameLayout.isIntrinsicSizeEnabled = true
		frameLayout.spacing = 40
//		frameLayout.debug = true // uncomment this to see how frameLayout layout its contents
		
		view.addSubview(loginButton)
		view.addSubview(facebookButton)
		view.addSubview(twitterButton)
		view.addSubview(forgotButton)
		view.addSubview(flashButton)
		view.addSubview(frameLayout)
		
		// Example of NKButtonStack usage:
		
		let buttonStack = NKButtonStack<NKButton>()
		
		buttonStack.configurationBlock = { (button, item, index) in
			button.backgroundColors[.normal] = .brown
			button.backgroundColors[.highlighted] = .gray
			button.backgroundColors[.selected] = .red
			button.backgroundColors[[.selected, .highlighted]] = .green
			button.title = item.title
			button.setTitleFont(.systemFont(ofSize: 14, weight: .regular), for: .normal)
			button.setTitleFont(.systemFont(ofSize: 15, weight: .bold), for: .selected)
			button.extendSize = CGSize(width: 20, height: 20)
		}
		
		buttonStack.selectionBlock = { (button, item, index) in
			print("Selected: \(button)")
		}
		
		buttonStack.items = [NKButtonItem(title: "Section A"),
							 NKButtonItem(title: "Section B"),
							 NKButtonItem(title: "Section C")]
		view.addSubview(buttonStack)
		buttonStack.isRounded = true
		frameLayout + buttonStack
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let viewSize = view.bounds.size
		let contentSize = frameLayout.sizeThatFits(CGSize(width: viewSize.width * 0.9, height: viewSize.height))
		frameLayout.frame = CGRect(x: (viewSize.width - contentSize.width)/2, y: (viewSize.height - contentSize.height)/2, width: contentSize.width, height: contentSize.height)
	}
	
	@objc func onButtonSelected(_ button: NKButton) {
		print("Button Selected")
		
		if button == flashButton {
			button.startFlashing(flashDuration: 0.25, intensity: 0.9, repeatCount: 10)
			return
		}
		
		button.isLoading = true
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
			button.isLoading = false
		}
	}

}

