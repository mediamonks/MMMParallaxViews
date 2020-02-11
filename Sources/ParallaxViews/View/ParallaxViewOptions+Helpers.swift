//
//  ParallaxViewOptions+Helpers.swift
//  ParallaxViews
//
//  Created by Erik Terwan on 11/02/2020.
//  Copyright © 2020 MediaMonks. All rights reserved.
//

import UIKit

extension ParallaxViewOptions {
	/// The provided IndexPath, if type == .tableView
	internal var followIndex: IndexPath? {
		switch type {
		case .tableView(let indexPath):
			return indexPath
		default:
			return nil
		}
	}
	
	/// The maxHeight, when the container is a TableView and the type is a tableView, calculate the height for row
	internal func maxHeight(with scrollView: UIScrollView) -> CGFloat {
		switch type {
		case .scrollView:
			return height.max
		case .tableView(let indexPath):
			guard case let tableView as UITableView = scrollView else {
				return height.max
			}
			
			guard height.max == UITableView.automaticDimension else {
				return height.max
			}
			
			return tableView.delegate?.tableView?(tableView, heightForRowAt: indexPath) ?? height.max
		}
	}
}
