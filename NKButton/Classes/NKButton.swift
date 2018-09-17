//
//  NKButton.swift
//  NKButton
//
//  Created by Nam Kennic on 8/18/17.
//  Copyright © 2017 Nam Kennic. All rights reserved.
//

import UIKit
import FrameLayoutKit
import NVActivityIndicatorView

public typealias NKButtonAnimationCompletionBlock = ((_ sender: NKButton) -> Void)

public enum NKButtonLoadingIndicatorAlignment : String {
	case left
	case center
	case right
	case atImage
}

public enum NKButtonImageAlignment {
	case left
	case right
	case top
	case bottom
}

open class NKButton: UIButton {
	
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
	
	/** Corner Radius, will be ignored if `isRoundedButton` is true */
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
	public var isRoundedButton : Bool = false {
		didSet {
			if isRoundedButton != oldValue {
				self.setNeedsLayout()
			}
		}
	}
	
	/** If `true`, title label will not be underlined when `Settings > Accessibility > Button Shapes` is ON */
	public var underlineTitleDisabled : Bool = false {
		didSet {
			if underlineTitleDisabled != oldValue {
				self.setNeedsDisplay()
			}
		}
	}
	
	/** Image alignment */
	public var imageAlignment : NKButtonImageAlignment = .left {
		didSet {
			updateLayoutAlignment()
		}
	}
	
	/** Text Horizontal Alignment */
	public var textHorizontalAlignment: NKContentHorizontalAlignment {
		get {
			return self.labelFrame.contentHorizontalAlignment
		}
		set {
			self.labelFrame.contentHorizontalAlignment = newValue
		}
	}
	
	/** Text Vertical Alignment */
	public var textVerticalAlignment: NKContentVerticalAlignment {
		get {
			return self.labelFrame.contentVerticalAlignment
		}
		set {
			self.labelFrame.contentVerticalAlignment = newValue
		}
	}
	
	/** Text Alignment */
	public var textAlignemnt: (NKContentVerticalAlignment, NKContentHorizontalAlignment) {
		get {
			return self.labelFrame.contentAlignment
		}
		set {
			self.labelFrame.contentAlignment = newValue
		}
	}
	
	/** If `true`, disabled color will be set from normal color with tranparency */
	public var autoSetDisableColor : Bool = true
	/** If `true`, highlighted color will be set from normal color with tranparency */
	public var autoSetHighlightedColor : Bool = true
	
	public var flashColor: UIColor! = UIColor(white: 1.0, alpha: 0.5) {
		didSet {
			flashLayer.fillColor = flashColor.cgColor
		}
	}
	
	/** Set loading state. Tap interaction will be disabled while loading */
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
	/** Style of loading indicator */
	public var loadingIndicatorStyle : NVActivityIndicatorType = .ballPulse
	/** Scale ratio of loading indicator, based on the minimum value of button width or height */
	public var loadingIndicatorScaleRatio : CGFloat = 0.7
	/** Color of loading indicator, if `nil`, it will use titleColor of normal state */
	public var loadingIndicatorColor : UIColor? = nil
	/** Alignment for loading indicator */
	public var loadingIndicatorAlignment : NKButtonLoadingIndicatorAlignment = .center
	/** `FrameLayout` that layout imageView */
	public var imageFrameLayout: FrameLayout! {
		get {
			return imageFrame
		}
	}
	/** `FrameLayout` that layout textLabel */
	public var labelFrameLayout: FrameLayout! {
		get {
			return labelFrame
		}
	}
	/** DoubleFrameLayout that layout the content */
	public var contentFrameLayout: DoubleFrameLayout! {
		get {
			return frameLayout
		}
	}
	
	/** The background view of the button */
	public var backgroundView: UIView? = nil {
		didSet {
			oldValue?.layer.removeFromSuperlayer()
			
			if let view = backgroundView {
				view.isUserInteractionEnabled = false
				view.layer.masksToBounds = true
				self.layer.insertSublayer(view.layer, at: 0)
				self.setNeedsLayout()
			}
		}
	}
	
	public var animationationDidEnd : NKButtonAnimationCompletionBlock? = nil
	
	fileprivate var loadingView 	: NVActivityIndicatorView? = nil
	fileprivate let shadowLayer 	= CAShapeLayer()
	fileprivate let backgroundLayer = CAShapeLayer()
	fileprivate let flashLayer 		= CAShapeLayer()
	fileprivate let gradientLayer	= CAGradientLayer()
	fileprivate let imageFrame 		= FrameLayout()
	fileprivate let labelFrame 		= FrameLayout()
	fileprivate let frameLayout 	= DoubleFrameLayout(direction: .horizontal)
	
