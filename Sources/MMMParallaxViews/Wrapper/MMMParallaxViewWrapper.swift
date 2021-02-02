//
// MMMParallaxViews. Part of MMMTemple.
// Copyright (C) 2020-2021 MediaMonks. All rights reserved.
//


import UIKit

// TODO: document why it might be useful.
public class MMMParallaxViewWrapper: UIView {
	
	public let coordinator = MMMParallaxViewCoordinator()
	
	public var scrollView: UIScrollView? {
		get {
			return coordinator.scrollView
		}
		set {
			coordinator.scrollView = newValue
			
			setView(newValue)
		}
	}
	
	public var tableView: UITableView? {
		get {
			return coordinator.scrollView as? UITableView
		}
		set {
			coordinator.scrollView = newValue
			
			setView(newValue)
		}
	}
	
	public var parallaxViews: [MMMParallaxView] {
		get {
			return coordinator.parallaxViews
		}
		set {
			coordinator.parallaxViews = newValue
		}
	}
	
	public convenience init(scrollView: UIScrollView, parallaxViews: [MMMParallaxView]) {
		self.init()
		
		self.scrollView = scrollView
		self.parallaxViews = parallaxViews
		self.coordinator.containerView = self
	}
	
	public convenience init(tableView: UITableView, parallaxViews: [MMMParallaxView]) {
		self.init()
		
		self.scrollView = tableView
		self.parallaxViews = parallaxViews
		self.coordinator.containerView = self
	}
	
	override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		return coordinator.hitTest(for: super.hitTest(point, with: event))
	}
	
	private func setView(_ scrollView: UIScrollView?) {
		guard let scrollView = scrollView else {
			// view set to nil, remove all subviews
			for v in subviews {
				v.removeFromSuperview()
			}
			
			return
		}

		scrollView.translatesAutoresizingMaskIntoConstraints = false
		
		addSubview(scrollView)
		
		let viewDict = ["scrollView": scrollView]
		
		NSLayoutConstraint.activate(
			NSLayoutConstraint.constraints(
				withVisualFormat: "V:|[scrollView]|",
				options: [], metrics: nil,
				views: viewDict
			) + NSLayoutConstraint.constraints(
				withVisualFormat: "H:|[scrollView]|",
				options: [], metrics: nil,
				views: viewDict
			)
		)
	}
	
}
