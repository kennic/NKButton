//
//  NKButton.swift
//  NKButton
//
//  Created by Nam Kennic on 8/18/17.
//  Copyright © 2017 Nam Kennic. All rights reserved.
//

import UIKit
import NKFrameLayoutKit
import NVActivityIndicatorView

public typealias NKButtonAnimationCompletionBlock = ((_ sender: NKButton) -> Void)

public enum NKButtonLoadingIndicatorAlignment : String {
	case left	= "left"
	case center	= "center"
	case right	= "right"
	case atImage = "atImage"
}

public enum NKButtonImageAlignment {
	case left(toEdge:Bool)
	case right(toEdge:Bool)
	case top(toEdge:Bool)
	case bottom(toEdge:Bool)
}

open class NKButton: UIButton, CAAnimationDelegate {
	
	/** Set/Get title of the button */
	public var title : String? {
		get {
			return self.currentTitle
		}
		set {
			self.setTitle(newValue, for: .normal)
			self.setNeedsLayout()
		}
	}
	
	/** Space between image and text */
	public var spacing : CGFloat {
		get {
			return frameLayout.spacing
		}
		set {
			frameLayout.spacing = newValue
			frameLayout.setNeedsLayout()
			self.setNeedsLayout()
		}
	}
	
	/** Minimum size of imageView, set zero to width or height to disable */
	public var imageMinSize : CGSize {
		get {
			return imageFrame.minSize
		}
		set {
			imageFrame.minSize = newValue
			frameLayout.setNeedsLayout()
			self.setNeedsLayout()
		}
	}
	
	/** Maximum size of imageView, set zero to width or height to disable */
	public var imageMaxSize : CGSize {
		get {
			return imageFrame.maxSize
		}
		set {
			imageFrame.maxSize = newValue
			frameLayout.setNeedsLayout()
			self.setNeedsLayout()
		}
	}
	
	/** Fixed size of imageView, set zero to width or height to disable */
	public var imageFixSize : CGSize {
		get {
			return imageFrame.fixSize
		}
		set {
			imageFrame.fixSize = newValue
			frameLayout.setNeedsLayout()
			self.setNeedsLayout()
		}
	}
	
	/** Extend size that will be included in sizeThatFits function */
	public var extendSize : CGSize = .zero
	
	/** Corner Radius, will be ignored if `roundedButton` is true */
	public var cornerRadius : CGFloat = 0 {
		didSet {
			if cornerRadius != oldValue {
				self.setNeedsDisplay()
			}
		}
	}
	
	/** Shadow radius */
	public var shadowRadius : CGFloat = 0 {
		didSet {
			if shadowRadius != oldValue {
				self.setNeedsDisplay()
			}
		}
	}
	
	/** Shadow opacity */
	public var shadowOpacity : Float = 0.5 {
		didSet {
			if shadowOpacity != oldValue {
				self.setNeedsDisplay()
			}
		}
	}
	
	/** Shadow offset */
	public var shadowOffset : CGSize = .zero {
		didSet {
			if shadowOffset != oldValue {
				self.setNeedsDisplay()
			}
		}
	}
	
	/** Size of border */
	public var borderSize : CGFloat = 0 {
		didSet {
			if borderSize != oldValue {
				self.setNeedsDisplay()
			}
		}
	}
	
	/** Rounds both sides of the button */
	public var roundedButton : Bool = false {
		didSet {
			if roundedButton != oldValue {
				self.setNeedsLayout()
			}
		}
	}
	
	/** If `true`, title label will not underlined when `Settings > Accessibility > Button Shapes` is ON */
	public var underlineTitleDisabled : Bool = false {
		didSet {
			if underlineTitleDisabled != oldValue {
				self.setNeedsDisplay()
			}
		}
	}
	
	/** Image alignment */
	public var imageAlignment : NKButtonImageAlignment = .left(toEdge: false) {
		didSet {
			updateLayoutAlignment()
		}
	}
	
	/** Text Horizontal Alignment */
	public var textHorizontalAlignment: UIControlContentHorizontalAlignment {
		get {
			return self.textFrameLayout.contentHorizontalAlignment
		}
		set {
			self.textFrameLayout.contentHorizontalAlignment = newValue
		}
	}
	
