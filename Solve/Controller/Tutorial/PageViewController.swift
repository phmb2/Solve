//
//  PageViewController.swift
//  Solve
//
//  Created by Pedro Barbosa on 20/11/21.
//

import UIKit

class PageViewController: UIViewController {
    // MARK: - Properties
    var page: Page

    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: page.tutorialPage.image)
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 250, height: 300)
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .darkGray
        label.contentMode = .scaleToFill
        label.numberOfLines = 0
        label.text = page.tutorialPage.description
        return label
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .solveColor
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.heightAnchor.constraint(equalToConstant: 42).isActive = true
        button.addTarget(self, action: #selector(handleOnboardingNext), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    init(with page: Page) {
        self.page = page
        let textButton = self.page.index == 2 ? "Conhecer" : "Pular"
        nextButton.setTitle(textButton, for: .normal)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }
    
    // MARK: - Helpers
    func configureLayout() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(imageView)
        imageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 120)
        imageView.centerX(inView: view)
        
        self.view.addSubview(titleLabel)
        titleLabel.anchor(top: imageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 24, paddingRight: 24)
        
        self.view.addSubview(nextButton)
        nextButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 80, paddingBottom: 30, paddingRight: 80)
    
    }
    
    // MARK: - Selectors
    @objc func handleOnboardingNext() {
        let viewController = SignInViewController()        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
