//
// MMMParallaxViews. Part of MMMTemple.
// Copyright (C) 2020-2021 MediaMonks. All rights reserved.
//

import UIKit

public class MMMParallaxViewCoordinator {

	/// A record with extra info we keep for each parallax view being managed.
	private class ParallaxViewRecord {

		public private(set) weak var descriptor: MMMParallaxView?

		public private(set) weak var view: UIView?

		/// `true`, if the view was added into the container by us.
		/// This is to not accidentally remove views added by the user code.
		public var hasAddedView: Bool = false
		
		public var topConstraint: NSLayoutConstraint?
		public var heightConstraint: NSLayoutConstraint?
		
		init(_ descriptor: MMMParallaxView) {
			self.descriptor = descriptor
			self.view = descriptor.parallaxView
		}

		public func minHeight(width: CGFloat, verticalFittingPriority: UILayoutPriority) -> CGFloat {

			guard let descriptor = descriptor, let view = view else {
				assertionFailure()
				return 0
			}

			switch descriptor.options.height {
			case let .fixed(min, _):
				return min
			case .dynamic:
				heightConstraint?.isActive = false
				let min = view.systemLayoutSizeFitting(
					CGSize(width: width, height: 0),
					withHorizontalFittingPriority: .required,
					verticalFittingPriority: verticalFittingPriority
				).height.rounded(.up)
				heightConstraint?.isActive = true
				return min
			}
		}

		public func maxHeight(width: CGFloat) -> CGFloat {

			guard let descriptor = descriptor, let view = view else {
				assertionFailure()
				return 0
			}

			switch descriptor.options.height {
			case let .fixed(_, max):
				return max
			case .dynamic:
				heightConstraint?.isActive = false
				let max = view.systemLayoutSizeFitting(
					CGSize(width: width, height: 0),
					withHorizontalFittingPriority: .required,
					verticalFittingPriority: .fittingSizeLevel
				).height.rounded(.up)
				heightConstraint?.isActive = true
				return max
			}
		}
	}

	/// The scroll or table view to coordinate "parallax views" for.
	public weak var scrollView: UIScrollView? {
		didSet {
			setUpListener()
			setUpViews()
		}
	}
	
	/// The `UIView` to add the `parallaxViews` to, usually the parentView of your `scrollView`.
	public weak var containerView: UIView? {
		didSet {
			setUpViews()
		}
	}

	/// `true` if the receiver should adjust `contentInset` of the table or scroll view to compensate
	/// for the views sticking to the top or bottom. `false` by default.
	///
	/// Let say your `UITableView` has section titles and a "parallax view" sticking to the top.
	/// By default the titles are going to appear behind the parallax view because the table view is unaware
	/// of the parallax view overlapping it. When this flag is set to `true` however, the the coordinator
	/// is going to adjust `contentInset` so the titles will stick to the bottom of the parallax view.
	///
	/// If you are adjusting `contentInsets` yourself, then you might want to take `topContentInset`
	/// and `bottomContentInset` into account.
	///
	/// - Note: We don't perform updates in `contentInset` when the table view is bouncing because this would
	/// interfere with the process in case the content view is small enough.
	public var shouldAdjustContentInset: Bool = false

	public private(set) var topContentInset: CGFloat = 0
	
	public private(set) var bottomContentInset: CGFloat = 0

	/// The priority of the parallax view height constraint. By default `.defaultHigh + 1` (751).
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

	/// Same as `stretchTopViewWhenBouncing` but for the parallax view tracking the bottom of the content.
	public var stretchBottomViewWhenBouncing: Bool = true
	
	/// `true` if `safeAreaInsets` of the container should be taken into account when sticking the parallax views.
	/// (`true` by default.)
	public var stickToSafeAreaInsets: Bool = true
	
	private var _parallaxViews: [ParallaxViewRecord] = []

