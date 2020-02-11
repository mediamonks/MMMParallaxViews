//
//  ParallaxHeightEvent.swift
//  ParallaxViews
//
//  Created by Erik Terwan on 11/02/2020.
//  Copyright © 2020 MediaMonks. All rights reserved.
//

import UIKit

public struct ParallaxHeightEvent {
	/// The amount the view is resized; maxSize = 1.0 (e.g. 100% showing);  minSize = 0.0; so half way is 0.5
	public var delta: CGFloat
	
	/// Resized from
	public var from: CGFloat
	
	/// Resized to
	public var to: CGFloat
}
