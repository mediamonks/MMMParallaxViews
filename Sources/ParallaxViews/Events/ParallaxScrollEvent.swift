//
//  ParallaxScrollEvent.swift
//  ParallaxViews
//
//  Created by Erik Terwan on 11/02/2020.
//  Copyright © 2020 MediaMonks. All rights reserved.
//

import UIKit

public struct ParallaxScrollEvent {
	public enum Direction {
		case up, down, unknown
	}
	
	/// The position of the ParallaxView in the wrapper (0 = top, 0.5 = center, 1 = bottom)
	public var delta: CGFloat
	
	/// The direction the user is scrolling
	public var direction: Direction
}
