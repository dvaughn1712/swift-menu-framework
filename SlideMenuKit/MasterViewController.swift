//
//  ViewController.swift
//  Custom SideBar Navigation
//
//  Created by David Vaughn on 10/26/15.
//  Copyright © 2015 David Vaughn. All rights reserved.
//

import UIKit

enum DeviceRotating {
	case iPhone
	case iPhone6Plus
	case iPad
}

public class MasterViewController: UIViewController, MainMenuDelegate {

	public var selectedIndex: Int? = 0
	public var menuButtonTintColor: UIColor = UIColor.whiteColor() {
		didSet {
			if let button = menuButton as? UIBarButtonItem {
				button.tintColor = menuButtonTintColor
			} else if let button = menuButton as? UIButton {
				button.tintColor = menuButtonTintColor
			}
		}
	}
	
	private(set) lazy var deviceToRotate: DeviceRotating = {
		if (self.traitCollection.verticalSizeClass == .Compact && self.traitCollection.horizontalSizeClass == .Regular) ||
			(self.traitCollection.horizontalSizeClass == .Compact && self.traitCollection.verticalSizeClass == .Regular) {
				//iPhone 6Plus
				return .iPhone6Plus
		} else if self.traitCollection.verticalSizeClass == .Regular && self.traitCollection.horizontalSizeClass == .Regular {
			// All iPads
			return .iPad
		} else {
			return .iPhone
		}
	}()
	
	private let maxAlpha: CGFloat = 0.3
	public var maxWidthForMenu: CGFloat! {
		
		switch deviceToRotate {
		case .iPhone:
			if self.view.bounds.width > self.view.bounds.height {
				return self.view.bounds.size.width / 3.5
			} else {
				return self.view.bounds.size.width / 2.5
			}
		case .iPhone6Plus, .iPad:
			if self.view.bounds.width > self.view.bounds.height {
				return view.bounds.size.width * 0.45
			} else {
				return view.bounds.size.width * 0.75
			}
		}
	}
	
	private var leadingMenuConstraint: NSLayoutConstraint?
	private var leadingMenuButtonConstraint: NSLayoutConstraint?
	private var topMenuButtonConstraint: NSLayoutConstraint?
	private var backgroundView: UIView?
	private var menuViewController: MenuViewController?
	private(set) var currentController: UIViewController!
	private var menuDataModel = MenuModel()
	
	private(set) var menuButton: AnyObject? {
		didSet {
			if let button = menuButton as? UIBarButtonItem {
				button.tintColor = menuButtonTintColor
			} else if let button = menuButton as? UIButton {
				button.tintColor = menuButtonTintColor
			}
		}
	}
	
	private class func bundle() -> NSBundle {
		return NSBundle(forClass: self)
	}
	
