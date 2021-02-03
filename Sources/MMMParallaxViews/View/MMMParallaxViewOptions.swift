//
// MMMParallaxViews. Part of MMMTemple.
// Copyright (C) 2020-2021 MediaMonks. All rights reserved.
//

import UIKit

public struct MMMParallaxViewOptions {

	public enum Height {

		/// Instructs to use fixed minimum and maximum heights known in advance.
		case fixed(min: CGFloat, max: CGFloat)

		/// Instructs to use Auto Layout when determining the minimum and the maximum height of the view.
		///
		/// It is going to use `systemLayoutSizeFitting(_:withHorizontalFittingPriority:verticalFittingPriority:)`
		/// where:
		///  - `(<container's width>, 0)` is the target size;
		///  - the horizontal fitting priority is always `.required`;
		///  - the vertical fitting priority is the same as `heightConstraintPriority` of the coordinator
		///    when determining the minimum size; or `.fittingSizeLevel` when determining the maximum one.
		case dynamic

		/// Calculate the height of the view automatically by autoLayout, gets the minimum height by calculating using
		/// priority `required - 1`, the maximum height by using priority `fittingSizeLevel`.
		public static func automatic(with view: UIView) -> Height {
			let min = view.systemLayoutSizeFitting(
				.zero,
				withHorizontalFittingPriority: .fittingSizeLevel,
				verticalFittingPriority: .required - 1
			).height
			
			let max = view.systemLayoutSizeFitting(
				.zero,
				withHorizontalFittingPriority: .fittingSizeLevel,
				verticalFittingPriority: .fittingSizeLevel
			).height
			
			return .init(min: min, max: max)
		}
		
		public init(min: CGFloat, max: CGFloat) {
			assert(min <= max)
			self = .fixed(min: min, max: max)
		}
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

	// TODO: should clarify this comment
	/// If the view should forward touches to the scrollView, makes it possible to scroll when dragging on the views.
	/// This is implemented in the wrapper, but should be custom implemented in your container when not using the wrapper.
	/// Defaults to true.
	public var forwardsTouches: Bool = true

	// TODO: note on sticky behaviour when bouncing
	/// The place on screen where the view will stick to (top, bottom), when using .none, the resizing functionality
	/// is not supported.
	/// Defaults to .both.
	public var stickPosition: StickPosition = .both
	
	public init(height: Height, type: TrackingType) {
		self.height = height
		self.type = type
	}

	// TODO: keeping single initializer with default values?
	public init(
		height: Height,
		type: TrackingType,
		forwardsTouches: Bool,
		stickPosition: StickPosition
	) {
		self.height = height
		self.type = type
		self.forwardsTouches = forwardsTouches
		self.stickPosition = stickPosition
	}
}
