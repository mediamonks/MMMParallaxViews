//
//  WrapperViewController.swift
//  ParallaxViews
//
//  Created by Erik Terwan on 10/02/2020.
//  Copyright © 2020 MediaMonks. All rights reserved.
//

import UIKit

class WrapperViewController: UIViewController {
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
			
			backgroundColor = .systemPink
		}
		
		required init?(coder: NSCoder) {
			super.init(coder: coder)
			
			backgroundColor = .systemPink
		}
	}
	
	let scrollView = UIScrollView(frame: .zero)
	let header = Sticky()
	let center = Sticky()
	let footer = Sticky()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		footer.backgroundColor = .yellow
		footer.options.type = .scrollView(y: 2000 - 120)
		footer.options.height = .init(min: 44, max: 120)
		
		center.backgroundColor = .init(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.5)
		center.options.type = .scrollView(y: 1000)
		center.options.height = .init(min: 40, max: 40)
		center.options.stickPosition = .none
		
		scrollView.showsVerticalScrollIndicator = false
		scrollView.contentSize = .init(width: view.frame.size.width, height: 2000)
		scrollView.backgroundColor = .white
		
		let wrapper = ParallaxViewWrapper(scrollView: scrollView, parallaxViews: [header, center, footer])
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
	}
	
	
}
