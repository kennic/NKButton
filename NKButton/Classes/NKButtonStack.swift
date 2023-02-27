//
//  NKButtonStack.swift
//  NKButton
//
//  Created by Nam Kennic on 8/23/17.
//  Copyright © 2017 Nam Kennic. All rights reserved.
//

import UIKit
import FrameLayoutKit

public struct NKButtonItem {
	public var title: String?
	public var image: UIImage?
	public var selectedImage: UIImage?
	public var userInfo: Any?
	
	public init(title: String?, image: UIImage? = nil, selectedImage: UIImage? = nil, userInfo: Any? = nil) {
		self.title = title
		self.image = image
		self.selectedImage = selectedImage
		self.userInfo = userInfo
	}
}

public enum NKButtonStackSelectionMode {
	case momentary
	case singleSelection
	case multiSelection
}

public typealias NKButtonCreationBlock<T> = (NKButtonItem, Int) -> T
public typealias NKButtonSelectionBlock<T> = (T, NKButtonItem, Int) -> Void

open class NKButtonStack<T: UIButton>: UIControl {
	
	open var items: [NKButtonItem]? = nil {
		didSet {
			updateLayout()
			setNeedsLayout()
		}
	}
	
	public var buttons: [T] { frameLayout.frameLayouts.map( { return $0.targetView as! T }) }
	public var firstButton: T? { frameLayout.firstFrameLayout?.targetView as? T }
	public var lastButton: T? { frameLayout.lastFrameLayout?.targetView as? T }
	
	open var spacing: CGFloat {
		get { frameLayout.spacing }
		set {
			frameLayout.spacing = newValue
			setNeedsLayout()
		}
	}
	
	open var contentEdgeInsets: UIEdgeInsets {
		get { frameLayout.edgeInsets }
		set {
			frameLayout.edgeInsets = newValue
			setNeedsLayout()
		}
	}
	
	open var cornerRadius: CGFloat = 0 {
		didSet {
			guard cornerRadius != oldValue else { return }
			setNeedsDisplay()
		}
	}
	
	/** Shadow color */
	open var shadowColor: UIColor? = nil {
		didSet {
			guard shadowColor != oldValue else { return }
			setNeedsDisplay()
		}
	}
	
	/** Shadow radius */
	open var shadowRadius: CGFloat = 0 {
		didSet {
			guard shadowRadius != oldValue else { return }
			setNeedsDisplay()
		}
	}
	
	/** Shadow opacity */
	open var shadowOpacity: Float = 0.5 {
		didSet {
			guard shadowOpacity != oldValue else { return }
			setNeedsDisplay()
		}
	}
	
	/** Shadow offset */
	open var shadowOffset: CGSize = .zero {
		didSet {
			guard shadowOffset != oldValue else { return }
			setNeedsDisplay()
		}
	}
	
	/** Border color */
	open var borderColor: UIColor? = nil {
		didSet {
			guard borderColor != oldValue else { return }
			setNeedsDisplay()
		}
	}
	
	/** Size of border */
	open var borderSize: CGFloat = 0 {
		didSet {
			guard borderSize != oldValue else { return }
			setNeedsDisplay()
		}
	}
	
	/** Border dash pattern */
	open var borderDashPattern: [NSNumber]? = nil {
		didSet {
			guard borderDashPattern != oldValue else { return }
			setNeedsDisplay()
		}
	}
	
	/** Border color */
	private var _backgroundColor: UIColor? = nil
	open override var backgroundColor: UIColor?{
		get { _backgroundColor }
		set {
			_backgroundColor = newValue
			setNeedsDisplay()
			super.backgroundColor = .clear
		}
	}
	
	open var isRounded: Bool = false {
		didSet {
			guard isRounded != oldValue else { return }
			setNeedsLayout()
		}
	}
	
	override open var frame: CGRect {
		didSet { setNeedsLayout() }
	}
	
	override open var bounds: CGRect {
		didSet { setNeedsLayout() }
	}
	
	public var selectedIndex: Int = -1 {
		didSet {
			buttons.forEach { $0.isSelected = selectedIndex == $0.tag }
		}
	}
	
	public var selectedIndexes: [Int] {
		get { buttons.filter { $0.isSelected }.map { $0.tag } }
		set { buttons.forEach { $0.isSelected = newValue.contains($0.tag) } }
	}
	
	public var axis: NKLayoutAxis {
		get { frameLayout.axis }
		set {
			frameLayout.axis = newValue
			setNeedsLayout()
		}
	}
	
	@available(*, deprecated, message: "Use `selectionMode` instead")
	public var isMomentary = false {
		didSet {
			selectionMode = isMomentary ? .momentary : .singleSelection
		}
	}
	
	public var selectionMode: NKButtonStackSelectionMode = .singleSelection
	public var creationBlock: NKButtonCreationBlock<T>? = nil
	public var configurationBlock: NKButtonSelectionBlock<T>? = nil
	public var selectionBlock: NKButtonSelectionBlock<T>? = nil
	
	public let scrollView = UIScrollView()
	public let frameLayout = StackFrameLayout(axis: .horizontal, distribution: .equal)
	
	fileprivate let shadowLayer 	= CAShapeLayer()
	fileprivate let backgroundLayer = CAShapeLayer()
	
	// MARK: -
	
	convenience public init(items: [NKButtonItem], axis: NKLayoutAxis = .horizontal) {
		self.init()
		
		self.axis = axis
		defer {
			self.items = items
		}
	}
	
