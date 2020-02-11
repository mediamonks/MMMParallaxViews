//
//  TableViewController.swift
//  ParallaxViews
//
//  Created by Erik Terwan on 10/02/2020.
//  Copyright © 2020 MediaMonks. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {
	class Sticky: UIView, ParallaxView {
		var options = ParallaxViewOptions(
			height: .init(min: 44, max: 220),
			type: .tableView(indexPath: IndexPath(row: 0, section: 0))
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
	
	let tableView = UITableView(frame: .zero, style: .plain)
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
		
		tableView.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(tableView)
		
		let viewDict = ["tableView": tableView]
		
		NSLayoutConstraint.activate(
			NSLayoutConstraint.constraints(
				withVisualFormat: "V:|[tableView]|",
				options: [], metrics: nil,
				views: viewDict
			) + NSLayoutConstraint.constraints(
				withVisualFormat: "H:|[tableView]|",
				options: [], metrics: nil,
				views: viewDict
			)
		)
		
		footer.backgroundColor = .blue
		footer.options.type = .tableView(indexPath: IndexPath(row: 0, section: 2))
		footer.options.height = .init(min: 44, max: 120)
		
		center.backgroundColor = .init(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.5)
		center.options.type = .tableView(indexPath: IndexPath(row: 13, section: 1))
		center.options.height = .init(min: 40, max: 40)
		center.options.stickPosition = .none
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.showsVerticalScrollIndicator = false
		
		coordinator.scrollView = tableView
		coordinator.parallaxViews = [header, center, footer]
		coordinator.containerView = self.view
	}
}

extension TableViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return coordinator.heightForRowAt(indexPath: indexPath)
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard section == 1 else { return 1 }
		
		return 20
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// you should dequeue your cells
		let cell = UITableViewCell()
		cell.textLabel?.text = "Cell \(indexPath.row)"
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

