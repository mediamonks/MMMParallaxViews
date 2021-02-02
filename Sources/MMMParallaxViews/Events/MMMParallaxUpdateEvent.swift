//
// MMMParallaxViews. Part of MMMTemple.
// Copyright (C) 2020-2021 MediaMonks. All rights reserved.
//

import Foundation
import UIKit

public struct MMMParallaxUpdateEvent {
	
	/// The amount the view is resized; maxSize = 1.0 (e.g. 100% showing);  minSize = 0.0; so half way is 0.5
	public var heightProgress: CGFloat
	
	/// The new height of the parallax view.
	public var newHeight: CGFloat
	
	/// The position of the view in the `containerView`; 0 = top, 0.5 = half on screen, 1 = bottom.
	public var topProgress: CGFloat
}
