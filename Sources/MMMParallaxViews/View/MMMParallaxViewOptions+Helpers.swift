//
// MMMParallaxViews. Part of MMMTemple.
// Copyright (C) 2020-2021 MediaMonks. All rights reserved.
//

import UIKit

extension MMMParallaxViewOptions {

	/// The provided IndexPath, if type == .tableView
	internal var followIndex: IndexPath? {
		switch type {
		case .tableView(let indexPath):
			return indexPath
		default:
			return nil
		}
	}
}
