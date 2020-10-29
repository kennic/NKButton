//
//  NKButton.swift
//  NKButton
//
//  Created by Nam Kennic on 8/18/17.
//  Copyright © 2017 Nam Kennic. All rights reserved.
//

import UIKit
import FrameLayoutKit
#if canImport(NVActivityIndicatorView)
import NVActivityIndicatorView
#endif

public extension UIControl.State {
	static let hovered = UIControl.State(rawValue: 1 << 18)
}

public enum NKButtonLoadingIndicatorAlignment {
	case left
	case center
	case right
	case atImage
	case atPosition(position: CGPoint)
}

public enum NKButtonImageAlignment {
	case left
	case right
	case top
	case bottom
	case leftEdge(spacing: CGFloat)
	case rightEdge(spacing: CGFloat)
	case topEdge(spacing: CGFloat)
	case bottomEdge(spacing: CGFloat)
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
			return contentFrameLayout.spacing
		}
		set {
			contentFrameLayout.spacing = newValue
			contentFrameLayout.setNeedsLayout()
			setNeedsLayout()
		}
	}
	
	/** Minimum size of imageView, set zero to width or height to disable */
	open var imageMinSize: CGSize {
		get {
			return imageFrameLayout.minSize
		}
		set {
			imageFrameLayout.minSize = newValue
			contentFrameLayout.setNeedsLayout()
			setNeedsLayout()
		}
	}
	
	/** Maximum size of imageView, set zero to width or height to disable */
	open var imageMaxSize: CGSize {
		get {
			return imageFrameLayout.maxSize
		}
		set {
			imageFrameLayout.maxSize = newValue
			contentFrameLayout.setNeedsLayout()
			setNeedsLayout()
		}
	}
	
	/** Fixed size of imageView, set zero to width or height to disable */
	open var imageFixSize: CGSize {
		get {
			return imageFrameLayout.fixSize
		}
		set {
			imageFrameLayout.fixSize = newValue
			contentFrameLayout.setNeedsLayout()
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
			return labelFrame.horizontalAlignment
		}
		set {
			resetLabelAlignment()
			labelFrame.horizontalAlignment = newValue
			setNeedsLayout()
		}
	}
	
	/** Text Vertical Alignment */
	open var textVerticalAlignment: NKContentVerticalAlignment {
		get {
			return labelFrame.verticalAlignment
		}
		set {
			resetLabelAlignment()
			labelFrame.verticalAlignment = newValue
			setNeedsLayout()
		}
	}
	
	/** Text Alignment */
	open var textAlignment: (NKContentVerticalAlignment, NKContentHorizontalAlignment) {
		get {
			return labelFrame.alignment
		}
		set {
			resetLabelAlignment()
			labelFrame.alignment = newValue
			setNeedsLayout()
		}
	}
	
	override open var contentEdgeInsets: UIEdgeInsets {
		get {
			return contentFrameLayout.edgeInsets
		}
		set {
			contentFrameLayout.edgeInsets = newValue
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
			guard isLoading != oldValue else { return }
			isEnabled = !isLoading
			
			if isLoading {
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
	/// `true` is mous cursor is hovering
	public fileprivate(set) var isHovering = false
	/** imageView will be hidden when `isLoading` is true */
	open var hideImageWhileLoading = false
	/** titleLabel will be hidden when `isLoading` is true */
	open var hideTitleWhileLoading = true
	/** Button will animated to circle shape when set `isLoading = true`*/
	open var transitionToCircleWhenLoading: Bool = false
	#if canImport(NVActivityIndicatorView)
	/** Style of loading indicator */
	open var loadingIndicatorStyle: NVActivityIndicatorType = .ballPulse
	#else
	open var loadingIndicatorStyle: UIActivityIndicatorView.Style = .white
	#endif
	/** Scale ratio of loading indicator, based on the minimum value of button width or height */
	open var loadingIndicatorScaleRatio: CGFloat = 0.7
	/** Color of loading indicator, if `nil`, it will use titleColor of normal state */
	open var loadingIndicatorColor: UIColor? = nil
	/** Alignment for loading indicator */
	open var loadingIndicatorAlignment: NKButtonLoadingIndicatorAlignment = .center
	
	private let flashAnimationKey = "flashAnimation"
	open var isFlashing: Bool {
		return flashLayer.animation(forKey: flashAnimationKey) != nil
	}
	
	/** The background view of the button */
	open var backgroundView: UIView? = nil {
		didSet {
			oldValue?.layer.removeFromSuperlayer()
			guard let view = backgroundView else { return }
			view.isUserInteractionEnabled = false
			view.layer.masksToBounds = true
			layer.insertSublayer(view.layer, at: 0)
			setNeedsLayout()
		}
	}
	/** `FrameLayout` that layout imageView */
	public let imageFrameLayout		= FrameLayout()
	/** `FrameLayout` that handles textLabel */
	public let labelFrameLayout		= FrameLayout()
	/** `FrameLayout` that handles contents */
	public let contentFrameLayout 	= DoubleFrameLayout(axis: .horizontal)
	
	#if canImport(NVActivityIndicatorView)
	fileprivate var loadingView 	: NVActivityIndicatorView? = nil
	#else
	fileprivate var loadingView 	: UIActivityIndicatorView? = nil
	#endif
	fileprivate let shadowLayer 	= CAShapeLayer()
	fileprivate let backgroundLayer = CAShapeLayer()
	fileprivate let flashLayer 		= CAShapeLayer()
	fileprivate let gradientLayer	= CAGradientLayer()
	
	fileprivate var bgColorDict			: [String : UIColor] = [:]
	fileprivate var borderColorDict		: [String : UIColor] = [:]
	fileprivate var shadowColorDict		: [String : UIColor] = [:]
	fileprivate var gradientColorDict	: [String : [UIColor]] = [:]
	fileprivate var borderSizeDict		: [String : CGFloat] = [:]
	fileprivate var borderDashDict		: [String : [NSNumber]] = [:]
	fileprivate var titleFontDict		: [String : UIFont] = [:]
	
	fileprivate var labelFrame: FrameLayout {
		return contentFrameLayout.leftFrameLayout.targetView == labelFrameLayout ? contentFrameLayout.leftFrameLayout : contentFrameLayout.rightFrameLayout
	}
	
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
		setupUI()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupUI()
	}
	
	open func setupUI() {
		flashLayer.opacity = 0
		flashLayer.fillColor = flashColor.cgColor
		contentEdgeInsets = .zero
		
		layer.addSublayer(shadowLayer)
		layer.addSublayer(backgroundLayer)
		layer.addSublayer(flashLayer)
		layer.addSublayer(gradientLayer)
		
		contentFrameLayout.isIntrinsicSizeEnabled = true
		contentFrameLayout.frameLayout1.alignment = (.center, .center)
		contentFrameLayout.frameLayout2.alignment = (.center, .center)
		
		imageFrameLayout.alignment = (.fit, .fit)
		imageFrameLayout.targetView = imageView
		
		labelFrameLayout.alignment = (.fill, .fill)
		labelFrameLayout.targetView = titleLabel

		updateLayoutAlignment()
		addSubview(labelFrameLayout)
		addSubview(imageFrameLayout)
		addSubview(contentFrameLayout)
		
		if #available(iOS 13.4, *) {
			enablePointerInteraction()
		}
		else if #available(iOS 13.0, *) {
			enableHoverGesture()
		}
	}
	
	@available(iOS 13.0, *)
	open func enableHoverGesture() {
		let hoverGesture = UIHoverGestureRecognizer(target: self, action: #selector(onHovered))
		addGestureRecognizer(hoverGesture)
	}
	
	open override func setNeedsLayout() {
		super.setNeedsLayout()
		
		contentFrameLayout.setNeedsLayout()
		imageFrameLayout.setNeedsLayout()
		labelFrameLayout.setNeedsLayout()
	}
	
	override open func sizeThatFits(_ size: CGSize) -> CGSize {
		let lastOverlapped = contentFrameLayout.isOverlapped
		if lastOverlapped {
			resetLabelAlignment()
		}
		
		var result = contentFrameLayout.sizeThatFits(size)
		
		result.width  += extendSize.width
		result.height += extendSize.height
		result.width  = min(result.width, size.width)
		result.height = min(result.height, size.height)
		
		if lastOverlapped {
			makeTitleRealCenter()
		}
		
		return result
	}
	
	override open func sizeToFit() {
		let size = sizeThatFits(UIScreen.main.bounds.size)
		frame = CGRect(origin: frame.origin, size: size)
	}
	
	override open func draw(_ rect: CGRect) {
		super.draw(rect)
		
		let currentState = isHovering ? [state, .hovered] : state
		let backgroundFrame = bounds
		let fillColor 		= backgroundColor(for: currentState) ?? backgroundColor(for: state) ?? backgroundColor(for: .normal)
		let strokeColor 	= borderColor(for: currentState)
		let strokeSize		= borderSize(for: currentState)
		let lineDashPattern = borderDashPattern(for: currentState)
		let roundedPath 	= UIBezierPath(roundedRect: backgroundFrame, cornerRadius: cornerRadius)
		let path			= transitionToCircleWhenLoading && isLoading ? backgroundLayer.path : roundedPath.cgPath
		
		backgroundLayer.path			= path
		backgroundLayer.fillColor		= fillColor?.cgColor
		backgroundLayer.strokeColor		= strokeColor?.cgColor
		backgroundLayer.lineWidth		= strokeSize
		backgroundLayer.miterLimit		= roundedPath.miterLimit
		backgroundLayer.lineDashPattern = lineDashPattern
		
		flashLayer.path 				= path
		flashLayer.fillColor 			= flashColor.cgColor
		
		if let shadowColor = shadowColor(for: currentState) {
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
		
		if let gradientColors = gradientColor(for: currentState) {
			var colors: [CGColor] = []
			for color in gradientColors {
				colors.append(color.cgColor)
			}
			
			gradientLayer.isHidden = false
			gradientLayer.cornerRadius = cornerRadius
			gradientLayer.shadowPath = path
			gradientLayer.colors = colors
		}
		else {
			gradientLayer.isHidden = true
			gradientLayer.colors = nil
		}
		
		if let titleFont = titleFont(for: currentState) {
			titleLabel?.font = titleFont
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
		contentFrameLayout.frame = bounds
		
		contentFrameLayout.setNeedsLayout()
		contentFrameLayout.layoutIfNeeded()
		
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
				case .atPosition(let position): point = position
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
	
	open override func didMoveToWindow() {
		super.didMoveToWindow()
		guard window != nil else { return }
		setNeedsLayout()
	}
	
	open override func didMoveToSuperview() {
		super.didMoveToSuperview()
		guard window != nil else { return }
		setNeedsLayout()
	}
	
	fileprivate func updateLayoutAlignment() {
		resetLabelAlignment()
		
		switch imageAlignment {
		case .left:
			contentFrameLayout.axis = .horizontal
			contentFrameLayout.distribution = .center
			
			contentFrameLayout.leftFrameLayout.targetView = imageFrameLayout
			contentFrameLayout.rightFrameLayout.targetView = labelFrameLayout
			break
			
		case .leftEdge(let spacing):
			contentFrameLayout.axis = .horizontal
			contentFrameLayout.distribution = .left
			
			imageFrameLayout.padding(top: 0, left: spacing, bottom: 0, right: 0)
			contentFrameLayout.leftFrameLayout.targetView = imageFrameLayout
			contentFrameLayout.rightFrameLayout.targetView = labelFrameLayout
			makeTitleRealCenter()
			break
			
		case .right:
			contentFrameLayout.axis = .horizontal
			contentFrameLayout.distribution = .center
			
			contentFrameLayout.leftFrameLayout.targetView = labelFrameLayout
			contentFrameLayout.rightFrameLayout.targetView = imageFrameLayout
			break
			
		case .rightEdge(let spacing):
			contentFrameLayout.axis = .horizontal
			contentFrameLayout.distribution = .right
			
			imageFrameLayout.padding(top: 0, left: 0, bottom: 0, right: spacing)
			contentFrameLayout.leftFrameLayout.targetView = labelFrameLayout
			contentFrameLayout.rightFrameLayout.targetView = imageFrameLayout
			makeTitleRealCenter()
			break
			
		case .top:
			contentFrameLayout.axis = .vertical
			contentFrameLayout.distribution = .center
			
			contentFrameLayout.topFrameLayout.targetView = imageFrameLayout
			contentFrameLayout.bottomFrameLayout.targetView = labelFrameLayout
			break
			
		case .topEdge(let spacing):
			contentFrameLayout.axis = .vertical
			contentFrameLayout.distribution = .top
			
			imageFrameLayout.padding(top: spacing, left: 0, bottom: 0, right: 0)
			contentFrameLayout.topFrameLayout.targetView = imageFrameLayout
			contentFrameLayout.bottomFrameLayout.targetView = labelFrameLayout
			break
			
		case .bottom:
			contentFrameLayout.axis = .vertical
			contentFrameLayout.distribution = .center
			
			contentFrameLayout.topFrameLayout.targetView = labelFrameLayout
			contentFrameLayout.bottomFrameLayout.targetView = imageFrameLayout
			break
			
		case .bottomEdge(let spacing):
			contentFrameLayout.axis = .vertical
			contentFrameLayout.distribution = .bottom
			
			imageFrameLayout.padding(top: 0, left: 0, bottom: spacing, right: 0)
			contentFrameLayout.topFrameLayout.targetView = labelFrameLayout
			contentFrameLayout.bottomFrameLayout.targetView = imageFrameLayout
			break
		}
		
		setNeedsDisplay()
		setNeedsLayout()
	}
	
	fileprivate func makeTitleRealCenter() {
		switch imageAlignment {
			case .leftEdge(_), .rightEdge:
				contentFrameLayout.isOverlapped = true
				labelFrameLayout.isIntrinsicSizeEnabled = false
				labelFrameLayout.alignment = (.center, .center)
			
			default: break
		}
	}
	
	fileprivate func resetLabelAlignment() {
		contentFrameLayout.isOverlapped = false
		labelFrameLayout.isIntrinsicSizeEnabled = true
		labelFrameLayout.alignment = (.fill, .fill)
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
	
	override open var center: CGPoint {
		didSet {
			setNeedsDisplay()
			setNeedsLayout()
		}
	}
	
	override open var isHighlighted: Bool {
		didSet {
			guard isHighlighted != oldValue else { return }
			setNeedsDisplay()
			
//			if isHighlighted {
//				if #available(iOS 10, *) {
//					let generator = UIImpactFeedbackGenerator(style: .light)
//					generator.prepare()
//					generator.impactOccurred()
//				}
//			}
		}
	}
	
	@available(iOS 13.0, *)
	@objc func onHovered(_ gesture: UIHoverGestureRecognizer) {
		let gestureState = gesture.state
		if gestureState == .began || gestureState == .ended || gestureState == .cancelled {
			isHovering = gestureState == .began
			setNeedsDisplay()
		}
	}
	
	
	// MARK: -
	
	open func startFlashing(flashDuration: TimeInterval = 0.5, intensity: Float = 0.85, repeatCount: Int = -1) {
		flashLayer.removeAnimation(forKey: flashAnimationKey)
		
		let flash = CABasicAnimation(keyPath: "opacity")
		flash.fromValue = 0.0
		flash.toValue = intensity
		flash.duration = flashDuration
		flash.autoreverses = true
		flash.repeatCount = repeatCount < 0 ? .infinity : Float(repeatCount)
		flashLayer.add(flash, forKey: flashAnimationKey)
	}
	
	open func stopFlashing() {
		flashLayer.removeAnimation(forKey: flashAnimationKey)
	}
	
	@available (iOS 13.4, *)
	open func enablePointerInteraction(insets: CGFloat = -5) {
		isPointerInteractionEnabled = true
		pointerStyleProvider = { (button, effect, shape) in
			let frame = button.frame.insetBy(dx: insets, dy: insets)
			let buttonShape = UIPointerShape.roundedRect(frame, radius: self.cornerRadius)
			return UIPointerStyle(effect: effect, shape: buttonShape)
		}
	}
	
	// MARK: -
	
	override open func setTitle(_ title: String?, for state: UIControl.State) {
		super.setTitle(title, for: state)
		guard self.state == state else { return }
		titleLabel?.text = title
		setNeedsLayout()
	}
	
	open func setTitleFont(_ font: UIFont?, for state: UIControl.State) {
		let key = titleFontKey(for: state)
		titleFontDict[key] = font
		guard self.state == state else { return }
		titleLabel?.font = font
		setNeedsLayout()
	}
	
	override open func setImage(_ image: UIImage?, for state: UIControl.State) {
		super.setImage(image, for: state)
		guard self.state == state else { return }
		imageView?.image = image
		setNeedsLayout()
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
	
	open func setBorderDashPattern(_ value: [NSNumber]?, for state: UIControl.State) {
		let key = borderDashKey(for: state)
		borderDashDict[key] = value
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
	
	open func borderDashPattern(for state: UIControl.State) -> [NSNumber]? {
		let key = borderDashKey(for: state)
		return borderDashDict[key]
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
	
	open func titleFont(for state: UIControl.State) -> UIFont? {
		let key = titleFontKey(for: state)
		return titleFontDict[key]
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
	
	fileprivate func borderDashKey(for state: UIControl.State) -> String {
		return "bd\(state.rawValue)"
	}
	
	fileprivate func titleFontKey(for state: UIControl.State) -> String {
		return "tf\(state.rawValue)"
	}
	
	// MARK: -
	
	fileprivate func showLoadingView() {
		guard loadingView == nil else { return }
		
		let viewSize = bounds.size
		let minSize = min(viewSize.width, viewSize.height) * loadingIndicatorScaleRatio
		let indicatorSize = CGSize(width: minSize, height: minSize)
		let loadingFrame = CGRect(x: 0, y: 0, width: indicatorSize.width, height: indicatorSize.height)
		let color = loadingIndicatorColor ?? titleColor(for: .normal)
		
		#if canImport(NVActivityIndicatorView)
		loadingView = NVActivityIndicatorView(frame: loadingFrame, type: loadingIndicatorStyle, color: color, padding: 0)
		#else
		loadingView = UIActivityIndicatorView(style: loadingIndicatorStyle)
		#endif
		
		loadingView!.startAnimating()
		addSubview(loadingView!)
		setNeedsLayout()
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
			backgroundLayer.cornerRadius = min(frame.width, frame.height)/2
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
button.titles[.normal] = ""
button.titleColors[[.normal, .highlighted]] = .black
button.backgroundColors[[.normal, .highlighted]] = .white
*/
public class UIControlStateValue<T> {
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
	
	public subscript(state: UIControl.State) -> T? {
		get {
			return getter(state)
		}
		set {
			setter(newValue, state)
		}
	}
}

public extension NKButton {
    
    var attributedTitles: UIControlStateValue<NSAttributedString> {
        return UIControlStateValue<NSAttributedString>(getter: self.attributedTitle(for:), setter: self.setAttributedTitle(_:for:))
    }
    
    var titles: UIControlStateValue<String> {
        return UIControlStateValue<String>(getter: self.title(for:), setter: self.setTitle(_:for:))
    }
    
    var titleColors: UIControlStateValue<UIColor> {
        return UIControlStateValue<UIColor>(getter: self.titleColor(for:), setter: self.setTitleColor(_:for:))
    }
    
    var titleFonts: UIControlStateValue<UIFont> {
        return UIControlStateValue<UIFont>(getter: self.titleFont(for:), setter: self.setTitleFont(_:for:))
    }
    
    var images: UIControlStateValue<UIImage> {
        return UIControlStateValue<UIImage>.init(getter: self.image, setter: self.setImage(_:for:))
    }
    
    var backgroundColors: UIControlStateValue<UIColor> {
        return UIControlStateValue<UIColor>(getter: self.backgroundColor(for:), setter: self.setBackgroundColor(_:for:))
    }
    
    var borderColors: UIControlStateValue<UIColor> {
        return UIControlStateValue<UIColor>(getter: self.borderColor(for:), setter: self.setBorderColor(_:for:))
    }
    
    var borderSizes: UIControlStateValue<CGFloat> {
        return UIControlStateValue<CGFloat>(getter: self.borderSize(for:), setter: self.setBorderSize(_:for:))
    }
    
    var borderDashPatterns: UIControlStateValue<[NSNumber]> {
        return UIControlStateValue<[NSNumber]>(getter: self.borderDashPattern(for:), setter: self.setBorderDashPattern(_:for:))
    }
    
    var shadowColors: UIControlStateValue<UIColor> {
        return UIControlStateValue<UIColor>(getter: self.shadowColor(for:), setter: self.setShadowColor(_:for:))
    }
    
    var gradientColors: UIControlStateValue<[UIColor]> {
        return UIControlStateValue<[UIColor]>(getter: self.gradientColor(for:), setter: self.setGradientColor(_:for:))
    }
    
}
