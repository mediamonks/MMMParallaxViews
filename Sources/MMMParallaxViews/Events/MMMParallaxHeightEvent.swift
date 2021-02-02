//
// MMMParallaxViews. Part of MMMTemple.
// Copyright (C) 2020-2021 MediaMonks. All rights reserved.
//

import UIKit

public struct MMMParallaxHeightEvent {

	/// The amount the view is resized; maxSize = 1.0 (e.g. 100% showing);  minSize = 0.0; so half way is 0.5
	public var progress: CGFloat

	// TOOD: Is it important to know the previous value?
	/// Resized from
	public var from: CGFloat
	
	/// Resized to
	public var to: CGFloat
}
