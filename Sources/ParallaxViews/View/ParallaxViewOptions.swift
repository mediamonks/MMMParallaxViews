//
//  ParallaxViewOptions.swift
//  ParallaxViews
//
//  Created by Erik Terwan on 11/02/2020.
//  Copyright © 2020 MediaMonks. All rights reserved.
//

import UIKit

public struct ParallaxViewOptions {
	public struct Height {
		/// The minimum height the view should animate to
		public var min: CGFloat
		
		/// The maximum, or default, height of the view. When using tableView as type, you can set this to
		/// UITableView.automaticDimension to grab the height from the specified UITableViewCell.
		public var max: CGFloat
	}
	
	public enum TrackingType {
		/// Track a position in the scrollView
		case scrollView(y: CGFloat)
		/// Track a cell in a tableView, you're scrollView should be a UITableView for this
		case tableView(indexPath: IndexPath)
	}
	
	public struct StickPosition: OptionSet {
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
		
		public let rawValue: Int
		
		/// Only stick to the top of the container
		public static let top = StickPosition(rawValue: 1 << 0)
		
		/// Only stick to the bottom of the container
		public static let bottom = StickPosition(rawValue: 1 << 1)
		
		/// Don't stick at all, the position or cell is just tracked
		public static let none: StickPosition = []
		
		/// Stick to the bottom and top of the container
		public static let both: StickPosition = [.top, .bottom]
	}
	
	/// Define the min and max height of your ParallaxView
	public var height: Height
	
	/// Define the tracking type, could be either scrollView (define a y pos) or tableView (define a IndexPath)
	public var type: TrackingType
	
	/// If the view should forward touches to the scrollView, makes it possible to scroll when dragging on the views.
	/// This is implemented in the wrapper, but should be custom implemented in your container when not using the wrapper.
	/// Defaults to true.
	public var forwardsTouches: Bool = true
	
	/// The place on screen where the view will stick to (top, bottom), when using .none, the resizing functionality
	/// is not supported.
	/// Defaults to .both.
	public var stickPosition: StickPosition = .both
}
