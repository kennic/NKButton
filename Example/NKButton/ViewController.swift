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
		
		button.roundedButton = true
		
		return button
	}
	
}

class ViewController: UIViewController {
	var loginButton: NKButton!
	var facebookButton: NKButton!
	var forgotButton: NKButton!
	var frameLayout: NKGridFrameLayout!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		let font = UIFont(name: "Helvetica", size: 14)
		
		loginButton = NKButton.DefaultButton(title: "SIGN IN", color: UIColor(red:0.90, green:0.18, blue:0.15, alpha:1.00))
		loginButton.setImage(#imageLiteral(resourceName: "login"), for: .normal)
		loginButton.transitionToCircleWhenLoading = true
		loginButton.loadingIndicatorStyle = .ballScaleRippleMultiple
		loginButton.loadingIndicatorAlignment = .center
		loginButton.underlineTitleDisabled = true
		loginButton.extendSize = CGSize(width: 50, height: 20)
		loginButton.imageAlignment = .right(toEdge: false)
		loginButton.spacing = 10.0
		
		let facebookIcon = #imageLiteral(resourceName: "facebook")
		facebookButton = NKButton.DefaultButton(title: "FACEBOOK", color: UIColor(red:0.25, green:0.39, blue:0.80, alpha:1.00))
		facebookButton.setImage(facebookIcon, for: .normal)
		facebookButton.setImage(facebookIcon, for: .highlighted)
		facebookButton.setBackgroundColor(UIColor(red:0.45, green:0.59, blue:1.0, alpha:1.00), for: .highlighted)
		facebookButton.spacing = 10.0
		facebookButton.transitionToCircleWhenLoading = true
		facebookButton.loadingIndicatorAlignment = .center
		facebookButton.underlineTitleDisabled = true
		facebookButton.loadingIndicatorStyle = .ballClipRotatePulse
		facebookButton.extendSize = CGSize(width: 50, height: 20)
		
		forgotButton = NKButton(title: "Forgot Password?", color: .clear)
		forgotButton.setImage(#imageLiteral(resourceName: "key"), for: .normal)
		forgotButton.setTitleColor(.gray, for: .normal)
		forgotButton.setTitleColor(.gray, for: .highlighted)
		forgotButton.titleLabel!.font = font
		forgotButton.showsTouchWhenHighlighted = true
		forgotButton.spacing = 5.0
		forgotButton.extendSize = CGSize(width: 10, height: 10)
		forgotButton.sizeToFit()
		forgotButton.autoSetDisableColor = false
		forgotButton.extendSize = CGSize(width: 50, height: 20)
		
		loginButton.addTarget(self, action: #selector(onButtonSelected(_:)), for: .touchUpInside)
		facebookButton.addTarget(self, action: #selector(onButtonSelected(_:)), for: .touchUpInside)
		forgotButton.addTarget(self, action: #selector(onButtonSelected(_:)), for: .touchUpInside)
		
		frameLayout = NKGridFrameLayout(direction: .vertical, andViews: [loginButton, facebookButton, forgotButton])
		frameLayout.spacing = 30
		
		self.view.addSubview(loginButton)
		self.view.addSubview(facebookButton)
		self.view.addSubview(forgotButton)
		self.view.addSubview(frameLayout)
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let viewSize = self.view.bounds.size
		let buttonSize = frameLayout.sizeThatFits(CGSize(width: viewSize.width * 0.8, height: viewSize.height))
		frameLayout.frame = CGRect(x: (viewSize.width - buttonSize.width)/2, y: (viewSize.height/2 - buttonSize.height)/2, width: buttonSize.width, height: buttonSize.height)
	}
	
	@objc func onButtonSelected(_ button: NKButton) {
		print("Button Selected")
		
		button.transitionToCircleWhenLoading = true
		button.isLoading = true
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
			button.isLoading = false
			
			/*
			self.button.expandFullscreen(duration: 0.5, completionBlock: { (sender) in
				UIView.animate(withDuration: 0.25, animations: {
					button.alpha = 0.0
				}, completion: { (finished) in
					button.alpha = 1.0
					button.isLoading = false
				})
			})
			*/
		}
	}

}

