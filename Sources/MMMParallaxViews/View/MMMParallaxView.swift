//
// MMMParallaxViews. Part of MMMTemple.
// Copyright (C) 2020-2021 MediaMonks. All rights reserved.
//

import UIKit

/// A view that can be placed over a Scroll/TableView that follows a certain point or cell. The height can be resized on scroll,
/// so you get a parallax effect; e.g. resize a header to be a sort-of navigation bar. Or resize a footer when the
/// bottom is reached to show more detailed information.
public protocol MMMParallaxView: UIView {

	/// Custom ID to use as refetence for the constraints, required to be unique. Defaults to class/type name.
	@available(*, deprecated, message: "Not neccessary anymore.")
	var id: ObjectIdentifier { get }

	var options: MMMParallaxViewOptions { get }

	/// Called when the scroll changed and the view is not at the top or bottom most position, so it actually moved on screen
	/// - Parameter coordinator: A reference to the coordinator
	/// - Parameter event: The event, check ParallaxScrollEvent for more info
	@available(*, deprecated, message: "Please use the new combined viewUpdated event.", renamed: "viewUpdated")
	func scrollChanged(_ coordinator: MMMParallaxViewCoordinator, event: MMMParallaxScrollEvent)
	
	/// Called when the views height is changed, this only gets called if the stickPosition != .none
	/// - Parameter coordinator: A reference to the coordinator
	/// - Parameter event: The event, check ParallaxScrollEvent for more info
	@available(*, deprecated, message: "Please use the new combined viewUpdated event.", renamed: "viewUpdated")
	func heightChanged(_ coordinator: MMMParallaxViewCoordinator, event: MMMParallaxHeightEvent)
	
	func viewUpdated(_ coordinator: MMMParallaxViewCoordinator, event: MMMParallaxUpdateEvent)
}

// Set defaults
extension MMMParallaxView {

	public var id: ObjectIdentifier {
		return ObjectIdentifier(self)
	}

	public func scrollChanged(_ coordinator: MMMParallaxViewCoordinator, event: MMMParallaxScrollEvent) {}
	public func heightChanged(_ coordinator: MMMParallaxViewCoordinator, event: MMMParallaxHeightEvent) {}
	
	public func viewUpdated(_ coordinator: MMMParallaxViewCoordinator, event: MMMParallaxUpdateEvent) {}
}
