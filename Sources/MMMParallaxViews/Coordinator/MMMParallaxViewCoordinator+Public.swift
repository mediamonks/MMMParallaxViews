//
// MMMParallaxViews. Part of MMMTemple.
// Copyright (C) 2020-2021 MediaMonks. All rights reserved.
//

import UIKit

extension MMMParallaxViewCoordinator {

	/// Returns the ParallaxView for a certain IndexPath
	/// - Parameter indexPath: The indexPath the parallaxView is following
	public func viewForRowAt(indexPath: IndexPath) -> MMMParallaxView? {
		// TODO: perhaps moving followIndex from the extension would make it more readable here
		return parallaxViews.first { $0.options.followIndex == indexPath }
	}
	
	/// Returns the maxHeight for a certain IndexPath, useful for the TableView's heightForRowAt.. dataSource method
	/// - Parameter indexPath: The indexPath the parallaxView is following
	public func heightForRowAt(indexPath: IndexPath) -> CGFloat {

		guard let view = viewForRowAt(indexPath: indexPath) else {
			// The view is not managed by us,
			return UITableView.automaticDimension
		}
		
		return view.options.height.max
	}

	// TODO: clarify this
	/// hitTest helper method, call super.hitTest and pass that view here. Override this in your viewController / container when
	/// not using the wrapper.
	/// - Parameter view: The view supplied by super.hitTest(...)
	public func hitTest(for view: UIView?) -> UIView? {
		guard case let parallaxView as MMMParallaxView = view else { return view }
		
		return parallaxView.options.forwardsTouches ? scrollView : view
	}
}
