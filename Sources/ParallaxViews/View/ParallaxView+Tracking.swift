//
//  ParallaxView+Tracking.swift
//  ParallaxViews
//
//  Created by Erik Terwan on 11/02/2020.
//  Copyright © 2020 MediaMonks. All rights reserved.
//

import UIKit

extension ParallaxView {
	internal func track(in coordinator: ParallaxViewCoordinator, from oldValue: CGPoint, to newValue: CGPoint,
						constraints: ParallaxViewCoordinator.ConstraintSet, scrollView: UIScrollView)
	{
		// weak reference, so fail silently if not found
		guard let containerView = coordinator.containerView else { return }
	
		// Find the Y value, either by passed options or from the IndexPath
		let top = findYPos(for: scrollView, in: containerView)
		let frameHeight = containerView.frame.height
		
		switch options.stickPosition {
		case .both:
			constraints.top.constant = min(max(top, 0.0), frameHeight - options.height.min)
        case .top:
			constraints.top.constant = max(top, 0.0)
		case .bottom:
			constraints.top.constant = min(top, frameHeight - options.height.min)
		default:
			constraints.top.constant = top
		}
		
		let delta = mapValue(constraints.top.constant, fromStart: 0, fromStop: frameHeight, toStart: 0.0, toStop: 1.0)
		let direction: ParallaxScrollEvent.Direction = oldValue.y > newValue.y ? .up : .down
		
		scrollChanged(coordinator, event: .init(delta: delta, direction: direction))
		
		setHeight(top: top, scrollView: scrollView, with: coordinator, in: containerView, constraints: constraints)
	}
	
	private func setHeight(top: CGFloat, scrollView: UIScrollView, with coordinator: ParallaxViewCoordinator,
						   in containerView: UIView, constraints: ParallaxViewCoordinator.ConstraintSet)
	{
		// resizing is not supported when using 'none'
		guard options.stickPosition != .none else { return }
		
		let maxHeight = options.maxHeight(with: scrollView)
		let frameHeight = containerView.frame.height
		
		// if the top < 0, the cell is going out of bounds, then adjust height accordingly
		// otherwise set it to the maxHeight.
		var height = top < 0 ? max(maxHeight + top, options.height.min) : maxHeight
		
		// check if the element is sticky on the top of the frame
		let isTopMostItem = Int(constraints.top.constant) <= 0
		
		if scrollView.contentOffset.y < 0 && isTopMostItem {
			// user is pulling down
			let pullAmount = abs(scrollView.contentOffset.y)
			
			height += pullAmount
		}
		
		let absoluteScrollPosition = scrollView.contentOffset.y + containerView.frame.height
		
		if absoluteScrollPosition > scrollView.contentSize.height && !isTopMostItem {
			// user is pulling up
			let pullAmount = abs(scrollView.contentSize.height - scrollView.contentOffset.y - frameHeight)
			
			height += pullAmount
		}
		
		if constraints.height.constant != height {
			// only send events when the height has actually changed
			let delta = mapValue(height, fromStart: maxHeight, fromStop: options.height.min, toStart: 1.0, toStop: 0.0)
			let event = ParallaxHeightEvent(delta: delta, from: constraints.height.constant, to: height)
			
			constraints.height.constant = height
			
			heightChanged(coordinator, event: event)
		}
	}
	
	private func findYPos(for scrollView: UIScrollView, in containerView: UIView) -> CGFloat {
		switch options.type {
		case .scrollView(let yReference):
			// Add the negative contentOffset for bounce effect
			let y = yReference - scrollView.contentOffset.y
			
			return y + min(scrollView.contentOffset.y, 0.0)
		case .tableView(let indexPath):
			guard case let tableView as UITableView = scrollView else {
				preconditionFailure("The provided scrollView is not a UITableView and the ParallaxOptions.Type is set to .tableView")
			}
			
			let tableRect = tableView.rectForRow(at: indexPath)
			let y = tableView.convert(tableRect, to: containerView).origin.y
			
			// Add the negative contentOffset for bounce effect
			return y + min(scrollView.contentOffset.y, 0.0)
		}
	}
	
	private func mapValue(_ value: CGFloat, fromStart: CGFloat, fromStop: CGFloat, toStart: CGFloat, toStop: CGFloat) -> CGFloat {
		return toStart + (toStop - toStart) * ((value - fromStart) / (fromStop - fromStart))
	}
}
