//
//  UIViewController+Extension.swift
//  Solve
//
//  Created by Pedro Barbosa on 18/12/21.
//

import UIKit
import SafariServices

fileprivate var containerView: UIView!

// MARK: - UIViewController
extension UIViewController {
    func presentAlertOnMainThread(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let alertViewController = AlertDefaultViewController(title: title, message: message, buttonTitle: buttonTitle)
            alertViewController.modalPresentationStyle = .overFullScreen
            alertViewController.modalTransitionStyle = .crossDissolve
            self.present(alertViewController, animated: true)
        }
    }
    
    func showLoadingView() {
        containerView = UIView(frame: view.bounds)
        view.addSubview(containerView)
        
        containerView.backgroundColor = .systemBackground
        containerView.alpha = 0
        
        UIView.animate(withDuration: 0.25) {
            containerView.alpha = 0.8
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        containerView.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    func dismissLoadingView() {
        DispatchQueue.main.async {
            if containerView != nil {
                containerView.removeFromSuperview()
                containerView = nil
            }
        }
    }
    
    func observeKeyboardWillShow(_ selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func observeKeyboardWillHide(_ selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func stopObservingKeyboardWillShow() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func stopObservingKeyboardWillHide() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func showEmptyStateView(with message: String, in view: UIView) {
        let emptyStateView = EmptyStateView(message: message)
        emptyStateView.frame = view.bounds
        view.addSubview(emptyStateView)
    }
    
    func openSafariViewController(with url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = .solveColor
        present(safariViewController, animated: true)
    }
}