	fileprivate var bgColorDict			: [String : UIColor] = [:]
	fileprivate var borderColorDict		: [String : UIColor] = [:]
	fileprivate var shadowColorDict		: [String : UIColor] = [:]
	fileprivate var gradientColorDict	: [String : [UIColor]] = [:]
	
	// MARK: -
	
	public convenience init(title: String, titleColor: UIColor? = nil, buttonColor: UIColor? = nil, shadowColor: UIColor? = nil) {
		self.init()
		self.title = title
		
		if let color = titleColor {
			self.setTitleColor(color, for: .normal)
		}
		
		if let color = buttonColor {
			self.setBackgroundColor(color, for: .normal)
		}
		
		if let color = shadowColor {
			self.setShadowColor(color, for: .normal)
		}
	}
	
	public init() {
		super.init(frame: .zero)
		
		flashLayer.opacity = 0
		flashLayer.fillColor = self.flashColor.cgColor
		
		self.layer.addSublayer(shadowLayer)
		self.layer.addSublayer(backgroundLayer)
		self.layer.addSublayer(flashLayer)
		self.layer.addSublayer(gradientLayer)
		
		frameLayout.layoutAlignment = .center
		frameLayout.isIntrinsicSizeEnabled = true
		frameLayout.frameLayout1.contentAlignment = (.center, .center)
		frameLayout.frameLayout2.contentAlignment = (.center, .center)
		
		imageFrame.contentAlignment = (.center, .center)
		imageFrame.targetView = self.imageView
		
		labelFrame.contentAlignment = (.fill, .fill)
		labelFrame.targetView = self.titleLabel
		
		updateLayoutAlignment()
		
		self.addSubview(imageFrame)
		self.addSubview(labelFrame)
		self.addSubview(frameLayout)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override open func sizeThatFits(_ size: CGSize) -> CGSize {
		var result = frameLayout.sizeThatFits(size)
		
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
		
		let fillColor 		= self.backgroundColor(for: state)
		let borderColor 	= self.borderColor(for: state)
		let roundedPath 	= UIBezierPath(roundedRect: backgroundFrame, cornerRadius: cornerRadius)
		let path			= transitionToCircleWhenLoading && isLoading ? backgroundLayer.path : roundedPath.cgPath
		
		backgroundLayer.path			= path
		backgroundLayer.fillColor		= fillColor?.cgColor
		backgroundLayer.strokeColor		= borderColor?.cgColor
		backgroundLayer.lineWidth		= borderSize
		backgroundLayer.miterLimit		= roundedPath.miterLimit
		
		flashLayer.path 				= path
		flashLayer.fillColor 			= flashColor.cgColor
		
		if let shadowColor = self.shadowColor(for: state) {
			shadowLayer.isHidden 		= false
			shadowLayer.path 			= path
			shadowLayer.shadowPath 		= path
			shadowLayer.fillColor 		= shadowColor.cgColor
			shadowLayer.shadowColor 	= shadowColor.cgColor
			shadowLayer.shadowRadius 	= shadowRadius
			shadowLayer.shadowOpacity 	= shadowOpacity
			shadowLayer.shadowOffset 	= shadowOffset
		}
		else {
			shadowLayer.isHidden = true
		}
		
		if let gradientColors = self.gradientColor(for: state) {
			var colors: [CGColor] = []
			for color in gradientColors {
				colors.append(color.cgColor)
			}
			
			gradientLayer.isHidden = false
			gradientLayer.shadowPath = path
			gradientLayer.colors = colors
		}
		else {
			gradientLayer.isHidden = true
			gradientLayer.colors = nil
		}
		
		if underlineTitleDisabled {
			self.disableUnderlineLabel()
		}
	}
	
	override open func layoutSubviews() {
		super.layoutSubviews()
		
		let viewSize = self.bounds.size
		let bounds = self.bounds
		shadowLayer.frame = bounds
		backgroundLayer.frame = bounds
		flashLayer.frame = bounds
		gradientLayer.frame = bounds
		frameLayout.frame = bounds
		
		if self.imageView != nil {
			self.bringSubview(toFront: self.imageView!)
		}
		
		if loadingView != nil {
			var point = CGPoint(x: 0, y: viewSize.height / 2)
			switch (loadingIndicatorAlignment) {
			case .left: 	point.x = loadingView!.frame.size.width/2 + 5 + contentFrameLayout.edgeInsets.left
			case .center: 	point.x = viewSize.width/2
			case .right: 	point.x = viewSize.width - (loadingView!.frame.size.width/2) - 5 -  contentFrameLayout.edgeInsets.right
			case .atImage:	point = self.imageView?.center ?? point
			}
			
			loadingView!.center = point
			
			self.titleLabel?.alpha = hideTitleWhileLoading ? 0.0 : 1.0
			self.imageView?.alpha = hideImageWhileLoading ? 0.0 : 1.0
		}
		
		if isRoundedButton {
			self.cornerRadius = viewSize.height / 2
			self.setNeedsDisplay()
		}
		
		gradientLayer.cornerRadius = cornerRadius
		gradientLayer.masksToBounds = cornerRadius > 0
		
		backgroundView?.layer.cornerRadius = cornerRadius
		backgroundView?.frame = bounds
	}
	
	fileprivate func updateLayoutAlignment() {
		switch imageAlignment {
		case .left:
			frameLayout.layoutDirection = .horizontal
			
			frameLayout.leftFrameLayout.targetView = imageFrame
			frameLayout.rightFrameLayout.targetView = labelFrame
			break
			
		case .right:
			frameLayout.layoutDirection = .horizontal
			
			frameLayout.leftFrameLayout.targetView = labelFrame
			frameLayout.rightFrameLayout.targetView = imageFrame
			break
			
		case .top:
			frameLayout.layoutDirection = .vertical
			
			frameLayout.topFrameLayout.targetView = imageFrame
			frameLayout.bottomFrameLayout.targetView = labelFrame
			break
			
		case .bottom:
			frameLayout.layoutDirection = .vertical
			
			frameLayout.topFrameLayout.targetView = labelFrame
			frameLayout.bottomFrameLayout.targetView = imageFrame
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
				
//				if isHighlighted {
//					if #available(iOS 10, *) {
//						let generator = UIImpactFeedbackGenerator(style: .light)
//						generator.prepare()
//						generator.impactOccurred()
//					}
//				}
			}
		}
	}
	
	
	// MARK: -
	
