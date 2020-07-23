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

public typealias NKButtonCreationBlock<T> = ((NKButtonItem, Int) -> T)
public typealias NKButtonSelectionBlock<T> = ((T, NKButtonItem, Int) -> Void)

open class NKButtonStack<T: UIButton>: UIControl {
	
	open var items: [NKButtonItem]? = nil {
		didSet {
			updateLayout()
			setNeedsLayout()
		}
	}
	
	public var buttons: [T] {
		return frameLayout.frameLayouts.map( { return $0.targetView as! T })
	}
	
	public var firstButton: T? {
		return frameLayout.firstFrameLayout?.targetView as? T
	}
	
	public var lastButton: T? {
		return frameLayout.lastFrameLayout?.targetView as? T
	}
	
	open var spacing: CGFloat {
		get {
			return frameLayout.spacing
		}
		set {
			frameLayout.spacing = newValue
			setNeedsLayout()
		}
	}
	
	open var contentEdgeInsets: UIEdgeInsets {
		get {
			return frameLayout.edgeInsets
		}
		set {
			frameLayout.edgeInsets = newValue
			setNeedsLayout()
		}
	}
	
	open var cornerRadius: CGFloat = 0 {
		didSet {
			layer.cornerRadius = cornerRadius
			layer.masksToBounds = cornerRadius > 0
		}
	}
	
	open var isRounded: Bool = false {
		didSet {
			if isRounded != oldValue {
				setNeedsLayout()
			}
		}
	}
	
	override open var frame: CGRect {
		didSet {
			setNeedsLayout()
		}
	}
	
	override open var bounds: CGRect {
		didSet {
			setNeedsLayout()
		}
	}
	
	public var selectedIndex: Int = -1 {
		didSet {
			for button in buttons {
				button.isSelected = selectedIndex == button.tag
			}
		}
	}
	
	public var axis: NKLayoutAxis {
		get {
			return frameLayout.axis
		}
		set {
			frameLayout.axis = newValue
			setNeedsLayout()
		}
	}
	
	public var isMomentary: Bool = true
	
	public var creationBlock: NKButtonCreationBlock<T>? = nil
	public var configurationBlock: NKButtonSelectionBlock<T>? = nil
	public var selectionBlock: NKButtonSelectionBlock<T>? = nil
	
	public let scrollView = UIScrollView()
	public let frameLayout = StackFrameLayout(axis: .horizontal, distribution: .equal)
	
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
	
	override open func layoutSubviews() {
		super.layoutSubviews()
		
		let viewSize = bounds.size
		let contentSize = frameLayout.sizeThatFits(CGSize(width: CGFloat.infinity, height: CGFloat.infinity))
		scrollView.contentSize = contentSize
		scrollView.frame = bounds
		
		var contentFrame = bounds
		if frameLayout.axis == .horizontal, contentSize.width > viewSize.width {
			contentFrame.size.width = contentSize.width
		}
		else if frameLayout.axis == .vertical, contentSize.height > viewSize.height {
			contentFrame.size.height = contentSize.height
		}
		frameLayout.frame = contentFrame
		
		if isRounded {
			cornerRadius = viewSize.height / 2
			setNeedsDisplay()
		}
	}
	
	// MARK: -
	
	public func button(at index: Int) -> T? {
		return frameLayout.frameLayout(at: index)?.targetView as? T
	}
	
	// MARK: -
	
	fileprivate func updateLayout() {
		if let buttonItems = items {
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
		else {
			frameLayout.enumerate({ (layout, index, stop) in
				if let button = layout.targetView as? T {
					button.removeTarget(self, action: #selector(onButtonSelected(_:)), for: .touchUpInside)
					button.removeFromSuperview()
				}
			})
			
			frameLayout.removeAll(autoRemoveTargetView: true)
		}
	}
	
	@objc fileprivate func onButtonSelected(_ sender: UIButton) {
		let index = sender.tag
		if isMomentary {
			selectedIndex = index
		}
		
		if selectionBlock != nil, let item = items?[index], let button = sender as? T {
			selectionBlock!(button, item, index)
		}
		
		sendActions(for: .valueChanged)
	}
	
}
