//
// MMMParallaxViews. Part of MMMTemple.
// Copyright (C) 2020-2021 MediaMonks. All rights reserved.
//

import UIKit

public struct MMMParallaxScrollEvent {

	public enum Direction {
		case up, down, unknown
	}

	// TODO: the comment on 0, 0.5, 1 does not seem to be correct.
	/// The position of the ParallaxView in the wrapper (0 = top, 0.5 = center, 1 = bottom)
	public var progress: CGFloat
	
	/// The direction the user is scrolling
	public var direction: Direction
}
