//
//  MainTabController.swift
//  Solve
//
//  Created by Pedro Barbosa on 15/11/21.
//

import UIKit
import Firebase

enum ActionButtonConfiguration {
    case complaint
    case message
}

class MainTabController: UITabBarController {
    // MARK: Properties
    private var buttonConfig: ActionButtonConfiguration = .complaint
    
    var user: User? {
        didSet {
            guard let nav = viewControllers?[0] as? UINavigationController else { return }
            guard let feed = nav.viewControllers.first as? FeedViewController else { return }
            feed.user = user
        }
    }
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = .solveColor
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .solveColor
        authenticateUserAndConfigureUI()
    }
    
    // MARK: API Service
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.shared.fetchUser(uid: uid) { [weak self] user in
            guard let self = self else { return }
            self.user = user
        }
    }
    
    func authenticateUserAndConfigureUI() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let userDefaults = UserDefaults.standard
                let tutorial = userDefaults.bool(forKey: "tutorial")
                let rootViewController = tutorial ? SignInViewController() : TutorialViewController()
                let nav = UINavigationController(rootViewController: rootViewController)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            configureViewControllers()
            configureUI()
            fetchUser()
        }
    }
    
    // MARK: Selectors
    @objc func actionButtonTapped() {
        let controller: UIViewController
        
        switch buttonConfig {
            case .message:
                controller = ExploreViewController(config: .messages)
            case .complaint:
                guard let user = user else { return }
                controller = UploadComplaintViewController(user: user, config: .complaint)
        }
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    // MARK: Helpers
    func configureUI() {
        self.delegate = self
        view.addSubview(actionButton)

        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingBottom: 64, paddingRight: 16, width: 56, height: 56)
        actionButton.layer.cornerRadius = 56/2
    }
    
    func configureViewControllers() {
        UITabBar.appearance().tintColor = .solveColor
        
        let feed = FeedViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let nav1 = templateNavigationController(image: UIImage(systemName: "house.fill"), title: "Reclamações", rootViewController: feed)
        
        let explore = ExploreViewController(config: .users)
        let nav2 = templateNavigationController(image: UIImage(systemName: "magnifyingglass.circle.fill"), title: "Busca", rootViewController: explore)
        
        let banks = BanksListViewController()
        let nav3 = templateNavigationController(image: UIImage(systemName: "banknote.fill"), title: "Bancos", rootViewController: banks)
        
        let notifications = NotificationsViewController()
        let nav4 = templateNavigationController(image: UIImage(systemName: "ellipsis.bubble.fill"), title: "Notificações", rootViewController: notifications)
        
        viewControllers = [nav1, nav2, nav3, nav4]
    }
    
    func templateNavigationController(image: UIImage?, title: String? = "", rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = image
        nav.tabBarItem.title = title
        nav.navigationBar.barTintColor = .white
        
        return nav
    }
}

// MARK: - UITabBarControllerDelegate
extension MainTabController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2 {
            actionButton.isHidden = true
        } else {
            let image = #imageLiteral(resourceName: "new_tweet")
            actionButton.isHidden = false
            actionButton.setImage(image, for: .normal)
            buttonConfig = .complaint
        }
    }
}