	private struct MenuButtonSelector {
		static func barButtonItem(target target: AnyObject) -> UIBarButtonItem {
			let image = UIImage(named: "ui-icon-menu", inBundle: MasterViewController.bundle(), compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
//			let image = UIImage(named: "ui-icon-menu")?.imageWithRenderingMode(.AlwaysTemplate)
			return UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: target, action: Selector("showMenuFromButton:"))
		}
		static func buttonItem(target target: AnyObject) -> UIButton {
			let image = UIImage(named: "ui-icon-menu", inBundle: MasterViewController.bundle(), compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)
//			let image = UIImage(named: "ui-icon-menu")?.imageWithRenderingMode(.AlwaysTemplate)
			let button = UIButton(frame: CGRectZero)
			button.translatesAutoresizingMaskIntoConstraints = false
			button.setImage(image, forState: .Normal)
			button.addTarget(target, action: Selector("showMenuFromButton:"), forControlEvents: UIControlEvents.TouchUpInside)
			button.accessibilityLabel = "menuButton"
			return button
		}
	}
	
	
	//MARK: - Init/View Lifecycle Events
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		if let menu = menuButton as? UIButton {
			setupConstraintsForRotationWithSize(size)
			coordinator.animateAlongsideTransition({ (context) -> Void in
				menu.layoutIfNeeded()
				}, completion: { (context) -> Void in
					
			})
		}
	}
	
	override public func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		if let _ = menuButton as? UIButton {
			if (newCollection.verticalSizeClass == .Compact && newCollection.horizontalSizeClass == .Regular) ||
				(newCollection.horizontalSizeClass == .Compact && newCollection.verticalSizeClass == .Regular) {
					//iPhone 6Plus
					deviceToRotate = .iPhone6Plus
			} else if newCollection.verticalSizeClass == .Regular && newCollection.horizontalSizeClass == .Regular {
				// All iPads
				deviceToRotate = .iPad
			} else {
				deviceToRotate = .iPhone
			}
		}
		
	}
	
	private func setupConstraintsForRotationWithSize(size: CGSize) {
		switch deviceToRotate {
		case .iPhone:
			if size.width > size.height {
				leadingMenuButtonConstraint?.constant = 10
				topMenuButtonConstraint?.constant = 16
			} else {
				leadingMenuButtonConstraint?.constant = 6
				topMenuButtonConstraint?.constant = 20
			}
		case .iPhone6Plus:
			if size.width > size.height {
				leadingMenuButtonConstraint?.constant = 10
				topMenuButtonConstraint?.constant = -1
			}
		case .iPad:
			leadingMenuButtonConstraint?.constant = 6
			topMenuButtonConstraint?.constant = 20
		}
	}
	
	//MARK: - Public Methods
	public func addMenuSelectionItem(cell: MenuCell) {
		menuDataModel.menuDataArray.append(cell)
	}
	
	public func addMenuSelectionItems(cells: [MenuCell]) {
		menuDataModel.menuDataArray.appendContentsOf(cells)
	}
	
	public func closeMenu(complete: (() -> Void)?) {
		if let menuView = menuViewController?.parentView {
			for constraint in menuView.constraintsAffectingLayoutForAxis(UILayoutConstraintAxis.Horizontal) {
				if let firstItem = constraint.firstItem as? UIView,
					let secondItem = constraint.secondItem as? UIView {
						
						if firstItem == menuView && constraint.firstAttribute == .Leading && secondItem == view && constraint.secondAttribute == .Leading  {
							constraint.constant = -maxWidthForMenu
							break
						}
				}
			}
			UIView.animateWithDuration(0.25, animations: { () -> Void in
				menuView.layoutIfNeeded()
				self.backgroundView?.alpha = 0
				}) { (done) -> Void in
					menuView.removeFromSuperview()
					self.menuViewController?.removeFromParentViewController()
					self.menuViewController = nil
					self.backgroundView?.removeFromSuperview()
					self.backgroundView = nil
					complete?()
			}
		}
	}

	public func didSelectCell(cell: MenuCell) {
		let removeController = currentController
		let mStoryBoard = UIStoryboard(name: cell.storyboardTitle, bundle: nil)
		let newController = mStoryBoard.instantiateViewControllerWithIdentifier(cell.controllerIdentifier)
		view.insertSubview(newController.view, atIndex: 0)
		newController.view.alpha = 0.0
		newController.willMoveToParentViewController(self)
		self.addChildViewController(newController)
		
		UIView.animateWithDuration(0.25, animations: { () -> Void in
			newController.view.alpha = 1.0
			removeController.view.alpha = 0.0
			}, completion: { (complete) -> Void in
				removeController.willMoveToParentViewController(nil)
				removeController.view.removeFromSuperview()
				removeController.removeFromParentViewController()
				newController.didMoveToParentViewController(self)
		})
		closeMenu(nil)
	}

	//MARK: - Menubutton Handler
	@objc private func showMenuFromButton(sender: AnyObject) {
		addMainMenuToChildViewControllers()
		if let menuView = menuViewController?.parentView {
			menuView.translatesAutoresizingMaskIntoConstraints = false
			leadingMenuConstraint = menuView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: -maxWidthForMenu)
			leadingMenuConstraint!.active = true
			menuView.widthAnchor.constraintEqualToConstant(maxWidthForMenu).active = true
			menuView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
			menuView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
			menuView.layoutIfNeeded()
			menuViewController!.drawShadow()
			
			leadingMenuConstraint!.constant = 0
			UIView.animateWithDuration(0.25, animations: { () -> Void in
				menuView.layoutIfNeeded()
				self.backgroundView?.alpha = self.maxAlpha
				}, completion: { (complete) in
					
			})
		}
	}
	
	//MARK: Private functions
	private func addMainMenuToChildViewControllers() {
		backgroundView = UIView(frame: CGRectZero)
		backgroundView!.backgroundColor = UIColor.blackColor()
		backgroundView!.alpha = 0
		backgroundView!.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(backgroundView!)
		backgroundView!.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
		backgroundView!.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
		backgroundView!.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
		backgroundView!.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
		
		if menuViewController == nil {
			menuViewController = MenuViewController(model: menuDataModel)
			menuViewController?.delegate = self
			let navigationVC = UINavigationController(rootViewController: menuViewController!)
			navigationVC.willMoveToParentViewController(self)
			self.addChildViewController(navigationVC)
			self.view.addSubview(navigationVC.view)
			navigationVC.didMoveToParentViewController(self)
		}
	}
	
	private func addMenuButtonToController(mController: UIViewController) {
		let controller = findAndReturnTopController(mController)
		if menuButton != nil && menuButton is UIButton {
			menuButton?.removeFromSuperview()
		}
		if let navigation = controller.navigationController
			where !navigation.navigationBar.hidden {
				menuButton = MenuButtonSelector.barButtonItem(target: self)
				controller.navigationItem.leftBarButtonItem = menuButton as? UIBarButtonItem
		} else {
			menuButton = MenuButtonSelector.buttonItem(target: self)
			let button = menuButton as! UIButton
			if let currentView = mController.view {
				currentView.insertSubview(button, atIndex: currentView.subviews.count)
				leadingMenuButtonConstraint = button.leftAnchor.constraintEqualToAnchor(currentView.leftAnchor, constant: 6)
				topMenuButtonConstraint = button.topAnchor.constraintEqualToAnchor(currentView.topAnchor, constant: 20)
				setupConstraintsForRotationWithSize(view.frame.size)
				leadingMenuButtonConstraint?.active = true
				topMenuButtonConstraint?.active = true
				button.widthAnchor.constraintEqualToConstant(44).active = true
				button.heightAnchor.constraintEqualToConstant(44).active = true
			}
		}
	}
	
	private func findAndReturnTopController(controller: UIViewController) -> UIViewController {
		func findTopController(mController: UIViewController) -> UIViewController {
			if mController.childViewControllers.count > 0 {
				if let navController = controller as? UINavigationController
					where mController.isKindOfClass(UINavigationController) {
						return self.findAndReturnTopController(navController.childViewControllers.last! as UIViewController)
				} else if let tabController = controller as? UITabBarController
					where mController.isKindOfClass(UITabBarController) {
						if tabController.selectedViewController != nil {
							return self.findAndReturnTopController(tabController.selectedViewController!)
						} else {
							return self.findAndReturnTopController(tabController.childViewControllers[0])
						}
				}
				return mController
			}
			return mController
		}
		return findTopController(controller)
	}
	
	override public func addChildViewController(childController: UIViewController) {
		super.addChildViewController(childController)
		if !(childController is MenuViewController) {
			if childController.childViewControllers.count > 0 {
				if !(childController.childViewControllers[0] is MenuViewController) {
					currentController = childController
					addMenuButtonToController(currentController)
				}
			} else {
				currentController = childController
				addMenuButtonToController(currentController)
			}
		}
	}

	//MARK: - UIView touch Method(s)
	private var startingTouch: CGPoint?
	private var deltaX: CGFloat = 0
	private var startTimeStamp: NSTimeInterval!
	override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if let touchPoint = touches.first?.locationInView(view)
			where touchPoint.x > maxWidthForMenu && menuViewController != nil {
				startingTouch = touchPoint
		} else if let touchPoint = touches.first?.locationInView(view)
			where touchPoint.x < 30 && menuViewController == nil {
				startingTouch = touchPoint
		}
		guard let touchEvent = event else {
			return
		}
		startTimeStamp = touchEvent.timestamp
	}
	
	override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		guard let currentPoint = touches.first?.locationInView(view)
			where startingTouch != nil else {
				return
		}
		
		guard let menuView = menuViewController?.parentView else {
			//menu does not exist so add it after we move 10 points
			if startingTouch!.x + 10 < currentPoint.x {
				addMainMenuToChildViewControllers()
				deltaX = currentPoint.x - startingTouch!.x
				if let menuView = menuViewController?.parentView {
					menuView.translatesAutoresizingMaskIntoConstraints = false
					leadingMenuConstraint = menuView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: -maxWidthForMenu)
					leadingMenuConstraint!.active = true
					menuView.widthAnchor.constraintEqualToConstant(maxWidthForMenu).active = true
					menuView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
					menuView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
					menuView.layoutIfNeeded()
					menuViewController!.drawShadow()
				}
			}
			return
		}
		let percentageOpen = (menuView.frame.size.width + menuView.frame.origin.x) / (maxWidthForMenu / 100) / 100
		backgroundView?.alpha = maxAlpha * percentageOpen
		
		if currentPoint.x <= maxWidthForMenu + deltaX {
			leadingMenuConstraint?.constant = -(maxWidthForMenu - currentPoint.x + deltaX)
		} else {
			leadingMenuConstraint?.constant = 0
		}
		view.updateConstraintsIfNeeded()
	}
	
	override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		guard let touchPoint = touches.first?.locationInView(view)
			where startingTouch != nil else {
				return
		}
		if menuViewController != nil {
			var dismiss = false
			if let endTouchEvent = event
				where endTouchEvent.timestamp < startTimeStamp + 0.2 {
					leadingMenuConstraint?.constant = -maxWidthForMenu
					dismiss = true
			} else {
				switch touchPoint.x {
				case startingTouch!.x:
					leadingMenuConstraint?.constant = -maxWidthForMenu
					dismiss = true
				case CGFloat(0.0)..<(maxWidthForMenu / 2):
					leadingMenuConstraint?.constant = -maxWidthForMenu
					dismiss = true
				case CGFloat(0.0)...(maxWidthForMenu):
					fallthrough
				default:
					leadingMenuConstraint?.constant = 0
				}
			}
			
			UIView.animateWithDuration(0.25, animations: { () -> Void in
				self.view.layoutIfNeeded()
				self.backgroundView?.alpha = dismiss ? 0.0 : self.maxAlpha
				}, completion: { (complete) in
					if dismiss {
						self.closeMenu(nil)
					}
					self.startingTouch = nil
					self.deltaX = 0
				}
			)
		} else {
			startingTouch = nil
			deltaX = 0
		}
	}
}