	/// The "parallax views" that should be managed by the coordinator.
	public var parallaxViews: [MMMParallaxView] {
		set {
			_parallaxViews.forEach { record in
				record.heightConstraint?.isActive = false
				record.topConstraint?.isActive = false
				if record.hasAddedView {
					record.view?.removeFromSuperview()
				}
			}
			_parallaxViews = newValue.map { ParallaxViewRecord($0) }
			setUpViews()
		}
		get {
			return _parallaxViews.compactMap { $0.descriptor }
		}
	}

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
		setUpListener()
	}
	
	deinit {
		tearDownListener()
	}
	
	/// Call this method to recalculate the positions of the parallax views.
	public func recalculate() {
		_recalculate()
	}

	private var contentOffsetChangeToken: NSKeyValueObservation?

	private func setUpListener() {
		// it's a weak ref, so fail silently if not found
		guard let scrollView = scrollView else { return }
		
		contentOffsetChangeToken?.invalidate()
		contentOffsetChangeToken = scrollView.observe(
			\.contentOffset,
			options: [.old, .new],
			changeHandler: contentOffsetDidChange
		)
	}
	
	private func tearDownListener() {
		contentOffsetChangeToken?.invalidate()
	}
	
	private func setUpViews() {

		// weak refs, fail silently if not found
		guard let container = containerView else { return }
		
		let constraints = _parallaxViews.compactMap({ record -> [NSLayoutConstraint]? in
			
			guard let view = record.view else {
				return nil
			}
			
			view.translatesAutoresizingMaskIntoConstraints = false
			
			if !container.subviews.contains(view) {
				container.addSubview(view)
				record.hasAddedView = true
			}
			
			if record.topConstraint != nil, record.heightConstraint != nil {
				// View already set up w. constraints.
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
			
			record.topConstraint = topConstraint
			record.heightConstraint = heightConstraint
			
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

	/// Ideal rect (that is not clipped or extended) for this view in the coordinate system of the container view.
	private func trackingRect(
		descriptor: MMMParallaxView,
		scrollView: UIScrollView,
		containerView: UIView,
		maxHeight: CGFloat
	) -> CGRect {

		let options = descriptor.options

		switch options.type {

		case .scrollView(let y):
			let b = scrollView.bounds
			let r = CGRect(x: b.origin.x, y: y, width: b.size.width, height: maxHeight)
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

	private func contentOffsetDidChange(_ scrollView: UIScrollView, change: NSKeyValueObservedChange<CGPoint>) {

		guard change.newValue != change.oldValue else {
			return
		}

		// TODO: oldValue should be removed on the next breaking update
		_recalculate(oldValue: change.oldValue ?? .zero)
	}

	private var skipRecalculateCall: Int = 0
	private var contentOffsetYToIgnore: CGFloat?

	private func _recalculate(oldValue: CGPoint = .zero) {

		// We want to be able to temporarily disable recalculations when the changes are caused by us.
		guard skipRecalculateCall == 0 else { return }

		guard let containerView = self.containerView, let scrollView = self.scrollView  else {
			// It might seem odd that the container can disappear when scrolling is reported,
			// but it can actually happen: the scroll view can change its `contentOffset` while it's being
			// removed from the superview due to deallocation of the container (which is typically its parent).
			return
		}

		// Scroll view's content rect (without insets) in coordinates of the container.
		let contentRect = containerView.convert(
			CGRect(origin: .zero, size: scrollView.contentSize),
			from: scrollView
		)

		// A "viewport" is the part of the container where all sticky views should stay in.
		// This either matches the safe area or bounds (when `stickToSafeAreaInsets` is `false`).
		let viewportRect = stickToSafeAreaInsets
			? containerView.bounds.inset(by: containerView.safeAreaInsets)
			: containerView.bounds
		
		// With the current calculations, if not sticking to the safe area, the calculated height will be too big.
		// We use this to subtract top and bottom accordingly.
		let safeAreaAdjustment = stickToSafeAreaInsets ? .zero : containerView.safeAreaInsets
		
		// These define the top (bottom) part of the viewport that is completely covered by stick-to-top
		// (stick-to-bottom) views without gaps in-between.
		//           ┌──────────────┐
		//  viewport╔╬══════════════╬╗
		//          ║│              │║
		//          ║├──────────────┤║
		//      top─▶└──────────────┘║
		//          ║                ║
		//          ╚      ...       ╝
		// We begin with the viewport's top/bottom and then update these when we see views sticking out.
		var top = viewportRect.minY
		var bottom = viewportRect.maxY
		
		// These are similar to top/bottom but describe adjustments in `contentInsets` that we might need to make
		// (if we were instructed to do so).
		var topInset = top
		var bottomInset = bottom

		let contentOffsetY = scrollView.contentOffset.y

		// Let's go through all views and decide where they should be positioned now.
		do {

			// TODO: We assume here that the views are nicely sorted by the user,
			// which is not true and will show up as unexpected ordering when many
			// views with both sticky flags are involved.
			for storage in _parallaxViews {
				
				guard let descriptor = storage.descriptor else {
					// If we don't have a view to work with, skip.
					continue
				}

				let minHeight = storage.minHeight(width: viewportRect.width, verticalFittingPriority: heightConstraintPriority)
				let maxHeight = storage.maxHeight(width: viewportRect.width)

				// The rect where the view ideally should sit, container's coordinates.
				// (We don't care about left/right sides of this rect for now.)
				var r = trackingRect(descriptor: descriptor, scrollView: scrollView, containerView: containerView, maxHeight: maxHeight)

				let shouldStickToTop = descriptor.options.stickPosition.contains(.top)
				let shouldStickToBottom = descriptor.options.stickPosition.contains(.bottom)
				
				// If it should stick to the top, then we cannot allow it to go somewhere above the viewport.
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

					// We've just (possibly) updated `top`, so let's review the corresponding inset.
					//
					// When the view slides into its topmost position in the container, then the insets of
					// the scroll view (if we have to adjust them) should be below that view (to keep section
					// headers of the table view out of the way, for example).
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
					// We could calculate this inset in advance using min height of the view, but this would
					// create unwanted extra space when the user scrolls up.
					//
					//   viewport╔════════════════╗
					//           ║ unwanted space ║
					//  topInset─▶┌──────────────┐║
					//           ║│              │║
					//           ║│              │║
					//           ║└──────────────┘║
					//           ╚      ...       ╝
					//
					// Thus we are trying to animate the top inset here from 0 to view's min height while it
					// slides into the place. We could be using the change of height from max to min as our cue
					// (time), but this would not work with views preferring to stay the same.
					//
					// So instead let's use the distance from the final position measured relative to min
					// height part. (This is limited by the distance the view can potentially move relative
					// to the viewport.)
					//
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
						r.size.height = max(rawHeight, minHeight)
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
					let direction: MMMParallaxScrollEvent.Direction = oldValue.y > contentOffsetY ? .up : .down
					descriptor.scrollChanged(self, event: .init(progress: topProgress, direction: direction))
				}

				// TODO: do we need the old value? Could be shorter without it.
				// TODO: do we need this event at all?
				// TODO: - remove oldValue since it's not used in the new callback.
				let heightProgress: CGFloat = {
					if maxHeight > minHeight {
						return map(
							value: r.size.height,
							fromStart: minHeight, fromStop: maxHeight,
							toStart: 0, toStop: 1,
							clampStart: true,
							clampStop: false
						)
					} else {
						return 1
					}
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
					descriptor.heightChanged(self, event: event)
				}
				
				if didChange {
					let event = MMMParallaxUpdateEvent(
						heightProgress: heightProgress,
						newHeight: newHeight,
						topProgress: topProgress
					)
					
					descriptor.viewUpdated(self, event: event)
				}
			}
		}

		// So `topContentInset` and `bottomContentInset` define "safe" parts of the view relative to the container,
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

		guard shouldAdjustContentInset, scrollView.contentInset != inset else {
			// No need to update contentInset, we are done.
			return
		}

		// In certain cases (when doing layout or implicit offset animations it seems) a table view
		// would adjust `contentOffset` in response to our changes in `contentInset` which can cause a loop of
		// updates eventually resulting in a crash.
		// Unfortunately we cannot yet easily distinguish when this is happening and thus this silly workaround
		// where we try to predict how it might compensate `contentOffset` and would ignore the corresponding
		// offset in this case.
		guard contentOffsetYToIgnore.map({ abs($0 - contentOffsetY) > 0.01 }) ?? true else {
			contentOffsetYToIgnore = nil
			return
		}
		contentOffsetYToIgnore = contentOffsetY - inset.top

		// Unfortunately we cannot update content insets on table views when bouncing happens either.
		// When we are trying to do so, then the table view updates its content offset in response
		// which prevents bouncing from working correctly. Fortunately it's also harder to notice that the insets
		// are not updated in this case, so disabling updates is an acceptable workaround for now.
		let isBouncing: Bool = {
			guard scrollView.isDragging || scrollView.isDecelerating else {
				return false
			}
			let contentRect = scrollView.convert(
				CGRect(origin: .zero, size: scrollView.contentSize),
				from: scrollView
			)
			let viewportRect = scrollView.bounds.inset(by: scrollView.adjustedContentInset)
			return viewportRect.minY < contentRect.minY || contentRect.maxY < viewportRect.maxY
		}()
		guard !isBouncing else {
			return
		}

		skipRecalculateCall += 1
		scrollView.contentInset = inset
		skipRecalculateCall -= 1
	}

	/// Descriptor of a parallax view that is following a cell with the given index path, if any.
	public func viewForRowAt(indexPath: IndexPath) -> MMMParallaxView? {
		// TODO: perhaps moving followIndex from the extension would make it more readable here
		return parallaxViews.first { $0.options.followIndex == indexPath }
	}

	/// The height of a proxy cell in your table view to match the maximum height of a parallax view
	/// corresponding to the given index path; or `UITableView.automaticDimension`, if there is no parallax
	/// view following a cell with the given index path.
	///
	/// You can use this in your table view delegate to make sure that the size of the proxy cell that
	/// the parallax view is going to follow matches the maximum height of the view according to its settings.
	public func heightForRowAt(indexPath: IndexPath) -> CGFloat {
		guard let record = _parallaxViews.first(where: { $0.descriptor?.options.followIndex == indexPath }) else {
			return UITableView.automaticDimension
		}
		guard let containerView = self.containerView else {
			assertionFailure("Cannot use \(#function) when the container view has gone or was not set")
			return UITableView.automaticDimension
		}
		return record.maxHeight(width: containerView.bounds.size.width)
	}

	/// The height for a proxy cell in your table view or a proxy view in your scroll view to match the maximum
	/// height of the parallax view corresponding to the given descriptor.
	///
	/// (This is the version of `heightForRowAt(indexPath:)` that works with scroll views as well.)
	///
	/// Note that the height is not static for the parallax views using dynamic sizing.
	public func maxHeightForView(_ descriptor: MMMParallaxView) -> CGFloat {
		guard let record = _parallaxViews.first(where: { $0.descriptor === descriptor }) else {
			assertionFailure("\(#function) only works with descriptors/views in its `parallaxViews` property")
			return 0
		}
		guard let containerView = self.containerView else {
			assertionFailure("Cannot use \(#function) when the container view has gone or was not set")
			return 0
		}
		return record.maxHeight(width: containerView.bounds.size.width)
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
