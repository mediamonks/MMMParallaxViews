//
//  ScrollViewController.swift
//  ParallaxViews
//
//  Created by Erik Terwan on 10/02/2020.
//  Copyright © 2020 MediaMonks. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController {
	class Sticky: UIView, ParallaxView {
		var options = ParallaxViewOptions(
			height: .init(min: 44, max: 220),
			type: .scrollView(y: 0)
		)
		
		var id: ObjectIdentifier {
			return ObjectIdentifier(self)
		}
		
		override init(frame: CGRect) {
			super.init(frame: frame)
			
			backgroundColor = .red
		}
		
		required init?(coder: NSCoder) {
			super.init(coder: coder)
			
			backgroundColor = .red
		}
	}
	
	class View: UIView {
		weak var coordinator: ParallaxViewCoordinator?
		
		// When not using the wrapper, and you want to be able to touch the parallax views
		// to scroll (e.g. make use of the forwardsTouches option), you should override the hitTest
		override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
			return coordinator?.hitTest(for: super.hitTest(point, with: event))
		}
	}
	
	let scrollView = UIScrollView(frame: .zero)
	let header = Sticky()
	let center = Sticky()
	let footer = Sticky()
	
	let coordinator = ParallaxViewCoordinator()
	
	override func loadView() {
		let view = View()
		view.coordinator = coordinator
		
        self.view = view
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(scrollView)
		
		let viewDict = ["wrapper": scrollView]
		
		NSLayoutConstraint.activate(
			NSLayoutConstraint.constraints(
				withVisualFormat: "V:|[wrapper]|",
				options: [], metrics: nil,
				views: viewDict
			) + NSLayoutConstraint.constraints(
				withVisualFormat: "H:|[wrapper]|",
				options: [], metrics: nil,
				views: viewDict
			)
		)
		
		footer.backgroundColor = .blue
		footer.options.type = .scrollView(y: 2000 - 120)
		footer.options.height = .init(min: 44, max: 120)
		
		center.backgroundColor = .init(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.5)
		center.options.type = .scrollView(y: 1000)
		center.options.height = .init(min: 40, max: 40)
		center.options.stickPosition = .none
		
		scrollView.showsVerticalScrollIndicator = true
		scrollView.contentSize = .init(width: view.frame.size.width, height: 2000)
		scrollView.backgroundColor = .gray
		
		coordinator.scrollView = scrollView
		coordinator.parallaxViews = [header, center, footer]
		coordinator.containerView = self.view
	}
	
	
}
