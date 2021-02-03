#  MMMParallaxViews

The idea of ParallaxViews is to bind to a `UIScrollView` or `UITableView`, and track
a certain position or cell. The views will resize according to the scroll position,
you're able to give a minimum and maximum height for your views, as well as a stick
position.

A picture says more than a thousand words;

![ParallaxViews - not working until merge; checkout the .gif in the repo](https://github.com/mediamonks/MMMParallaxViews/raw/main/MMMParallaxViews.gif)

## Example

There is an example application showing the use of tracking a `UITableView`, `UIScrollView`
and with the (helper) wrapper view.

### The Coordinator

The main class is the `MMMParallaxViewCoordinator`, this holds a reference to your
`UIScrollView` or `UITableView`, your container view (`UIView` that hosts your
`MMMParallaxViews`, usually the parent of your `UIScrollView`) and an array of
`MMMParallaxView`'s.

### MMMParallaxView protocol

You should supply the coordinator with `MMMParallaxView` instances, these are regular
views that conform to the `MMMParallaxView` protocol. Each `MMMParallaxView` has it's own
set of options. Checkout `Sources/ParallaxViews/View/MMMParallaxView.swift` and
`Sources/ParallaxViews/View/MMMParallaxViewOptions.swift` for more info.

### Simple code example

```swift
class Header: UIView, MMMParallaxView {
    var options = MMMParallaxViewOptions(
        height: .init(min: 44, max: 220),
        type: .tableView(indexPath: IndexPath(row: 0, section: 0))
    )
}

class Footer: UIView, MMMParallaxView {
    var options = MMMParallaxViewOptions(
        height: .init(min: 44, max: 120),
        type: .tableView(indexPath: IndexPath(row: 0, section: 2))
    )
}

let coordinator = MMMParallaxViewCoordinator()

func viewDidLoad() {
    // do your regular stuff

    coordinator.scrollView = myTableView
    coordinator.containerView = self.view
    coordinator.parallaxViews = [header, footer]
}

// IMPORTANT! Make sure to call didFinishLayout when your views are properly calculated.
// for more info check the documentation on `didFinishLayout`.
override func viewDidLayoutSubviews() {
	super.viewDidLayoutSubviews()

	coordinator.didFinishLayout()
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // Supply your cells as you normally would, we assume here that section 0 and 2
    // are template cells for the ParallaxViews. Because the ParallaxView's are overlaying
    // the scrollView, you need a dummy cell for this.
    guard indexPath.section == 1 else {
        // might want to dequeue this
        return UITableViewCell()
    }

    // your cell code
    return cell
}

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    // Helper method to set the height for the cells that the coordinator is tracking,
    // because you need dummy cells to avoid overlapping.
    return coordinator.heightForRowAt(indexPath: indexPath)
}
```

### Need more?

Checkout the `Example` directory and/or app, or go straight to the `Sources` directory,
everything is pretty well documented.

## Installation

Either install via CocoaPods or Swift Package Manager, like you usually would.

## Known issues

If you aren't using the `MMMParallaxViewWrapper` and you want to use the `forwardsTouches`
option, you should override the `hitTest` in your containerView; Have a look at
the example for an implementation of this.
