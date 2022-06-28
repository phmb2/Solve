//
//  NotificationsViewController.swift
//  Solve
//
//  Created by Pedro Barbosa on 24/11/21.
//

import UIKit

class NotificationsViewController: UITableViewController {
    // MARK: - Properties
    private var notifications = [Notification]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: - API Service
    func fetchNotifications() {
//        refreshControl?.beginRefreshing()
        showLoadingView()
        NotificationService.shared.fetchNotifications { [weak self] notifications in
            guard let self = self else { return }
//            self.refreshControl?.endRefreshing()
            self.dismissLoadingView()
            self.notifications = notifications
            self.checkIfUserIsFollowed(notifications: notifications)
        }
    }
    
    func checkIfUserIsFollowed(notifications: [Notification]) {
        guard !notifications.isEmpty else { return }
        
        notifications.forEach { notification in

            guard case .follow = notification.type else { return }

            let user = notification.user

            UserService.shared.checkUserIsFollowed(uid: user.uid) { [weak self] userIsFollowed in
                guard let self = self else { return }
                
                if let index = self.notifications.firstIndex(where: { $0.user.uid == notification.user.uid }) {
                    self.notifications[index].user.isFollowed = userIsFollowed
                }
            }
        }
    }
    
    // MARK: - Selectors
//    @objc func handleRefresh() {
//        fetchNotifications()
//    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        
        navigationItem.title = "Notificações"
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.reuseId)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
//        let refreshControl = UIRefreshControl()
//        tableView.refreshControl = refreshControl
//        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
}

// MARK: - UITableViewDataSource
extension NotificationsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.reuseId, for: indexPath) as! NotificationCell
        cell.notification = notifications[indexPath.row]
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NotificationsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        
        guard let complaintId = notification.complaintId else { return }
        
        ComplaintService.shared.fetchComplaint(withComplaintId: complaintId) { [weak self] complaint in
            guard let self = self else { return }
            let controller = ComplaintViewController(complaint: complaint)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: - NotificationCellDelegate
extension NotificationsViewController: NotificationCellDelegate {
    func didTapProfileImage(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        let controller = ProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapFollow(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { (error, ref) in
                cell.notification?.user.isFollowed = false
            }
        } else {
            UserService.shared.followUser(uid: user.uid) { (error, ref) in
                cell.notification?.user.isFollowed = true
            }
        }
    }
}
