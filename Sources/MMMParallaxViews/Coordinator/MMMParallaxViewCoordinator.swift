//
// MMMParallaxViews. Part of MMMTemple.
// Copyright (C) 2020-2021 MediaMonks. All rights reserved.
//

import UIKit

public class MMMParallaxViewCoordinator {

	private class ParallaxViewStorage {

		public private(set) weak var view: MMMParallaxView?
		
		public var topConstraint: NSLayoutConstraint?
		public var heightConstraint: NSLayoutConstraint?
		
		init(_ view: MMMParallaxView?) {
			self.view = view
		}
	}

	/// The ScrollView or TableView to attach to.
	public weak var scrollView: UIScrollView? {
		didSet {
			self.setUpListener()
			self.setUpViews()
		}
	}
	
	/// The `UIView` to add the `parallaxViews` to, usually the parentView of your `scrollView`.
	public weak var containerView: UIView? {
		didSet {
			self.setUpViews()
		}
	}

	/// If the Coordinator should adjust the `contentInset` of the scrollView to adjust for views
	/// sticking on top, this overrides your `contentInsets` so use with caution.
	///
	/// Say you have `UITableView` section titles, and a `ParallaxView` sticking to the top
	/// of the frame. By default the section titles will appear behind the `ParallaxView`. When
	/// setting this to true, we adjust the contentInsets of the `UITableView/UIScrollView` to
	/// the height of the `ParallaxView` so the section titles will stick to the bottom of the
	/// `ParallaxView`. As mentioned before, this will override any custom `contentInset` you have
	/// set. If you use custom `contentInsets`, calculate the insets by using the `topContentInset`
	/// and `bottomContentInset` instead.
	///
	/// Defaults to `false`.
	public var shouldAdjustContentInset: Bool = false

	/// The calculated top `contentInset`, calculated by getting the maximum 'min' height of the
	/// topmost view.
	///
	/// More info on this behaviour is documented at `shouldAdjustContentInset`.
	public private(set) var topContentInset: CGFloat = 0
	
	/// The calculated bottom `contentInset`, calculated by getting the maximum 'min' height of the
	/// bottommost view.
	///
	/// More info on this behaviour is documented at `shouldAdjustContentInset`.
	public private(set) var bottomContentInset: CGFloat = 0

	/// The priority that should be given to the height constraint, defaults to `.defaultHigh + 1` (751).
	/// Set this before assigning your `parallaxViews`.
	public var heightConstraintPriority: UILayoutPriority = .defaultHigh + 1

	/// The priority that should be given to the top constraint, defaults to `.required` (1000).
	/// Set this before assigning your `parallaxViews`.
	@available(*, deprecated, message: "We don't allow setting the top constraint priority.")
	public var topConstraintPriority: UILayoutPriority = .required

	/// Defines what happens when the user scrolls down past the scroll view's content ("bounces")
	/// and there is a parallax view tracking the top of the content (e.g. the first cell of a table view).
	///
	/// If `true` (default), then the parallax view that is tracking the top is stretched to fill the bounced space;
	/// if `false`, then the parallax view is following its target as usual.
	///
	/// Stretching is useful for a typical "sticky header" use case and was default behaviour in previous versions
	/// of the library hence on by default. However in case the bounced area is occupied by something else already,
	/// like a pull-to-refresh control, then it can be useful to disable the stretching.
	public var stretchTopViewWhenBouncing: Bool = true

	/// Same as `stretchTopViewWhenBouncing` but for the paralax view tracking the bottom of the content.
	public var stretchBottomViewWhenBouncing: Bool = true
	
	/// If the ParallaxViews should stick to the `safeAreaInsets`. Defaults to `true`.
	public var stickToSafeAreaInsets: Bool = true
	
	private var _parallaxViews: [ParallaxViewStorage] = []

	/// The parallaxViews to animate, these views will be placed in the `containerView` by the coordinator
	/// and animated according to the current scroll position.
	public var parallaxViews: [MMMParallaxView] {
		set {
			_parallaxViews.forEach { $0.view?.removeFromSuperview() }
			_parallaxViews = newValue.map { ParallaxViewStorage($0) }
			
			self.setUpViews()
		}
		get {
			return _parallaxViews.compactMap { $0.view }
		}
	}
	
	private var observer: NSKeyValueObservation?
	
	public init() {}
	
	public convenience init(
		scrollView: UIScrollView,
		containerView: UIView,
		parallaxViews: [MMMParallaxView]
	) {
		self.init()
		self.scrollView = scrollView
		self.containerView = containerView
		self.parallaxViews = parallaxViews
	}
	
