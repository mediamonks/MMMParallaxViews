//
// MMMParallaxViews. Part of MMMTemple.
// Copyright (C) 2020-2021 MediaMonks. All rights reserved.
//

import MMMParallaxViews
import UIKit

extension CGFloat {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (Double(self) * divisor).rounded() / divisor
    }
}

class ScrollViewController: UIViewController {

	class Sticky: UIView, MMMParallaxView {
	
		var options = MMMParallaxViewOptions(
			height: .init(min: 84, max: 320),
			type: .scrollView(y: 0)
		)
		
		private let label = UILabel(frame: .zero)
		
		override init(frame: CGRect) {
			super.init(frame: frame)
			
			setup()
		}
		
		required init?(coder: NSCoder) {
			super.init(coder: coder)
			
			setup()
		}
		
		private func setup() {
			backgroundColor = .orange
			
			label.translatesAutoresizingMaskIntoConstraints = false
			label.textAlignment = .center
			addSubview(label)
			
			label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
			label.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
			label.topAnchor.constraint(equalTo: topAnchor).isActive = true
			label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		}
		
		func viewUpdated(_ coordinator: MMMParallaxViewCoordinator, event: MMMParallaxUpdateEvent) {
			label.text = "Top: \(event.topProgress.rounded(toPlaces: 3)) - Height: \(event.heightProgress.rounded(toPlaces: 3))"
		}
	}
	
	class View: UIView {
		weak var coordinator: MMMParallaxViewCoordinator?
		
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
	
	let coordinator = MMMParallaxViewCoordinator()
	
	override func loadView() {
		let view = View()
		view.coordinator = coordinator
		coordinator.stickToSafeAreaInsets = false
		
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
		
		header.options.stickPosition = .top
		
		footer.backgroundColor = .purple
		footer.options.type = .scrollView(y: 2000 - 220)
		footer.options.height = .init(min: 144, max: 220)
		footer.options.stickPosition = .bottom
		
		center.backgroundColor = .init(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.5)
		center.options.type = .scrollView(y: 1000)
		center.options.height = .init(min: 40, max: 40)
		center.options.stickPosition = .top
		
		scrollView.showsVerticalScrollIndicator = false
		scrollView.contentSize = .init(width: view.frame.size.width, height: 2000)
		scrollView.backgroundColor = .gray
		
		coordinator.scrollView = scrollView
		coordinator.parallaxViews = [header, center, footer]
		coordinator.containerView = self.view
	}
}