	public init() {
		super.init(frame: .zero)
		
		layer.addSublayer(shadowLayer)
		layer.addSublayer(backgroundLayer)
		
		frameLayout.spacing = 1.0
		frameLayout.isIntrinsicSizeEnabled = true
		frameLayout.shouldCacheSize = false
		
		scrollView.bounces = true
		scrollView.alwaysBounceHorizontal = false
		scrollView.alwaysBounceVertical = false
		scrollView.isDirectionalLockEnabled = true
		scrollView.showsVerticalScrollIndicator = false
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.clipsToBounds = false
		scrollView.delaysContentTouches = false
		scrollView.addSubview(frameLayout)
		addSubview(scrollView)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override open func sizeThatFits(_ size: CGSize) -> CGSize {
		return frameLayout.sizeThatFits(size)
	}
	
	override open func draw(_ rect: CGRect) {
		super.draw(rect)
		
		let backgroundFrame = bounds
		let fillColor 		= backgroundColor
		let strokeColor 	= borderColor
		let strokeSize		= borderSize
		let roundedPath 	= UIBezierPath(roundedRect: backgroundFrame, cornerRadius: cornerRadius)
		let path			= roundedPath.cgPath
		
		backgroundLayer.path			= path
		backgroundLayer.fillColor		= fillColor?.cgColor
		backgroundLayer.strokeColor		= strokeColor?.cgColor
		backgroundLayer.lineWidth		= strokeSize
		backgroundLayer.miterLimit		= roundedPath.miterLimit
		backgroundLayer.lineDashPattern = borderDashPattern
		
		if let shadowColor = shadowColor {
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
	}
	
	override open func layoutSubviews() {
		super.layoutSubviews()
		
		shadowLayer.frame = bounds
		backgroundLayer.frame = bounds
		
		let viewSize = bounds.size
		let contentSize = frameLayout.sizeThatFits(CGSize(width: CGFloat.infinity, height: CGFloat.infinity))
		scrollView.contentSize = contentSize
		scrollView.frame = bounds
		
		var contentFrame = bounds
		if frameLayout.axis == .horizontal, contentSize.width > viewSize.width {
			contentFrame.size.width = contentSize.width
			scrollView.delaysContentTouches = true
		}
		else if frameLayout.axis == .vertical, contentSize.height > viewSize.height {
			contentFrame.size.height = contentSize.height
			scrollView.delaysContentTouches = true
		}
		else {
			scrollView.delaysContentTouches = false
		}
		
		frameLayout.frame = contentFrame
		
		if isRounded {
			cornerRadius = viewSize.height / 2
			setNeedsDisplay()
		}
		
		if cornerRadius > 0 {
			scrollView.layer.cornerRadius = cornerRadius
			scrollView.layer.masksToBounds = true
		}
		else {
			scrollView.layer.cornerRadius = 0
			scrollView.layer.masksToBounds = false
		}
	}
	
	// MARK: -
	
	public func button(at index: Int) -> T? {
		return frameLayout.frameLayout(at: index)?.targetView as? T
	}
	
	open func setShadow(color: UIColor?, radius: CGFloat, opacity: Float = 1.0, offset: CGSize = .zero) {
		self.shadowColor = color
		self.shadowOpacity = opacity
		self.shadowRadius = radius
		self.shadowOffset = offset
	}
	
	@discardableResult
	public func creation(_ block: @escaping NKButtonCreationBlock<T>) -> Self {
		creationBlock = block
		return self
	}
	
	@discardableResult
	public func configuration(_ block: @escaping NKButtonSelectionBlock<T>) -> Self {
		configurationBlock = block
		return self
	}
	
	@discardableResult
	public func selection(_ block: @escaping NKButtonSelectionBlock<T>) -> Self {
		selectionBlock = block
		return self
	}
	
	// MARK: -
	
	fileprivate func updateLayout() {
		guard let buttonItems = items else {
			frameLayout.enumerate({ (layout, index, stop) in
				if let button = layout.targetView as? T {
					button.removeTarget(self, action: #selector(onButtonSelected(_:)), for: .touchUpInside)
					button.removeFromSuperview()
				}
			})
			
			frameLayout.removeAll(autoRemoveTargetView: true)
			return
		}
		
		let total = buttonItems.count
		
		if frameLayout.frameLayouts.count > total {
			frameLayout.enumerate({ (layout, index, stop) in
				if Int(index) >= Int(total) {
					if let button = layout.targetView as? T {
						button.removeTarget(self, action: #selector(onButtonSelected(_:)), for: .touchUpInside)
						button.removeFromSuperview()
					}
				}
			})
		}
		
		frameLayout.numberOfFrameLayouts = total
		
		frameLayout.enumerate({ (layout, idx, stop) in
			let index = Int(idx)
			let buttonItem = items![index]
			let button = layout.targetView as? T ?? creationBlock?(buttonItem, index) ?? T()
			button.tag = index
			button.addTarget(self, action: #selector(onButtonSelected(_:)), for: .touchUpInside)
			scrollView.addSubview(button)
			layout.targetView = button
			
			guard let configurationBlock = configurationBlock else {
				button.setTitle(buttonItem.title, for: .normal)
				button.setImage(buttonItem.image, for: .normal)
				
				if buttonItem.selectedImage != nil {
					button.setImage(buttonItem.selectedImage, for: .highlighted)
					button.setImage(buttonItem.selectedImage, for: .selected)
				}
				return
			}
			
			configurationBlock(button , buttonItem, index)
		})
	}
	
	@objc fileprivate func onButtonSelected(_ sender: UIButton) {
		let index = sender.tag
		
		if selectionMode == .singleSelection {
			selectedIndex = index
		}
		else if selectionMode == .multiSelection {
			sender.isSelected = !sender.isSelected
		}
		
		if let item = items?[index], let button = sender as? T {
			selectionBlock?(button, item, index)
		}
		
		sendActions(for: .valueChanged)
	}
	
}
