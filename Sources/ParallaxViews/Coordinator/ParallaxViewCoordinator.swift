//
//  ParallaxViewCoordinator.swift
//  ParallaxViews
//
//  Created by Erik Terwan on 11/02/2020.
//  Copyright © 2020 MediaMonks. All rights reserved.
//

import UIKit

public class ParallaxViewCoordinator {
	private class WeakParallaxView {
		private(set) weak var value: ParallaxView?

		init(_ value: ParallaxView?) {
			self.value = value
		}
	}
	
	/// The ScrollView or TableView to attach to
	public weak var scrollView: UIScrollView? {
		didSet {
			self.setUpListener()
			self.setUpViews()
		}
	}
	
	/// The UIView to add the parallaxViews to, usually the parentView of your scrollView
	public weak var containerView: UIView? {
		didSet {
			self.setUpViews()
		}
	}
	
	private var _parallaxViews: [WeakParallaxView] = []
	
	/// The parallaxViews to animate
	public var parallaxViews: [ParallaxView] {
		set {
			_parallaxViews.forEach { $0.value?.removeFromSuperview() }
			constraintsById = [:]
			
			var currentIDs: [ObjectIdentifier] = []

			_parallaxViews = newValue.map { view in
				let id = view.id
				
				guard !currentIDs.contains(id) else {
					preconditionFailure("Make sure to assign unique IDs to your ParallaxViews when using multiple views of the same class. E.g. override the `var id: ObjectIdentifier { return ObjectIdentifier(self) }`")
				}
				
				currentIDs.append(id)
				
				return WeakParallaxView(view)
			}
			
			self.setUpViews()
		}
		get {
			return _parallaxViews.compactMap { $0.value }
		}
	}
	
	internal typealias ConstraintSet = (top: NSLayoutConstraint, height: NSLayoutConstraint)

	private var constraintsById: [ObjectIdentifier: ConstraintSet] = [:]
	private var observer: NSKeyValueObservation?
	
	convenience init(scrollView: UIScrollView, containerView: UIView, parallaxViews: [ParallaxView]) {
		self.init()
		self.scrollView = scrollView
		self.containerView = containerView
		self.parallaxViews = parallaxViews
	}
	
	deinit {
		self.tearDownListener()
	}
	
	private func setUpListener() {
		// it's a weak ref, so fail silently if not found
		guard let scrollView = scrollView else { return }
		
		observer?.invalidate()
		observer = scrollView.observe(\.contentOffset, options: [.old, .new], changeHandler: scrollViewDidScroll)
	}
	
	private func tearDownListener() {
		observer?.invalidate()
	}
	
	private func setUpViews() {
		// weak refs, fail silently if not found
		guard let container = containerView else { return }
		guard let scrollView = scrollView else { return }
		
		let constraints = parallaxViews.compactMap({ view -> [NSLayoutConstraint]? in
			view.translatesAutoresizingMaskIntoConstraints = false
			
			if !container.subviews.contains(view) {
				container.addSubview(view)
			}
			
			let height = view.options.maxHeight(with: scrollView)
			
			if let constraints = constraintsById[view.id] {
				constraints.height.constant = height
				
				return nil
			}
			
			let topConstraint = NSLayoutConstraint(item: view, attribute: .top,
				relatedBy: .equal, toItem: container, attribute: .top,
				multiplier: 1.0, constant: 0)
			
			let heightConstraint = NSLayoutConstraint(item: view, attribute: .height,
				relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
				multiplier: 1.0, constant: height)
			
			constraintsById[view.id] = (topConstraint, heightConstraint)
			
			let horizontalConstraints = NSLayoutConstraint.constraints(
				withVisualFormat: "H:|[view]|",
				options: [], metrics: nil,
				views: ["view": view]
			)
			
			return [topConstraint, heightConstraint] + horizontalConstraints
		}).reduce([]) { (result, constraints) -> [NSLayoutConstraint] in
			return result + constraints
		}
		
		NSLayoutConstraint.activate(constraints)
	}
	
	private func scrollViewDidScroll(_ scrollView: UIScrollView, change: NSKeyValueObservedChange<CGPoint>) {
		// offset is observed, if the NSKeyValueObservedChange is nil, the user probably didn't scroll,
		// fail silently
		guard let newValue = change.newValue else { return }
		
		let oldValue = change.oldValue ?? .zero
		
		parallaxViews.forEach { view in
			/// View is not initialized properly yet
			guard let constraints = constraintsById[view.id] else { return }
			
			view.track(in: self, from: oldValue, to: newValue, constraints: constraints, scrollView: scrollView)
		}
	}
}
