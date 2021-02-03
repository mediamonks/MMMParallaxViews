//
// MMMParallaxViews. Part of MMMTemple.
// Copyright (C) 2020-2021 MediaMonks. All rights reserved.
//

import UIKit
import MMMParallaxViews

class TableViewController: UIViewController {

	class Sticky: UIView, MMMParallaxView {

		var options = MMMParallaxViewOptions(
			height: .init(min: 120, max: 220),
			type: .tableView(indexPath: IndexPath(row: 0, section: 0))
		)

		public init() {

			super.init(frame: .zero)

			self.backgroundColor = .red
			self.translatesAutoresizingMaskIntoConstraints = false
			
			let top = UIView(frame: .zero)
			top.translatesAutoresizingMaskIntoConstraints = false
			top.backgroundColor = UIColor.white.withAlphaComponent(0.7)
			
			let bottom = UIView(frame: .zero)
			bottom.translatesAutoresizingMaskIntoConstraints = false
			bottom.backgroundColor = UIColor.white.withAlphaComponent(0.5)
			
			addSubview(top)
			addSubview(bottom)
			
			let views = ["top": top, "bottom": bottom]
			
			NSLayoutConstraint.activate(
				NSLayoutConstraint.constraints(
					withVisualFormat: "H:|-20-[top]-20-|",
					options: [], metrics: [:], views: views
				) + NSLayoutConstraint.constraints(
					withVisualFormat: "H:|-20-[bottom]-20-|",
					options: [], metrics: [:], views: views
				)
			)
			
			NSLayoutConstraint.activate(
				NSLayoutConstraint.constraints(
					// Using prio 749 constraints allows the view to become smaller when that's needed.
					withVisualFormat: "V:|-(20)-[top(>=20@749)]-(>=0,20@749)-[bottom(20@752)]-(20)-|",
					options: [], metrics: [:], views: views
				)
			)
		}

		required init?(coder: NSCoder) {
			preconditionFailure()
		}
	}
	
	class View: UIView {
		weak var coordinator: MMMParallaxViewCoordinator?

		// TODO: cannot the same be achieved by overriding it on the sticky header?
		// When not using the wrapper, and you want to be able to touch the parallax views
		// to scroll (e.g. make use of the forwardsTouches option), you should override the hitTest
		override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
			return coordinator?.hitTest(for: super.hitTest(point, with: event))
		}
	}
	
	let tableView = UITableView(frame: .zero, style: .plain)
	let refreshControl = UIRefreshControl()
	let header = Sticky()
	let footer = Sticky()

	private lazy var center: UIView = {
		let center = UIView()
		center.translatesAutoresizingMaskIntoConstraints = false
		center.backgroundColor = .init(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.5)
		return center
	}()

	// This is to show that the views being managed do not have to support certain protocol.
	// The desired behavior can be described separately.
	private lazy var centerDescriptor = MMMParallaxViewDescriptor(
		view: center,
		options: MMMParallaxViewOptions(
			height: .init(min: 20, max: 40),
			type: .tableView(indexPath: .init(row: 5, section: 3)),
			forwardsTouches: true,
			stickPosition: .top
		),
		onDidUpdate: { p in
			// And we can do something with the view from the outside without overriding anything there.
			self.center.alpha = p.topProgress
		}
	)
	
	let coordinator = MMMParallaxViewCoordinator()
	
	override func loadView() {

		let view = View()
		view.coordinator = coordinator
		
        self.view = view
	}
	
	override func viewDidLoad() {

		super.viewDidLoad()
		
		title = "Test"
		
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.refreshControl = refreshControl
		
		refreshControl.attributedTitle = .init(string: "Refresh!")
		refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		
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
		
		header.alpha = 0.5

		footer.backgroundColor = .blue
		footer.options.type = .tableView(indexPath: IndexPath(row: 0, section: 5))
		footer.options.height = .dynamic
		footer.options.stickPosition = .bottom

		tableView.delegate = self
		tableView.dataSource = self
		tableView.showsVerticalScrollIndicator = false

		// We have a refresh control here and don't want our header to cover it.
		coordinator.stretchTopViewWhenBouncing = false
		// However it's fine to stretch the bottom view.
		coordinator.stretchBottomViewWhenBouncing = true
		// This is the default value anyway, but let's test it here.
		// The constraints in our stickies with prio less than 751 will be beaten when the view needs to be compressed.
		coordinator.heightConstraintPriority = .defaultHigh + 1
		coordinator.scrollView = tableView
		coordinator.parallaxViews = [ header, centerDescriptor, footer ]
		coordinator.containerView = self.view
		coordinator.shouldAdjustContentInset = true // to make sure the section titles are sticking below the header
	}
	
	// If the views aren't properly aligned, make sure to call recalculate
	// when your views are properly calculated. For more info check the
	// documentation on `contentOffsetDidChange`.
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		coordinator.recalculate()
	}
	
	@objc func refresh() {
		RunLoop.main.add(Timer(timeInterval: 2, repeats: false, block: { _ in
			self.refreshControl.endRefreshing()
		}), forMode: .common)
	}
}

extension TableViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return coordinator.heightForRowAt(indexPath: indexPath)
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 6
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 || section == 5 { return 1 }
		
		return 10
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section > 0, section < 5 {
			return "Title \(section)"
		}
		
		return nil
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