	public func startFlashing(flashDuration: TimeInterval = 0.5, intensity: Float = 0.65, repeatCount: Int = 10) {
		let flash = CABasicAnimation(keyPath: "opacity")
		flash.fromValue = 0.0
		flash.toValue = intensity
		flash.duration = flashDuration
		flash.autoreverses = true
		flash.repeatCount = Float(repeatCount)
		flashLayer.add(flash, forKey: "flashAnimation")
	}
	
	public func stopFlashing() {
		flashLayer.removeAnimation(forKey: "flashAnimation")
	}
	
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
	
	public func setGradientColor(_ colors: [UIColor]?, for state: UIControlState) {
		let key = gradientColorKey(for: state)
		gradientColorDict[key] = colors
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
				let normalColor = self.backgroundColor(for: .normal)
				result = normalColor != nil ? normalColor!.darker(by: 0.5) : nil
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
				let normalColor = self.borderColor(for: .normal)
				result = normalColor != nil ? normalColor!.darker(by: 0.5) : nil
			}
		}
		
		return result
	}
	
	public func shadowColor(for state: UIControlState) -> UIColor? {
		let key = shadowColorKey(for: state)
		return shadowColorDict[key]
	}
	
	public func gradientColor(for state: UIControlState) -> [UIColor]? {
		let key = gradientColorKey(for: state)
		return gradientColorDict[key]
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
	
	fileprivate func gradientColorKey(for state: UIControlState) -> String {
		return "gr\(state.rawValue)"
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
		gradientLayer.add(animation, forKey: animation.keyPath)
		flashLayer.add(animation, forKey: animation.keyPath)
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
	
	deinit {
		backgroundLayer.removeAllAnimations()
		shadowLayer.removeAllAnimations()
		gradientLayer.removeAllAnimations()
		flashLayer.removeAllAnimations()
	}
	
}

extension NKButton: CAAnimationDelegate {
	
	public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		if flag {
			animationationDidEnd?(self)
		}
	}
	
}

// MARK: -

fileprivate extension UIColor {
	
	func lighter(by value:CGFloat = 0.5) -> UIColor? {
		return self.adjust(by: abs(value) )
	}
	
	func darker(by value:CGFloat = 0.5) -> UIColor? {
		return self.adjust(by: -1 * abs(value) )
	}
	
	func adjust(by value:CGFloat = 0.5) -> UIColor? {
		var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
		
		if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
			return UIColor(red: min(r + value, 1.0),
						   green: min(g + value, 1.0),
						   blue: min(b + value, 1.0),
						   alpha: a)
		}
		else {
			return nil
		}
	}
	
}
