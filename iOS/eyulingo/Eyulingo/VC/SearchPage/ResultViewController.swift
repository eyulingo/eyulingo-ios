import Parchment
import UIKit

// This first thing we need to do is to create our own custom paging
// view and override the layout constraints. The default
// implementation positions the menu view above the page view
// controller, but since we want to overlay the menu above the page
// view and store the top constraint so that we can update it when
// the user is scrolling.
class CustomPagingView: PagingView {
    var menuTopConstraint: NSLayoutConstraint?

    override func setupConstraints() {
        pageView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        menuTopConstraint = collectionView.topAnchor.constraint(equalTo: topAnchor)
        menuTopConstraint?.isActive = true

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: options.menuHeight),

            pageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            pageView.topAnchor.constraint(equalTo: topAnchor),
        ])
    }
}

// Create a custom paging view controller and override the view with
// our own custom subclass.
class CustomPagingViewController: PagingViewController<PagingIndexItem> {
    override func loadView() {
        view = CustomPagingView(
            options: options,
            collectionView: collectionView,
            pageView: pageViewController.view
        )
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
            textColor = .label
            borderColor = .quaternarySystemFill
            selectedTextColor = .label
            menuBackgroundColor = .tertiarySystemBackground
            selectedBackgroundColor = .systemFill
        }
    }
}

class ResultViewController: UIViewController {
    private let pagingViewController = CustomPagingViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add the paging view controller as a child view controller and
        // contrain it to all edges.
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParent: self)

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        }
        // Set our data source and delegate.
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
    }

    /// Calculate the menu offset based on the content offset of the
    /// scroll view.
    private func menuOffset(for scrollView: UIScrollView) -> CGFloat {
        return min(pagingViewController.options.menuHeight, max(0, scrollView.contentOffset.y))
    }
}

extension ResultViewController: PagingViewControllerDataSource {
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
        let viewController = DetailContentViewController()

        // Inset the table view with the height of the menu height.
//        let menuHeight = pagingViewController.options.menuHeight
//        let insets = UIEdgeInsets(top: menuHeight, left: 0, bottom: 0, right: 0)
//        viewController.tableView.contentInset = insets
//        viewController.tableView.scrollIndicatorInsets = insets

        // Set delegate so that we can listen to scroll events.
//        viewController.tableView.delegate = self

        return viewController
    }

    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
        return PagingIndexItem(index: index, title: "View \(index)") as! T
    }

    func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
        return 6
    }
}

extension ResultViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Offset the menu view based on the content offset of the
        // scroll view.
        if let menuView = pagingViewController.view as? CustomPagingView {
            menuView.menuTopConstraint?.constant = -menuOffset(for: scrollView)
        }
    }
}

extension ResultViewController: PagingViewControllerDelegate {
    // We want to transition the menu offset smoothly to it correct
    // position when we are swiping between pages.
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, isScrollingFromItem currentPagingItem: T, toItem upcomingPagingItem: T?, startingViewController: UIViewController, destinationViewController: UIViewController?, progress: CGFloat) {
        guard let destinationViewController = destinationViewController as? DetailContentViewController else { return }
        guard let startingViewController = startingViewController as? DetailContentViewController else { return }
        guard let menuView = pagingViewController.view as? CustomPagingView else { return }

        // Tween between the current menu offset and the menu offset of
        // the destination view controller.
        let from = menuOffset(for: startingViewController.scrollView)
        let to = menuOffset(for: destinationViewController.scrollView)
        let offset = ((to - from) * abs(progress)) + from

        menuView.menuTopConstraint?.constant = -offset
    }
}
