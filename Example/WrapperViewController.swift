//
// MMMParallaxViews. Part of MMMTemple.
// Copyright (C) 2020-2021 MediaMonks. All rights reserved.
//

import MMMParallaxViews
import UIKit

class WrapperViewController: UIViewController {

	class Sticky: UIView, MMMParallaxView {
		
		var options = MMMParallaxViewOptions(
			height: .init(min: 40, max: 40),
			type: .scrollView(y: 0)
		)
		
		private let label = UILabel(frame: .zero)
		
		init(automatic: Bool = false) {
			super.init(frame: .zero)
			
			translatesAutoresizingMaskIntoConstraints = false
			backgroundColor = .systemPink
			
			if automatic {
				let maxHeight = heightAnchor.constraint(equalToConstant: 250)
				maxHeight.priority = .defaultHigh
				
				let minHeight = heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
				minHeight.priority = .required
				
				NSLayoutConstraint.activate([maxHeight, minHeight])
			}
			
			label.translatesAutoresizingMaskIntoConstraints = false
			label.textAlignment = .center
			addSubview(label)
			
			label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
			label.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
			label.topAnchor.constraint(equalTo: topAnchor).isActive = true
			label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		}
		
		@available(*, unavailable)
		required init?(coder: NSCoder) {
			fatalError()
		}
		
		func viewUpdated(_ coordinator: MMMParallaxViewCoordinator, event: MMMParallaxUpdateEvent) {
			label.text = "Top: \(event.topProgress.rounded(toPlaces: 3)) - Height: \(event.heightProgress.rounded(toPlaces: 3))"
		}
	}
	
	let scrollView = UIScrollView(frame: .zero)
	let header = Sticky(automatic: true)
	let center = Sticky()
	let footer = Sticky()
	
	var wrapper: MMMParallaxViewWrapper?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		header.options.height = .automatic(with: header)
		
		footer.backgroundColor = .systemYellow
		footer.options.type = .scrollView(y: 2000 - 120)
		footer.options.height = .init(min: 44, max: 120)
		
		center.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.5)
		center.options.type = .scrollView(y: 1000)
		center.options.height = .init(min: 40, max: 40)
		center.options.stickPosition = .none
		
		scrollView.showsVerticalScrollIndicator = false
		scrollView.contentSize = .init(width: view.frame.size.width, height: 2000)
		scrollView.backgroundColor = .black
		
		let wrapper = MMMParallaxViewWrapper(scrollView: scrollView, parallaxViews: [header, center, footer])
		wrapper.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(wrapper)
		
		let viewDict = ["wrapper": wrapper]
		
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
		
		self.wrapper = wrapper
	}
}