	deinit {
		self.tearDownListener()
	}
	
	/// Call this method to recalculate the positions of the parallax views.
	public func recalculate() {
		if let scrollView = scrollView {
			// Ask for a recalculation by passing change = nil.
			contentOffsetDidChange(scrollView, change: nil)
		}
	}
	
	private func setUpListener() {
		// it's a weak ref, so fail silently if not found
		guard let scrollView = scrollView else { return }
		
		observer?.invalidate()
		observer = scrollView.observe(
			\.contentOffset,
			options: [.old, .new],
			changeHandler: contentOffsetDidChange
		)
	}
	
	private func tearDownListener() {
		observer?.invalidate()
	}
	
	private func setUpViews() {
		// weak refs, fail silently if not found
		guard let container = containerView else { return }
		
		let constraints = _parallaxViews.compactMap({ storage -> [NSLayoutConstraint]? in
			
			guard let view = storage.view else {
				return nil
			}
			
			view.translatesAutoresizingMaskIntoConstraints = false
			
			if !container.subviews.contains(view) {
				container.addSubview(view)
			}
			
			if storage.topConstraint != nil, storage.heightConstraint != nil {
				// View already setup w. constraints.
				return nil
			}
			
			let topConstraint = NSLayoutConstraint(item: view, attribute: .top,
				relatedBy: .equal, toItem: container, attribute: .top,
				multiplier: 1.0, constant: 0)
			topConstraint.priority = .required
			
			let heightConstraint = NSLayoutConstraint(item: view, attribute: .height,
				relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
				multiplier: 1.0, constant: 0)
			heightConstraint.priority = heightConstraintPriority
			
			storage.topConstraint = topConstraint
			storage.heightConstraint = heightConstraint
			
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

	/// Ideal (not clipped or extended) rect for this view in the coordinate system of the container view.
	private func trackingRect(
		view: MMMParallaxView,
		scrollView: UIScrollView,
		containerView: UIView
	) -> CGRect {

		let options = view.options

		switch options.type {

		case .scrollView(let y):
			let b = scrollView.bounds
			let r = CGRect(x: b.origin.x, y: y, width: b.size.width, height: options.height.max)
			return scrollView.convert(r, to: containerView)

		case .tableView(let indexPath):
			guard let tableView = scrollView as? UITableView else {
				preconditionFailure("Expected UITableView for a parallax view of \(options.type) type")
			}
			let r = tableView.rectForRow(at: indexPath)
			return tableView.convert(r, to: containerView)
		}
	}

	// TODO: is not this a good candidate for ranges?
	private func map(
		value: CGFloat,
		fromStart: CGFloat,
		fromStop: CGFloat,
		toStart: CGFloat,
		toStop: CGFloat,
		clampStart: Bool = true,
		clampStop: Bool = true
	) -> CGFloat {
	
		let d = fromStop - fromStart
//		assert(abs(d) > 0.1)
		let t = (value - fromStart) / d
		
		// Let's make sure it's clamped.
		if clampStart, t <= toStart {
			return toStart
		} else if clampStop, t >= toStop {
			return toStop
		}
		
		return toStart + (toStop - toStart) * t
	}
	
	private func contentOffsetDidChange(
		_ scrollView: UIScrollView,
		change: NSKeyValueObservedChange<CGPoint>?
	) {

		// Offset is observed, if the NSKeyValueObservedChange is nil, we ask for a
		// plain recalculation of the
		let newValue = change?.newValue ?? .zero
		let oldValue = change?.oldValue ?? .zero

		// When there is no change, lets fail silently if the user has set
		// shouldAdjustContentInset. This fixes an infinite loop issue that occured
		// sometimes on iPhone SE. However, this can get called with .zero and .zero
		// multiple times while AutoLayout is setting up the view. We basically need
		// the 'last' change event to setup the views properly, this is really hard
		// to detect.
		//
		// When the view isn't properly calculated when using shouldAdjustContentInset
		// you're able to call `.recalculate()` on the coordinator after Autolayout
		// finishes (e.g. in viewDidLayoutSubviews).
		
		// On recalulation always check for change.
		let recalculation = change == nil
		
		// Only check for change when shouldAdjustContentInset is false.
		let isChanged = newValue != oldValue || !shouldAdjustContentInset
		
		guard isChanged || recalculation else { return }
		
		guard let containerView = self.containerView else {
			// Feels odd that the container can disappear when scrolling is
			// reported, but it can actually happen as the scroll view can
			// change its contentOffset when it's being removed from the superview
			// as a result of deallocation of the container (which is typically
			// its parent).
			return
		}

		// Scroll view's content rect (without insets) in coordinates of the container.
		let contentRect = containerView.convert(
			CGRect(origin: .zero, size: scrollView.contentSize),
			from: scrollView
		)

		// A "viewport" is the part of the container where all sticky views
		// should stay in. This either matches the safe area or when stickToSafeAreaInsets
		// is set to false it uses the raw edges.
		let viewportRect = stickToSafeAreaInsets ?
			containerView.bounds.inset(by: containerView.safeAreaInsets) :
			containerView.bounds
		
		// With the current calculations, if not sticking to the safe area, the
		// calculated height will be too big. We use this to subtract top and
		// bottom accordingly.
		let safeAreaAdjustment = stickToSafeAreaInsets ? .zero : containerView.safeAreaInsets
		
		// These define the top (bottom) part of the viewport that is completely
		// covered by stick-to-top (stick-to-bottom) views without gaps between.
		//           ┌──────────────┐
		//  viewport╔╬══════════════╬╗
		//          ║│              │║
		//          ║├──────────────┤║
		//      top─▶└──────────────┘║
		//          ║                ║
		//          ╚      ...       ╝
		// We begin with the viewport's top/bottom and then update these when we
		// see views sticking out.
		var top = viewportRect.minY
		var bottom = viewportRect.maxY
		
		// These are similar to top/bottom but describe adjustmenets in
		// `contentInsets` that we might need to make (if were instructed to do so).
		var topInset = top
		var bottomInset = bottom

		// Let's go through all views and decide where they should be positioned now.
		do {

			// TODO: We assume here that the views are nicely sorted by the user,
			// which is not true and will show up as unexpected ordering when many
			// views with both sticky flags are involved.
			for storage in _parallaxViews {
				
				guard let view = storage.view else {
					// If we don't have a view to work with, skip.
					continue
				}
				
				// The rect where the view ideally should sit, container's coordinates.
				// (We don't care about left/right sides of this rect for now.)
				var r = self.trackingRect(view: view, scrollView: scrollView, containerView: containerView)

				let minHeight = view.options.height.min
				
				let shouldStickToTop = view.options.stickPosition.contains(.top)
				let shouldStickToBottom = view.options.stickPosition.contains(.bottom)
				
				// If it should stick to the top, then we cannot allow it to go
				// somewhere above the viewport.
				if shouldStickToTop {

					let prevTop = top
					
					if r.minY < top {
						let rawHeight = r.maxY - top - safeAreaAdjustment.top
						r.size.height = max(rawHeight, minHeight)
						r.origin.y = top
						top = r.maxY + safeAreaAdjustment.top
					} else if stretchTopViewWhenBouncing && r.minY <= contentRect.minY {
						r.size.height = r.maxY - viewportRect.minY - safeAreaAdjustment.top
						r.origin.y = viewportRect.minY
						top = r.maxY + safeAreaAdjustment.top
					}

					// We've just (possibly) updated `top`, so let's review the
					// corresponding inset.
					//
					// When the view slides into its topmost position in the container,
					// then the insets of the scroll view (if we have to adjust them)
					// should be below that view (to keep section headers of the
					// table view out of the way, for example).
					//
					//            ┌──────────────┐
					//   viewport╔╬══════════════╬╗
					//           ║│              │║
					//  topInset─▶└──────────────┘║
					//           ║                ║
					//           ║                ║
					//           ║      ...       ║
					//           ╚                ╝
					//
					// We could calculate this inset in advance using min height of
					// the view, but this would create unwanted extra space when the
					// user scrolls up.
					//
					//   viewport╔════════════════╗
					//           ║ unwanted space ║
					//  topInset─▶┌──────────────┐║
					//           ║│              │║
					//           ║│              │║
					//           ║└──────────────┘║
					//           ╚      ...       ╝
					//
					// Thus we are trying to animate the top inset here from 0 to
					// view's min height while it slides into the place. We could
					// be using the change of height from max to min as our cue
					// (time), but this would not work with views preferring to
					// stay the same.
					//
					// So instead let's use the distance from the final position
					// measured relative to min height part. (This is limited by
					// the distance the view can potentially move relative to the
					// viewport.)
					//             ╔╦──────────────╦╗
					//            ▶║└──────────────┘║
					//    distance│║                ║
					//      to top│║┌──────────────┐║
					//            ▶║├──────────────┤║
					//  min height│║│              │║
					//            ▶║└──────────────┘║
					//             ╚      ...       ╝
					let d = (r.maxY - minHeight) - prevTop
					let maxMovement = (r.maxY - minHeight) - contentRect.minY
					
					// Note there is an edge case when the topmost view has its
					// min height the same as max.
					if maxMovement > 1 {
						let start = min(minHeight, maxMovement)
						topInset += map(
							value: d,
							fromStart: start, fromStop: 0,
							toStart: 0, toStop: minHeight
						)
					}
				}

				// Same logic for bottom-sticking views.
				if shouldStickToBottom {
					
					let prevBottom = bottom
					if r.maxY > bottom {
						let rawHeight = bottom - r.minY - safeAreaAdjustment.bottom
						r.size.height = max(rawHeight, view.options.height.min)
						r.origin.y = bottom - r.size.height
						bottom = r.minY
					} else if stretchBottomViewWhenBouncing && r.maxY >= contentRect.maxY {
						r.size.height = viewportRect.maxY - r.minY - safeAreaAdjustment.bottom
						r.origin.y = bottom - r.size.height
						top = r.minY + safeAreaAdjustment.bottom
					}
					let d = prevBottom - (r.minY + minHeight)
					let maxMovement = contentRect.maxY - (r.minY + minHeight)
					
					if maxMovement > 1 {
						let start = min(minHeight, maxMovement)
						bottomInset += map(
							value: d,
							fromStart: start, fromStop: 0,
							toStart: 0, toStop: minHeight
						)
					}
				}

				// OK, figured the actual rect, can set the constraints.
				guard
					let topConstraint = storage.topConstraint,
					let heightConstraint = storage.heightConstraint
				else {
					preconditionFailure()
				}

				// TODO: do we need the old value? Could be shorter without it.
				// TODO: can we combine 2 events into one?
				// TODO: - remove oldValue since it's not used in the new callback.
				
				var didChange = false
				
				let oldTop = topConstraint.constant
				let newTop = r.minY
				
				let minTop = viewportRect.minY
				let maxTop = viewportRect.maxY
				
				let topProgress = map(
					value: newTop,
					fromStart: minTop, fromStop: maxTop,
					toStart: 0, toStop: 1
				)
				
				if oldTop != newTop {
					topConstraint.constant = newTop
					
					didChange = true
					// TODO: Remove on next release.
					let direction: MMMParallaxScrollEvent.Direction = oldValue.y > newValue.y ? .up : .down
					view.scrollChanged(self, event: .init(progress: topProgress, direction: direction))
				}

				// TODO: do we need the old value? Could be shorter without it.
				// TODO: do we need this event at all?
				// TODO: - remove oldValue since it's not used in the new callback.
				let heightProgress: CGFloat = {
					if view.options.height.max > minHeight {
						return map(
							value: r.size.height,
							fromStart: minHeight, fromStop: view.options.height.max,
							toStart: 0, toStop: 1,
							clampStart: true,
							clampStop: false
						)
					}
					return 1
				}()
				
				let oldHeight = heightConstraint.constant
				let newHeight: CGFloat = {
					if newTop <= minTop {
						// Sticking to top, add safe area if applicable.
						return r.size.height + safeAreaAdjustment.top
					} else if newTop >= maxTop {
						// Sticking to bottom, add safe area if applicable.
						return r.size.height + safeAreaAdjustment.bottom
					}
					
					return r.size.height
				}()
				
				if oldHeight != newHeight {
					heightConstraint.constant = newHeight
					didChange = true
					
					// TODO: Remove on next release.
					let event = MMMParallaxHeightEvent(progress: heightProgress, from: oldHeight, to: newHeight)
					view.heightChanged(self, event: event)
				}
				
				if didChange {
					let event = MMMParallaxUpdateEvent(
						heightProgress: heightProgress,
						newHeight: newHeight,
						topProgress: topProgress
					)
					
					view.viewUpdated(self, event: event)
				}
			}
		}
		
		// Sizes and positions of the views might depend on the scroll view insets,
		// so let's update them first (if we are supposed to do so).
		
		// So `topInset` and `bottomtopInset` define "safe" parts of the view relative to the container,
		// need to figure out how these "safe" parts would overlap the scroll view.

		// The safe area insets of the scroll view will be included into the final insets (`adjustedContentInset`),
		// so we should not count them here.
		let scrollViewRect = containerView.convert(
			scrollView.frame.inset(by: scrollView.safeAreaInsets),
			from: scrollView.superview
		)
		var inset = scrollView.contentInset
		inset.top = max(0, (topInset - scrollViewRect.minY).rounded())
		inset.bottom = max(0, (scrollViewRect.maxY - bottomInset).rounded())
		
		topContentInset = inset.top
		bottomContentInset = inset.bottom
		
		if shouldAdjustContentInset, scrollView.contentInset != inset {
			scrollView.contentInset = inset
		}
	}
}
