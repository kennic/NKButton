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

public enum NKButtonLoadingIndicatorAlignment: String {
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
	case leftEdge
	case rightEdge
	case topEdge
	case bottomEdge
}

open class NKButton: UIButton {
	
	/** Set/Get title of the button */
	open var title: String? {
		get {
			return currentTitle
		}
		set {
			setTitle(newValue, for: .normal)
			setNeedsLayout()
		}
	}
	
	/** Space between image and text */
	open var spacing: CGFloat {
		get {
			return frameLayout.spacing
		}
		set {
			frameLayout.spacing = newValue
			frameLayout.setNeedsLayout()
			setNeedsLayout()
		}
	}
	
	/** Minimum size of imageView, set zero to width or height to disable */
	open var imageMinSize: CGSize {
		get {
			return imageFrame.minSize
		}
		set {
			imageFrame.minSize = newValue
			frameLayout.setNeedsLayout()
			setNeedsLayout()
		}
	}
	
	/** Maximum size of imageView, set zero to width or height to disable */
	open var imageMaxSize: CGSize {
		get {
			return imageFrame.maxSize
		}
		set {
			imageFrame.maxSize = newValue
			frameLayout.setNeedsLayout()
			setNeedsLayout()
		}
	}
	
	/** Fixed size of imageView, set zero to width or height to disable */
	open var imageFixSize: CGSize {
		get {
			return imageFrame.fixSize
		}
		set {
			imageFrame.fixSize = newValue
			frameLayout.setNeedsLayout()
			setNeedsLayout()
		}
	}
	
	/** Extend size that will be included in sizeThatFits function */
	open var extendSize: CGSize = .zero
	
	/** Corner Radius, will be ignored if `isRoundedButton` is true */
	open var cornerRadius: CGFloat = 0 {
		didSet {
			if cornerRadius != oldValue {
				setNeedsDisplay()
			}
		}
	}
	
	/** Shadow radius */
	open var shadowRadius: CGFloat = 0 {
		didSet {
			if shadowRadius != oldValue {
				setNeedsDisplay()
			}
		}
	}
	
	/** Shadow opacity */
	open var shadowOpacity: Float = 0.5 {
		didSet {
			if shadowOpacity != oldValue {
				setNeedsDisplay()
			}
		}
	}
	
	/** Shadow offset */
	open var shadowOffset: CGSize = .zero {
		didSet {
			if shadowOffset != oldValue {
				setNeedsDisplay()
			}
		}
	}
	
	/** Size of border */
	open var borderSize: CGFloat {
		get {
			return borderSize(for: .normal)
		}
		set {
			setBorderSize(newValue, for: .normal)
		}
	}
	
	/** Rounds both sides of the button */
	open var isRoundedButton: Bool = false {
		didSet {
			if isRoundedButton != oldValue {
				setNeedsLayout()
			}
		}
	}
	
	/** If `true`, title label will not be underlined when `Settings > Accessibility > Button Shapes` is ON */
	open var underlineTitleDisabled: Bool = false {
		didSet {
			if underlineTitleDisabled != oldValue {
				setNeedsDisplay()
			}
		}
	}
	
	/** Image alignment */
	open var imageAlignment: NKButtonImageAlignment = .left {
		didSet {
			updateLayoutAlignment()
		}
	}
	
	/** Text Horizontal Alignment */
	open var textHorizontalAlignment: NKContentHorizontalAlignment {
		get {
			return labelFrame.contentHorizontalAlignment
		}
		set {
			labelFrame.contentHorizontalAlignment = newValue
			setNeedsLayout()
		}
	}
	
	/** Text Vertical Alignment */
	open var textVerticalAlignment: NKContentVerticalAlignment {
		get {
			return labelFrame.contentVerticalAlignment
		}
		set {
			labelFrame.contentVerticalAlignment = newValue
			setNeedsLayout()
		}
	}
	
	/** Text Alignment */
	open var textAlignemnt: (NKContentVerticalAlignment, NKContentHorizontalAlignment) {
		get {
			return labelFrame.contentAlignment
		}
		set {
			labelFrame.contentAlignment = newValue
			setNeedsLayout()
		}
	}
	
