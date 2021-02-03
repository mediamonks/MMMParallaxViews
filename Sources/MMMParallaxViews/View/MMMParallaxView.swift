//
// MMMParallaxViews. Part of MMMTemple.
// Copyright (C) 2020-2021 MediaMonks. All rights reserved.
//

import UIKit

/// A view that can be placed over a Scroll/TableView that follows a certain point or cell. The height can be resized on scroll,
/// so you get a parallax effect; e.g. resize a header to be a sort-of navigation bar. Or resize a footer when the
/// bottom is reached to show more detailed information.
public protocol MMMParallaxView: AnyObject {

	/// Custom ID to use as reference for the constraints, required to be unique. Defaults to class/type name.
	@available(*, deprecated, message: "Not necessary anymore.")
	var id: ObjectIdentifier { get }

	/// The view whose position and size will be managed.
	var parallaxView: UIView { get }

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

/// Describes the view to be managed by `MMMParallaxViewCoordinator`.
/// (This is to not require managed views to conform to certain protocol.)
public class MMMParallaxViewDescriptor: MMMParallaxView {

	private var onDidUpdate: ((MMMParallaxUpdateEvent) -> Void)?

	public init(view: UIView, options: MMMParallaxViewOptions, onDidUpdate: ((MMMParallaxUpdateEvent) -> Void)? = nil) {
		self.parallaxView = view
		self.options = options
		self.onDidUpdate = onDidUpdate
	}

	public let parallaxView: UIView
	public let options: MMMParallaxViewOptions
	public func viewUpdated(_ coordinator: MMMParallaxViewCoordinator, event: MMMParallaxUpdateEvent) {
		onDidUpdate?(event)
	}
}

extension MMMParallaxView {

	public var id: ObjectIdentifier { ObjectIdentifier(self) }

	/// For compatibility with the existing code where parallax views have to conform to `MMMParallaxView`.
	public var parallaxView: UIView {
		guard let view = self as? UIView else {
			preconditionFailure()
		}
		return view
	}

	public func scrollChanged(_ coordinator: MMMParallaxViewCoordinator, event: MMMParallaxScrollEvent) {}
	public func heightChanged(_ coordinator: MMMParallaxViewCoordinator, event: MMMParallaxHeightEvent) {}
	
	public func viewUpdated(_ coordinator: MMMParallaxViewCoordinator, event: MMMParallaxUpdateEvent) {}
}