	/** Text Vertical Alignment */
	public var textVerticalAlignment: UIControlContentVerticalAlignment {
		get {
			return self.textFrameLayout.contentVerticalAlignment
		}
		set {
			self.textFrameLayout.contentVerticalAlignment = newValue
		}
	}
	
	/** If `true`, disabled color will be set from normal color with tranparency */
	public var autoSetDisableColor : Bool = true
	/** If `true`, highlighted color will be set from normal color with tranparency */
	public var autoSetHighlightedColor : Bool = true
	
	/** Set loading state for this button */
	public var isLoading : Bool = false {
		didSet {
			if isLoading != oldValue {
				if isLoading {
					self.isEnabled = false
					showLoadingView()
					
					if transitionToCircleWhenLoading {
						self.titleLabel?.alpha = 0.0
						self.imageView?.alpha = 0.0
						transition(toCircle: true)
					}
					else {
						if hideImageWhileLoading {
							self.imageView?.alpha = 0.0
						}
						
						if hideTitleWhileLoading {
							self.titleLabel?.alpha = 0.0
						}
					}
				}
				else {
					self.isEnabled = true
					hideLoadingView()
					
					if transitionToCircleWhenLoading {
						self.titleLabel?.alpha = 1.0
						self.imageView?.alpha = 1.0
						transition(toCircle: false)
					}
					else {
						if hideImageWhileLoading {
							self.imageView?.alpha = 1.0
						}
						
						if hideTitleWhileLoading {
							self.titleLabel?.alpha = 1.0
						}
					}
				}
			}
		}
	}
	/** imageView will be hidden when `isLoading` is true */
	public var hideImageWhileLoading : Bool = false
	/** titleLabel will be hidden when `isLoading` is true */
	public var hideTitleWhileLoading : Bool = true
	/** Button will animated to circle shape when set `isLoading = true`*/
	public var transitionToCircleWhenLoading : Bool = false
	/** Color of loading indicator */
	public var loadingIndicatorStyle : NVActivityIndicatorType = .ballPulse
	/** Scale ratio of loading indicator, based on the minimum value of button size.width or size.height */
	public var loadingIndicatorScaleRatio : CGFloat = 0.7
	/** Color of loading indicator, if `nil`, it will use titleColor of normal state */
	public var loadingIndicatorColor : UIColor? = nil
	/** Alignment for loading indicator */
	public var loadingIndicatorAlignment : NKButtonLoadingIndicatorAlignment = .center
	/** `NKFrameLayout` that layout imageView */
	public var imageFrameLayout: NKFrameLayout! {
		get {
			return imageFrame
		}
	}
	/** `NKFrameLayout` that layout textLabel */
	public var textFrameLayout: NKFrameLayout! {
		get {
			switch imageAlignment {
			case .left(_):
				return frameLayout.rightFrameLayout
				
			case .right(_):
				return frameLayout.leftFrameLayout
				
			case .top(_):
				return frameLayout.bottomFrameLayout
				
			case .bottom(_):
				return frameLayout.topFrameLayout
			}
		}
	}
	/** NKDoubleFrameLayout that layout the content */
	public var contentFrameLayout: NKDoubleFrameLayout! {
		get {
			return frameLayout
		}
	}
	
	fileprivate var loadingView : NVActivityIndicatorView? = nil
	fileprivate var animationationDidEnd : NKButtonAnimationCompletionBlock? = nil
	fileprivate let shadowLayer 	= CAShapeLayer()
	fileprivate let backgroundLayer = CAShapeLayer()
	fileprivate var bgColorDict		: [String : UIColor] = [:]
	fileprivate var borderColorDict	: [String : UIColor] = [:]
	fileprivate var shadowColorDict	: [String : UIColor] = [:]
	fileprivate var imageFrame = NKFrameLayout()
	fileprivate var frameLayout = NKDoubleFrameLayout(direction: .horizontal)!
	
	// MARK: -
	
	public convenience init(title:String, color:UIColor) {
		self.init()
		self.title = title
		
//		self.setTitleColor(color.contrasting(), for: .normal)
		self.setBackgroundColor(color, for: .normal)
		self.setShadowColor(color, for: .normal)
	}
	