	override open var contentEdgeInsets: UIEdgeInsets {
		get {
			return frameLayout.edgeInsets
		}
		set {
			frameLayout.edgeInsets = newValue
			setNeedsLayout()
		}
	}
	
	/** If `true`, disabled color will be set from normal color with tranparency */
	open var autoSetDisableColor: Bool = true
	/** If `true`, highlighted color will be set from normal color with tranparency */
	open var autoSetHighlightedColor: Bool = true
	
	open var flashColor: UIColor! = UIColor(white: 1.0, alpha: 0.5) {
		didSet {
			flashLayer.fillColor = flashColor.cgColor
		}
	}
	
	/** Set loading state. Tap interaction will be disabled while loading */
	open var isLoading: Bool = false {
		didSet {
			if isLoading != oldValue {
				if isLoading {
					isEnabled = false
					showLoadingView()
					
					if transitionToCircleWhenLoading {
						titleLabel?.alpha = 0.0
						imageView?.alpha = 0.0
						transition(toCircle: true)
					}
					else {
						if hideImageWhileLoading {
							imageView?.alpha = 0.0
						}
						
						if hideTitleWhileLoading {
							titleLabel?.alpha = 0.0
						}
					}
				}
				else {
					isEnabled = true
					hideLoadingView()
					
					if transitionToCircleWhenLoading {
						titleLabel?.alpha = 1.0
						imageView?.alpha = 1.0
						transition(toCircle: false)
					}
					else {
						if hideImageWhileLoading {
							imageView?.alpha = 1.0
						}
						
						if hideTitleWhileLoading {
							titleLabel?.alpha = 1.0
						}
					}
				}
			}
		}
	}
	/** imageView will be hidden when `isLoading` is true */
	open var hideImageWhileLoading: Bool = false
	/** titleLabel will be hidden when `isLoading` is true */
	open var hideTitleWhileLoading: Bool = true
	/** Button will animated to circle shape when set `isLoading = true`*/
	open var transitionToCircleWhenLoading: Bool = false
	/** Style of loading indicator */
	open var loadingIndicatorStyle: NVActivityIndicatorType = .ballPulse
	/** Scale ratio of loading indicator, based on the minimum value of button width or height */
	open var loadingIndicatorScaleRatio: CGFloat = 0.7
	/** Color of loading indicator, if `nil`, it will use titleColor of normal state */
	open var loadingIndicatorColor: UIColor? = nil
	/** Alignment for loading indicator */
	open var loadingIndicatorAlignment: NKButtonLoadingIndicatorAlignment = .center
	/** `FrameLayout` that layout imageView */
	open var imageFrameLayout: FrameLayout! {
		get {
			return imageFrame
		}
	}
	/** `FrameLayout` that layout textLabel */
	open var labelFrameLayout: FrameLayout! {
		get {
			return labelFrame
		}
	}
	/** DoubleFrameLayout that layout the content */
	open var contentFrameLayout: DoubleFrameLayout! {
		get {
			return frameLayout
		}
	}
	
	/** The background view of the button */
	open var backgroundView: UIView? = nil {
		didSet {
			oldValue?.layer.removeFromSuperlayer()
			
			if let view = backgroundView {
				view.isUserInteractionEnabled = false
				view.layer.masksToBounds = true
				layer.insertSublayer(view.layer, at: 0)
				setNeedsLayout()
			}
		}
	}
	
	open var animationationDidEnd: NKButtonAnimationCompletionBlock? = nil
	
	fileprivate var loadingView 	: NVActivityIndicatorView? = nil
	fileprivate let shadowLayer 	= CAShapeLayer()
	fileprivate let backgroundLayer = CAShapeLayer()
	fileprivate let flashLayer 		= CAShapeLayer()
	fileprivate let gradientLayer	= CAGradientLayer()
	fileprivate let imageFrame 		= FrameLayout()
	fileprivate let labelFrame 		= FrameLayout()
	fileprivate let frameLayout 	= DoubleFrameLayout(axis: .horizontal)
	
