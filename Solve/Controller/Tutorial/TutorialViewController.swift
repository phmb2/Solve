//
//  TutorialViewController.swift
//  Solve
//
//  Created by Pedro Barbosa on 20/11/21.
//

import UIKit

class TutorialViewController: UIViewController {
    // MARK: - Properties
    private var pages = Page.allCases
    private var currentIndex = 0
    
    private lazy var pageController: UIPageViewController = {
        let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        return pageController
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        decoratePageController()
        setupPageController()
        addInitialPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func decoratePageController() {
        let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [TutorialViewController.self])
        pageControl.currentPageIndicatorTintColor = .solveColor
        pageControl.pageIndicatorTintColor = .gray
    }
    
    private func setupPageController() {
      pageController.dataSource = self
      pageController.delegate = self
      pageController.view.backgroundColor = .white
      pageController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width,height: view.frame.height)
      addChild(pageController)
      view.addSubview(pageController.view)
      pageController.didMove(toParent: self)
    }
    
    private func addInitialPage() {
        view.addSubview(pageController.view)
        let initialPage = PageViewController(with: pages[0])
        pageController.setViewControllers([initialPage], direction: .forward, animated: true, completion: nil)
        pageController.didMove(toParent: self)
    }
    
    @objc
    private func goToNextPage() {
        if currentIndex < pages.count - 1 {
            let nextPageViewController = PageViewController(with: pages[currentIndex + 1])
            currentIndex += 1
            pageController.setViewControllers([nextPageViewController], direction: .forward, animated: true)
        }
    }
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension TutorialViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let inde = (viewController as? PageViewController)?.page.index,
              inde > 0 else {
            return nil
        }

        currentIndex = inde - 1
        return PageViewController(with: pages[currentIndex])
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = (viewController as? PageViewController)?.page.index,
              index < self.pages.count - 1 else {
            return nil
        }

        currentIndex = index + 1
        return PageViewController(with: pages[currentIndex])
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        currentIndex
    }
}
