//
//  ParallaxViewCoordinator+Public.swift
//  ParallaxViews
//
//  Created by Erik Terwan on 11/02/2020.
//  Copyright © 2020 MediaMonks. All rights reserved.
//

import UIKit

extension ParallaxViewCoordinator {
	/// Returns the ParallaxView for a certain IndexPath
	/// - Parameter indexPath: The indexPath the parallaxView is following
	public func viewForRowAt(indexPath: IndexPath) -> ParallaxView? {
		return parallaxViews.first { $0.options.followIndex == indexPath }
	}
	
	/// Returns the maxHeight for a certain IndexPath, useful for the TableView's heightForRowAt.. dataSource method
	/// - Parameter indexPath: The indexPath the parallaxView is following
	public func heightForRowAt(indexPath: IndexPath) -> CGFloat {
		guard let view = viewForRowAt(indexPath: indexPath) else {
			return UITableView.automaticDimension
		}
		
		return view.options.height.max
	}

	/// hitTest helper method, call super.hitTest and pass that view here. Override this in your viewController / container when
	/// not using the wrapper.
	/// - Parameter view: The view supplied by super.hitTest(...)
	public func hitTest(for view: UIView?) -> UIView? {
		guard case let parallaxView as ParallaxView = view else { return view }
		
		return parallaxView.options.forwardsTouches ? scrollView : view
	}
}