	init() {
		super.init(frame: .zero)
		
		self.layer.addSublayer(shadowLayer)
		self.layer.addSublayer(backgroundLayer)
		
		updateLayoutAlignment()
		
		frameLayout.layoutAlignment = .center
		frameLayout.intrinsicSizeEnabled = true
		
		imageFrame.contentAlignment = "cc"
		imageFrame.targetView = self.imageView
		
		self.addSubview(imageFrame)
		self.addSubview(frameLayout)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override open func sizeThatFits(_ size: CGSize) -> CGSize {
		var result = frameLayout.sizeThatFits(size)
		
//		if __CGSizeEqualToSize(result, .zero) {
//			result = super.sizeThatFits(size)
//		}
		
		result.width  += extendSize.width
		result.height += extendSize.height
		result.width  = min(result.width, size.width)
		result.height = min(result.height, size.height)
		
		return result
	}
	
	override open func sizeToFit() {
		let size = self.sizeThatFits(UIScreen.main.bounds.size)
		var frame = self.frame
		frame.size.width = size.width
		frame.size.height = size.height
		self.frame = frame
	}
	
	override open func draw(_ rect: CGRect) {
		super.draw(rect)
		
		var backgroundFrame: CGRect = UIEdgeInsetsInsetRect(bounds, contentEdgeInsets)
		backgroundFrame.origin.x = (bounds.size.width - backgroundFrame.size.width) / 2
		backgroundFrame.origin.y = (bounds.size.height - backgroundFrame.size.height) / 2
		
		let fillColor 	= self.backgroundColor(for: state)
		let borderColor = self.borderColor(for: state)
		let shadowColor	= self.shadowColor(for: state)
		let roundedPath = UIBezierPath(roundedRect: backgroundFrame, cornerRadius: cornerRadius)
		let path		= transitionToCircleWhenLoading && isLoading ? backgroundLayer.path : roundedPath.cgPath
		
		backgroundLayer.path			= path
		backgroundLayer.fillColor		= fillColor?.cgColor
		backgroundLayer.strokeColor		= borderColor?.cgColor
		backgroundLayer.lineWidth		= borderSize
		backgroundLayer.miterLimit		= roundedPath.miterLimit
		
		if shadowColor != nil {
			shadowLayer.isHidden 		= false
			shadowLayer.path 			= path
			shadowLayer.shadowPath 		= path
			shadowLayer.fillColor 		= shadowColor!.cgColor
			shadowLayer.shadowColor 	= shadowColor!.cgColor
			shadowLayer.shadowRadius 	= shadowRadius
			shadowLayer.shadowOpacity 	= shadowOpacity
			shadowLayer.shadowOffset 	= shadowOffset
		}
		else {
			shadowLayer.isHidden = true
		}
		
		if underlineTitleDisabled {
			self.disableUnderlineLabel()
		}
	}
	
	override open func layoutSubviews() {
		super.layoutSubviews()
		
		let viewSize = self.bounds.size
		shadowLayer.frame = self.bounds
		backgroundLayer.frame = self.bounds
		frameLayout.frame = self.bounds
		
		if self.imageView != nil {
			self.bringSubview(toFront: self.imageView!)
		}
		
		if loadingView != nil {
			var point = CGPoint(x: 0, y: viewSize.height / 2)
			switch (loadingIndicatorAlignment) {
			case .left: 	point.x = 5
			case .center: 	point.x = viewSize.width/2
			case .right: 	point.x = viewSize.width - loadingView!.frame.size.width - 5
			case .atImage:	point = self.imageView?.center ?? point
			}
			point.x += contentEdgeInsets.left / 2
			point.x -= contentEdgeInsets.right / 2
			point.y += contentEdgeInsets.top / 2
			point.y -= contentEdgeInsets.bottom / 2
			
			loadingView!.center = point
			
			self.titleLabel?.alpha = hideTitleWhileLoading ? 0.0 : 1.0
			self.imageView?.alpha = hideImageWhileLoading ? 0.0 : 1.0
		}
		
		if roundedButton {
			self.cornerRadius = viewSize.height / 2
			self.setNeedsDisplay()
		}
	}
	
	fileprivate func updateLayoutAlignment() {
		switch imageAlignment {
		case .left(let toEdge):
			frameLayout.layoutDirection = .horizontal
			frameLayout.leftFrameLayout.targetView = imageFrame
			frameLayout.rightFrameLayout.targetView = self.titleLabel
			
			frameLayout.leftFrameLayout.contentHorizontalAlignment = toEdge ? .left : .center
			frameLayout.leftFrameLayout.contentVerticalAlignment = .center
			frameLayout.rightFrameLayout.contentHorizontalAlignment = .left
			frameLayout.rightFrameLayout.contentVerticalAlignment = .center
			break
			
		case .right(let toEdge):
			frameLayout.layoutDirection = .horizontal
			frameLayout.leftFrameLayout.targetView = self.titleLabel
			frameLayout.rightFrameLayout.targetView = imageFrame
			
			frameLayout.leftFrameLayout.contentHorizontalAlignment = .right
			frameLayout.leftFrameLayout.contentVerticalAlignment = .center
			frameLayout.rightFrameLayout.contentHorizontalAlignment = toEdge ? .center : .left
			frameLayout.rightFrameLayout.contentVerticalAlignment = .center
			break
			
		case .top(let toEdge):
			frameLayout.layoutDirection = .vertical
			frameLayout.topFrameLayout.targetView = imageFrame
			frameLayout.bottomFrameLayout.targetView = self.titleLabel
			
			frameLayout.topFrameLayout.contentVerticalAlignment = toEdge ? .top : .center
			frameLayout.topFrameLayout.contentHorizontalAlignment = .center
			frameLayout.bottomFrameLayout.contentHorizontalAlignment = .center
			frameLayout.bottomFrameLayout.contentVerticalAlignment = .top
			break
			
		case .bottom(let toEdge):
			frameLayout.layoutDirection = .vertical
			frameLayout.topFrameLayout.targetView = self.titleLabel
			frameLayout.bottomFrameLayout.targetView = imageFrame
			
			frameLayout.topFrameLayout.contentHorizontalAlignment = .center
			frameLayout.topFrameLayout.contentVerticalAlignment = .bottom
			frameLayout.bottomFrameLayout.contentHorizontalAlignment = .center
			frameLayout.bottomFrameLayout.contentVerticalAlignment = toEdge ? .bottom : .center
			break
		}
		
		self.setNeedsDisplay()
		self.setNeedsLayout()
	}
	
	// MARK: -
	
	override open var frame: CGRect {
		didSet {
			if __CGSizeEqualToSize(super.frame.size, oldValue.size) {
				self.setNeedsDisplay()
				self.setNeedsLayout()
			}
		}
	}
	
	override open var bounds: CGRect {
		didSet {
			if __CGSizeEqualToSize(super.bounds.size, oldValue.size) {
				self.setNeedsDisplay()
				self.setNeedsLayout()
			}
		}
	}
	
	override open var isHighlighted: Bool {
		didSet {
			if super.isHighlighted != oldValue {
				self.setNeedsDisplay()
			}
		}
	}
	
	
	// MARK: -
	
	public func setBackgroundColor(_ color: UIColor?, for state: UIControlState) {
		let key = backgroundColorKey(for: state)
		bgColorDict[key] = color
	}
	
	public func setBorderColor(_ color: UIColor?, for state: UIControlState) {
		let key = borderColorKey(for: state)
		borderColorDict[key] = color
	}
	
	public func setShadowColor(_ color: UIColor?, for state: UIControlState) {
		let key = shadowColorKey(for: state)
		shadowColorDict[key] = color
	}
	
	public func backgroundColor(for state: UIControlState) -> UIColor? {
		let key = backgroundColorKey(for: state)
		var result = bgColorDict[key]
		
		if result == nil {
			if state == .disabled && autoSetDisableColor {
				let normalColor = self.backgroundColor(for: .normal)
				result = normalColor != nil ? normalColor!.withAlphaComponent(0.3) : nil
			}
			else if state == .highlighted && autoSetHighlightedColor {
//				let normalColor = self.backgroundColor(for: .normal)
//				result = normalColor != nil ? normalColor!.darkening(to: 0.5) : nil
			}
		}
		
		return result
	}
	
	public func borderColor(for state: UIControlState) -> UIColor? {
		let key = borderColorKey(for: state)
		var result = borderColorDict[key]
		
		if result == nil {
			if state == .disabled && autoSetDisableColor {
				let normalColor = self.borderColor(for: .normal)
				result = normalColor != nil ? normalColor!.withAlphaComponent(0.3) : nil
			}
			else if state == .highlighted && autoSetHighlightedColor {
//				let normalColor = self.borderColor(for: .normal)
//				result = normalColor != nil ? normalColor!.darkening(to: 0.5) : nil
			}
		}
		
		return result
	}
	
	public func shadowColor(for state: UIControlState) -> UIColor? {
		let key = shadowColorKey(for: state)
		return shadowColorDict[key]
	}
	
	// MARK: -
	
	fileprivate func backgroundColorKey(for state: UIControlState) -> String {
		return "bg\(state.rawValue)"
	}
	
	fileprivate func borderColorKey(for state: UIControlState) -> String {
		return "br\(state.rawValue)"
	}
	
	fileprivate func shadowColorKey(for state: UIControlState) -> String {
		return "sd\(state.rawValue)"
	}
	
	// MARK: -
	
	fileprivate func showLoadingView() {
		if loadingView == nil {
			let viewSize = self.bounds.size
			let minSize = min(viewSize.width, viewSize.height) * loadingIndicatorScaleRatio
			let indicatorSize = CGSize(width: minSize, height: minSize)
			let loadingFrame = CGRect(x: 0, y: 0, width: indicatorSize.width, height: indicatorSize.height)
			let color = loadingIndicatorColor ?? self.titleColor(for: .normal)
			loadingView = NVActivityIndicatorView(frame: loadingFrame, type: loadingIndicatorStyle, color: color, padding: 0)
			loadingView!.startAnimating()
			self.addSubview(loadingView!)
			self.setNeedsLayout()
		}
	}
	
	fileprivate func hideLoadingView() {
		loadingView?.stopAnimating()
		loadingView?.removeFromSuperview()
		loadingView = nil
	}
	
	fileprivate func transition(toCircle: Bool) {
		backgroundLayer.removeAllAnimations()
		shadowLayer.removeAllAnimations()
		
		let animation = CABasicAnimation(keyPath: "bounds.size.width")
		
		if toCircle {
			animation.fromValue = frame.width
			animation.toValue = frame.height
			animation.duration = 0.1
			animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
			backgroundLayer.masksToBounds = true
			backgroundLayer.cornerRadius = cornerRadius
		}
		else {
			animation.fromValue = frame.height
			animation.toValue = frame.width
			animation.duration = 0.15
			animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
			
			self.setNeedsLayout()
			self.setNeedsDisplay()
		}
		
		animation.fillMode = kCAFillModeForwards
		animation.isRemovedOnCompletion = false
		backgroundLayer.add(animation, forKey: animation.keyPath)
		shadowLayer.add(animation, forKey: animation.keyPath)
	}
	
	public func expandFullscreen(duration:Double = 0.3, completionBlock:NKButtonAnimationCompletionBlock? = nil) {
		self.animationationDidEnd = completionBlock
		hideLoadingView()
		
		if self.window != nil {
			let targetFrame = self.convert(self.bounds, to: self.window!)
			self.window!.addSubview(self)
			self.frame = targetFrame
		}
		
		self.isEnabled = true // back to normal color
		self.isUserInteractionEnabled = false
		self.titleLabel?.alpha = 0.0
		self.imageView?.alpha = 0.0
		
		let animation = CABasicAnimation(keyPath: "transform.scale")
		animation.fromValue = 1.0
		animation.toValue = 26.0
		animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		animation.duration = duration
		animation.delegate = self
		animation.fillMode = kCAFillModeForwards
		animation.isRemovedOnCompletion = false
		
		backgroundLayer.add(animation, forKey: animation.keyPath)
	}
	
	fileprivate func disableUnderlineLabel() {
		let attributedText: NSMutableAttributedString? = titleLabel?.attributedText?.mutableCopy() as? NSMutableAttributedString
		if attributedText != nil {
			attributedText!.addAttribute(NSAttributedStringKey.underlineStyle, value: (0), range: NSRange(location: 0, length: attributedText!.length))
			titleLabel?.attributedText = attributedText
		}
	}
	
	public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		if flag {
			animationationDidEnd?(self)
		}
	}
	
	deinit {
		backgroundLayer.removeAllAnimations()
		shadowLayer.removeAllAnimations()
	}
	
}
