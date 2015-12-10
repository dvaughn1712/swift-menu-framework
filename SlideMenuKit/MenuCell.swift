//
//  MenuCell.swift
//  Custom SideBar Navigation
//
//  Created by David Vaughn on 10/26/15.
//  Copyright © 2015 David Vaughn. All rights reserved.
//

import Foundation

public struct MenuCell {
	public let controllerIdentifier: String
	public let storyboardTitle: String
	public let cellTitle: String
	
	public init(controllerIdentifier: String, storyboardTitle: String, cellTitle: String) {
		self.controllerIdentifier = controllerIdentifier
		self.storyboardTitle = storyboardTitle
		self.cellTitle = cellTitle
	}
}