	fileprivate var bgColorDict			: [String : UIColor] = [:]
	fileprivate var borderColorDict		: [String : UIColor] = [:]
	fileprivate var shadowColorDict		: [String : UIColor] = [:]
	fileprivate var gradientColorDict	: [String : [UIColor]] = [:]
	fileprivate var borderSizeDict		: [String : CGFloat] = [:]
	
	// MARK: -
	
	public convenience init(title: String, titleColor: UIColor? = nil, buttonColor: UIColor? = nil, shadowColor: UIColor? = nil) {
		self.init()
		self.title = title
		
		if let color = titleColor {
			setTitleColor(color, for: .normal)
		}
		
		if let color = buttonColor {
			setBackgroundColor(color, for: .normal)
		}
		
		if let color = shadowColor {
			setShadowColor(color, for: .normal)
		}
	}
	
	public init() {
		super.init(frame: .zero)
		
		flashLayer.opacity = 0
		flashLayer.fillColor = flashColor.cgColor
		contentEdgeInsets = .zero
		
		layer.addSublayer(shadowLayer)
		layer.addSublayer(backgroundLayer)
		layer.addSublayer(flashLayer)
		layer.addSublayer(gradientLayer)
		
		frameLayout.isIntrinsicSizeEnabled = true
		frameLayout.frameLayout1.contentAlignment = (.center, .center)
		frameLayout.frameLayout2.contentAlignment = (.center, .center)
		
		imageFrame.contentAlignment = (.center, .center)
		imageFrame.targetView = imageView
		
		labelFrame.contentAlignment = (.fill, .fill)
		labelFrame.targetView = titleLabel
		
		updateLayoutAlignment()
		
		addSubview(imageFrame)
		addSubview(labelFrame)
		addSubview(frameLayout)
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
		let size = sizeThatFits(UIScreen.main.bounds.size)
		frame = CGRect(origin: frame.origin, size: size)
	}
	
