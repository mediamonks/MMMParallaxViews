//
//  ParallaxView.swift
//  ParallaxViews
//
//  Created by Erik Terwan on 11/02/2020.
//  Copyright © 2020 MediaMonks. All rights reserved.
//

import UIKit

/// A view that can be placed over a Scroll/TableView that follows a certain point or cell. The height can be resized on scroll,
/// so you get a parallax effect; e.g. resize a header to be a sort-of navigation bar. Or resize a footer when the
/// bottom is reached to show more detailed information.
public protocol ParallaxView: UIView {
	/// Custom ID to use as refetence for the constraints, required to be unique. Defaults to class/type name.
	var id: ObjectIdentifier { get }

	/// The options for this stickyView, checkout StickyViewOptions for detailed information
	var options: ParallaxViewOptions { get }
	
	/// Called when the scroll changed and the view is not at the top or bottom most position, so it actually moved on screen
	/// - Parameter coordinator: A reference to the coordinator
	/// - Parameter event: The event, check ParallaxScrollEvent for more info
	func scrollChanged(_ coordinator: ParallaxViewCoordinator, event: ParallaxScrollEvent)
	
	/// Called when the views height is changed, this only gets called if the stickPosition != .none
	/// - Parameter coordinator: A reference to the coordinator
	/// - Parameter delta: The amount the view is resized; maxSize = 1.0 (e.g. 100% showing);  minSize = 0.0; so half way is 0.5
	func heightChanged(_ coordinator: ParallaxViewCoordinator, event: ParallaxHeightEvent)
}

// Set defaults
extension ParallaxView {
	public var id: ObjectIdentifier {
		return ObjectIdentifier(Self.self)
	}

	public func scrollChanged(_ coordinator: ParallaxViewCoordinator, event: ParallaxScrollEvent) {}
	public func heightChanged(_ coordinator: ParallaxViewCoordinator, event: ParallaxHeightEvent) {}
}
