//
//  MenuViewController.swift
//  Custom SideBar Navigation
//
//  Created by David Vaughn on 10/26/15.
//  Copyright © 2015 David Vaughn. All rights reserved.
//

import UIKit

protocol MainMenuDelegate: class {
	func didSelectCell(cell: MenuCell)
	var selectedIndex: Int? { get set }
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	private weak var tableView: UITableView!
	weak var delegate: MainMenuDelegate?
	private var model: MenuModel
	var parentView: UIView! {
		return self.parentViewController?.view ?? self.view
	}
	
	init(model: MenuModel) {
		self.model = model
		super.init(nibName: nil, bundle: nil)
		setupMenu()
	}
	
	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		navigationItem.title = "Main Menu"
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		coordinator.animateAlongsideTransition({ [unowned self](context) -> Void in
			self.drawShadow()
			}, completion: nil)
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
	}
	
	func setupMenu() {
		let tableView = UITableView(frame: CGRectZero)
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		tableView.delegate = self
		tableView.dataSource = self
		view.addSubview(tableView)
		self.tableView = tableView
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
		tableView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
		tableView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
		tableView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
	}
	
	func drawShadow() {
		parentView.clipsToBounds = false
		parentView.layer.shadowOpacity = 0.5
		parentView.layer.shadowRadius = 2.0
		parentView.layer.shadowOffset = CGSizeMake(2.0, 0.0)
		parentView.layer.shadowPath = UIBezierPath(rect: view.bounds).CGPath
	}
	
	func removeShadow() {
		view.clipsToBounds = true
		view.layer.shadowOpacity = 0.0
		view.layer.shadowRadius = 0.0
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return model.menuDataArray.count
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 60
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
		let data = model.menuDataArray[indexPath.row]
		cell.textLabel?.text = data.cellTitle
		return cell
	}
	
	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.row == delegate?.selectedIndex {
			cell.setSelected(true, animated: false)
		}
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		delegate?.selectedIndex = indexPath.row
		delegate?.didSelectCell(model.menuDataArray[indexPath.row])
	}
}