	override open func draw(_ rect: CGRect) {
		super.draw(rect)
		
		let backgroundFrame = bounds
		let fillColor 		= backgroundColor(for: state)
		let strokeColor 	= borderColor(for: state)
		let strokeSize		= borderSize(for: state)
		let roundedPath 	= UIBezierPath(roundedRect: backgroundFrame, cornerRadius: cornerRadius)
		let path			= transitionToCircleWhenLoading && isLoading ? backgroundLayer.path : roundedPath.cgPath
		
		backgroundLayer.path			= path
		backgroundLayer.fillColor		= fillColor?.cgColor
		backgroundLayer.strokeColor		= strokeColor?.cgColor
		backgroundLayer.lineWidth		= strokeSize
		backgroundLayer.miterLimit		= roundedPath.miterLimit
		
		flashLayer.path 				= path
		flashLayer.fillColor 			= flashColor.cgColor
		
		if let shadowColor = shadowColor(for: state) {
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
		
		if let gradientColors = gradientColor(for: state) {
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
			removeLabelUnderline()
		}
	}
	
	override open func layoutSubviews() {
		super.layoutSubviews()
		
		let bounds = self.bounds
		let viewSize = bounds.size
		
		shadowLayer.frame = bounds
		backgroundLayer.frame = bounds
		flashLayer.frame = bounds
		gradientLayer.frame = bounds
		frameLayout.frame = bounds
		
		frameLayout.setNeedsLayout()
		frameLayout.layoutIfNeeded()
		
		if let imageView = imageView {
			#if swift(>=4.2)
			bringSubviewToFront(imageView)
			#else
			bringSubview(toFront: imageView)
			#endif
		}
		
		if let loadingView = loadingView {
			var point = CGPoint(x: 0, y: viewSize.height / 2)
			switch (loadingIndicatorAlignment) {
			case .left: 	point.x = loadingView.frame.size.width/2 + 5 + contentFrameLayout.edgeInsets.left
			case .center: 	point.x = viewSize.width/2
			case .right: 	point.x = viewSize.width - (loadingView.frame.size.width/2) - 5 -  contentFrameLayout.edgeInsets.right
			case .atImage:	point = imageView?.center ?? point
			}
			
			loadingView.center = point
			
			titleLabel?.alpha = hideTitleWhileLoading ? 0.0 : 1.0
			imageView?.alpha = hideImageWhileLoading ? 0.0 : 1.0
		}
		
		if isRoundedButton {
			cornerRadius = viewSize.height / 2
			setNeedsDisplay()
		}
		
		gradientLayer.cornerRadius = cornerRadius
		gradientLayer.masksToBounds = cornerRadius > 0
		
		backgroundView?.layer.cornerRadius = cornerRadius
		backgroundView?.frame = bounds
	}
	
	fileprivate func updateLayoutAlignment() {
		switch imageAlignment {
		case .left:
			frameLayout.axis = .horizontal
			frameLayout.distribution = .center
			
			frameLayout.leftFrameLayout.targetView = imageFrame
			frameLayout.rightFrameLayout.targetView = labelFrame
			break
			
		case .leftEdge:
			frameLayout.axis = .horizontal
			frameLayout.distribution = .left
			
			frameLayout.leftFrameLayout.targetView = imageFrame
			frameLayout.rightFrameLayout.targetView = labelFrame
			break
			
		case .right:
			frameLayout.axis = .horizontal
			frameLayout.distribution = .center
			
			frameLayout.leftFrameLayout.targetView = labelFrame
			frameLayout.rightFrameLayout.targetView = imageFrame
			break
			
		case .rightEdge:
			frameLayout.axis = .horizontal
			frameLayout.distribution = .right
			
			frameLayout.leftFrameLayout.targetView = labelFrame
			frameLayout.rightFrameLayout.targetView = imageFrame
			break
			
		case .top:
			frameLayout.axis = .vertical
			frameLayout.distribution = .center
			
			frameLayout.topFrameLayout.targetView = imageFrame
			frameLayout.bottomFrameLayout.targetView = labelFrame
			break
			
		case .topEdge:
			frameLayout.axis = .vertical
			frameLayout.distribution = .top
			
			frameLayout.topFrameLayout.targetView = imageFrame
			frameLayout.bottomFrameLayout.targetView = labelFrame
			break
			
		case .bottom:
			frameLayout.axis = .vertical
			frameLayout.distribution = .center
			
			frameLayout.topFrameLayout.targetView = labelFrame
			frameLayout.bottomFrameLayout.targetView = imageFrame
			break
			
		case .bottomEdge:
			frameLayout.axis = .vertical
			frameLayout.distribution = .bottom
			
			frameLayout.topFrameLayout.targetView = labelFrame
			frameLayout.bottomFrameLayout.targetView = imageFrame
			break
		}
		
		setNeedsDisplay()
		setNeedsLayout()
	}
	
	// MARK: -
	
	override open var frame: CGRect {
		didSet {
			setNeedsDisplay()
			setNeedsLayout()
		}
	}
	
	override open var bounds: CGRect {
		didSet {
			setNeedsDisplay()
			setNeedsLayout()
		}
	}
	
	override open var isHighlighted: Bool {
		didSet {
			if super.isHighlighted != oldValue {
				setNeedsDisplay()
				
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
	
	open func startFlashing(flashDuration: TimeInterval = 0.5, intensity: Float = 0.85, repeatCount: Int = 10) {
		let flash = CABasicAnimation(keyPath: "opacity")
		flash.fromValue = 0.0
		flash.toValue = intensity
		flash.duration = flashDuration
		flash.autoreverses = true
		flash.repeatCount = repeatCount < 0 ? .infinity : Float(repeatCount)
		flashLayer.add(flash, forKey: "flashAnimation")
	}
	
	open func stopFlashing() {
		flashLayer.removeAnimation(forKey: "flashAnimation")
	}
	
	open func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
		let key = backgroundColorKey(for: state)
		bgColorDict[key] = color
		setNeedsDisplay()
	}
	
	open func setBorderColor(_ color: UIColor?, for state: UIControl.State) {
		let key = borderColorKey(for: state)
		borderColorDict[key] = color
		setNeedsDisplay()
	}
	
	open func setShadowColor(_ color: UIColor?, for state: UIControl.State) {
		let key = shadowColorKey(for: state)
		shadowColorDict[key] = color
		setNeedsDisplay()
	}
	
	open func setGradientColor(_ colors: [UIColor]?, for state: UIControl.State) {
		let key = gradientColorKey(for: state)
		gradientColorDict[key] = colors
		setNeedsDisplay()
	}
	
	open func setBorderSize(_ value: CGFloat?, for state: UIControl.State) {
		let key = borderSizeKey(for: state)
		borderSizeDict[key] = value
		setNeedsDisplay()
	}
	
	open func backgroundColor(for state: UIControl.State) -> UIColor? {
		let key = backgroundColorKey(for: state)
		var result = bgColorDict[key]
		
		if result == nil {
			if state == .disabled && autoSetDisableColor {
				let normalColor = backgroundColor(for: .normal)
				result = normalColor != nil ? normalColor!.withAlphaComponent(0.3) : nil
			}
			else if state == .highlighted && autoSetHighlightedColor {
				let normalColor = backgroundColor(for: .normal)
				result = normalColor != nil ? normalColor!.darker(by: 0.5) : nil
			}
		}
		
		return result
	}
	
	open func borderColor(for state: UIControl.State) -> UIColor? {
		let key = borderColorKey(for: state)
		var result = borderColorDict[key]
		
		if result == nil {
			if state == .disabled && autoSetDisableColor {
				let normalColor = borderColor(for: .normal)
				result = normalColor != nil ? normalColor!.withAlphaComponent(0.3) : nil
			}
			else if state == .highlighted && autoSetHighlightedColor {
				let normalColor = borderColor(for: .normal)
				result = normalColor != nil ? normalColor!.darker(by: 0.5) : nil
			}
		}
		
		return result
	}
	
	open func shadowColor(for state: UIControl.State) -> UIColor? {
		let key = shadowColorKey(for: state)
		return shadowColorDict[key]
	}
	
	open func gradientColor(for state: UIControl.State) -> [UIColor]? {
		let key = gradientColorKey(for: state)
		return gradientColorDict[key]
	}
	
	open func borderSize(for state: UIControl.State) -> CGFloat {
		let key = borderSizeKey(for: state)
		return borderSizeDict[key] ?? 0
	}
	
	// MARK: -
	
	fileprivate func backgroundColorKey(for state: UIControl.State) -> String {
		return "bg\(state.rawValue)"
	}
	
	fileprivate func borderColorKey(for state: UIControl.State) -> String {
		return "br\(state.rawValue)"
	}
	
	fileprivate func shadowColorKey(for state: UIControl.State) -> String {
		return "sd\(state.rawValue)"
	}
	
	fileprivate func gradientColorKey(for state: UIControl.State) -> String {
		return "gr\(state.rawValue)"
	}
	
	fileprivate func borderSizeKey(for state: UIControl.State) -> String {
		return "bs\(state.rawValue)"
	}
	
	// MARK: -
	
	fileprivate func showLoadingView() {
		if loadingView == nil {
			let viewSize = bounds.size
			let minSize = min(viewSize.width, viewSize.height) * loadingIndicatorScaleRatio
			let indicatorSize = CGSize(width: minSize, height: minSize)
			let loadingFrame = CGRect(x: 0, y: 0, width: indicatorSize.width, height: indicatorSize.height)
			let color = loadingIndicatorColor ?? titleColor(for: .normal)
			
			loadingView = NVActivityIndicatorView(frame: loadingFrame, type: loadingIndicatorStyle, color: color, padding: 0)
			loadingView!.startAnimating()
			addSubview(loadingView!)
			setNeedsLayout()
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
			#if swift(>=4.2)
			animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
			#else
			animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
			#endif
			backgroundLayer.masksToBounds = true
			backgroundLayer.cornerRadius = cornerRadius
		}
		else {
			animation.fromValue = frame.height
			animation.toValue = frame.width
			animation.duration = 0.15
			#if swift(>=4.2)
			animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
			#else
			animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
			#endif
			
			setNeedsLayout()
			setNeedsDisplay()
		}
		
		#if swift(>=4.2)
		animation.fillMode = CAMediaTimingFillMode.forwards
		#else
		animation.fillMode = kCAFillModeForwards
		#endif
		animation.isRemovedOnCompletion = false
		
		backgroundLayer.add(animation, forKey: animation.keyPath)
		shadowLayer.add(animation, forKey: animation.keyPath)
		gradientLayer.add(animation, forKey: animation.keyPath)
		flashLayer.add(animation, forKey: animation.keyPath)
	}
	
	open func expandFullscreen(duration:Double = 0.3, completionBlock:NKButtonAnimationCompletionBlock? = nil) {
		animationationDidEnd = completionBlock
		hideLoadingView()
		
		if window != nil {
			let targetFrame = convert(bounds, to: window!)
			window!.addSubview(self)
			frame = targetFrame
		}
		
		isEnabled = true // back to normal color
		isUserInteractionEnabled = false
		titleLabel?.alpha = 0.0
		imageView?.alpha = 0.0
		
		let animation = CABasicAnimation(keyPath: "transform.scale")
		animation.fromValue = 1.0
		animation.toValue = 26.0
		animation.duration = duration
		animation.delegate = self
		#if swift(>=4.2)
		animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
		animation.fillMode = CAMediaTimingFillMode.forwards
		#else
		animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
		animation.fillMode = kCAFillModeForwards
		#endif
		animation.isRemovedOnCompletion = false
		
		backgroundLayer.add(animation, forKey: animation.keyPath)
	}
	
	fileprivate func removeLabelUnderline() {
		let attributedText: NSMutableAttributedString? = titleLabel?.attributedText?.mutableCopy() as? NSMutableAttributedString
		if attributedText != nil {
			attributedText!.addAttribute(NSAttributedString.Key.underlineStyle, value: (0), range: NSRange(location: 0, length: attributedText!.length))
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
	
	open func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		if flag {
			animationationDidEnd?(self)
		}
	}
	
}

// MARK: -

fileprivate extension UIColor {
	
	func lighter(by value:CGFloat = 0.5) -> UIColor? {
		return adjust(by: abs(value) )
	}
	
	func darker(by value:CGFloat = 0.5) -> UIColor? {
		return adjust(by: -1 * abs(value) )
	}
	
	func adjust(by value:CGFloat = 0.5) -> UIColor? {
		var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
		
		if getRed(&r, green: &g, blue: &b, alpha: &a) {
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

/**
Supports:
let button = NKButton()
button.titles[[.normal, .highlighted]] = ""
*/
class UIControlStateValue<T> {
	private let getter: (UIControl.State) -> T?
	private let setter: (T?, UIControl.State) -> Void
	
	// The initializer is fileprivate here because all
	// extensions are in a single file. If it's split
	// in multiple files, this should be internal
	fileprivate init(getter: @escaping (UIControl.State) -> T?,
					 setter: @escaping (T?, UIControl.State) -> Void) {
		self.getter = getter
		self.setter = setter
	}
	
	subscript(state: UIControl.State) -> T? {
		get {
			return getter(state)
		}
		set {
			setter(newValue, state)
		}
	}
}

extension NKButton {
	
	var titles: UIControlStateValue<String> {
		return UIControlStateValue<String>.init(getter: self.title(for:), setter: self.setTitle(_:for:))
	}
	
	var titleColors: UIControlStateValue<UIColor> {
		return UIControlStateValue<UIColor>(getter: self.titleColor(for:), setter: self.setTitleColor(_:for:))
	}
	
	var backgroundColors: UIControlStateValue<UIColor> {
		return UIControlStateValue<UIColor>.init(getter: self.backgroundColor(for:), setter: self.setBackgroundColor(_:for:))
	}
	
	var  borderColors: UIControlStateValue<UIColor> {
		return UIControlStateValue<UIColor>(getter: self.borderColor(for:), setter: self.setBorderColor(_:for:))
	}
	
	var  shadowColors: UIControlStateValue<UIColor> {
		return UIControlStateValue<UIColor>(getter: self.shadowColor(for:), setter: self.setShadowColor(_:for:))
	}
	
	var  gradientColors: UIControlStateValue<[UIColor]> {
		return UIControlStateValue<[UIColor]>(getter: self.gradientColor(for:), setter: self.setGradientColor(_:for:))
	}
	
}
