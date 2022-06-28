//
//  ProfileViewController.swift
//  Solve
//
//  Created by Pedro Barbosa on 08/12/21.
//

import UIKit
import Firebase

private let profileHeader = "profileHeader"

class ProfileViewController: UICollectionViewController {
    // MARK: - Properties
    private var user: User
    
    private var selectedFilter: ProfileFilterOptions = .complaints {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var complaints = [Complaint]()
    private var repliesComplaints = [Complaint]()
    private var likedComplaints = [Complaint]()
    
    private var currentDataSource: [Complaint] {
        switch selectedFilter {
            case .complaints: return complaints
            case .replies: return repliesComplaints
            case .likes: return likedComplaints
        }
    }
    
    // MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchComplaints()
        fetchReplies()
        fetchLikedComplaints()
        checkUserIsFollowed()
        fetchUserStats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - API Service
    func fetchComplaints() {
        ComplaintService.shared.fetchComplaints(forUser: user) { [weak self] complaints in
            guard let self = self else { return }
            self.complaints = complaints
            self.collectionView.reloadData()
        }
    }
    
    func fetchReplies() {
        ComplaintService.shared.fetchReplies(forUser: user) { [weak self] complaints in
            guard let self = self else { return }
            self.repliesComplaints = complaints
        }
    }
    
    func fetchLikedComplaints() {
        ComplaintService.shared.fetchLikes(forUser: user) { [weak self] complaints in
            guard let self = self else { return }
            self.likedComplaints = complaints
        }
    }
    
    func checkUserIsFollowed() {
        UserService.shared.checkUserIsFollowed(uid: user.uid) { [weak self] isFollowed in
            guard let self = self else { return }
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    func fetchUserStats() {
        UserService.shared.fetchUserStats(uid: user.uid) { [weak self] stats in
            guard let self = self else { return }
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Helpers
    func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: profileHeader)
        collectionView.register(ComplaintCell.self, forCellWithReuseIdentifier: ComplaintCell.reuseId)
        
        guard let tabHeight = tabBarController?.tabBar.frame.height else { return }
        collectionView.contentInset.bottom = tabHeight
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ComplaintCell.reuseId, for: indexPath) as! ComplaintCell
        cell.complaint = currentDataSource[indexPath.row]
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var height: CGFloat = 360
        
        if user.bio != nil {
            height += 30
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let complaintViewModel = ComplaintViewModel(complaint: currentDataSource[indexPath.row])
        var captionHeight = complaintViewModel.size(forWidth: view.frame.width).height + 80
        
        if currentDataSource[indexPath.row].isReply {
            captionHeight = captionHeight + 20
        }
        
        return CGSize(width: view.frame.width, height: captionHeight)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: view.frame.width, height: 120)
//    }
}

// MARK: - UICollectionViewDelegate
extension ProfileViewController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: profileHeader, for: indexPath) as! ProfileHeader
        header.user = user
        header.delegate = self
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = ComplaintViewController(complaint: currentDataSource[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - ProfileHeaderDelegate
extension ProfileViewController: ProfileHeaderDelegate {
    func handleBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    func handleEditProfileFollow(_ header: ProfileHeader) {
        
        if user.isCurrentUser {
            let controller = EditProfileViewController(user: user)
            controller.delegate = self
            let navigation = UINavigationController(rootViewController: controller)
            navigation.modalPresentationStyle = .fullScreen
            present(navigation, animated: true, completion: nil)
            return
            
        } else {
            if user.isFollowed {
                UserService.shared.unfollowUser(uid: user.uid) { (error, ref) in
                    self.user.isFollowed = false
                    self.collectionView.reloadData()
                }
            } else {
                UserService.shared.followUser(uid: user.uid) { (error, ref) in
                    self.user.isFollowed = true
                    self.collectionView.reloadData()
                    
                    NotificationService.shared.uploadNotification(toUser: self.user, type: .follow)
                }
            }
        }

    }
    
    func didSelect(filter: ProfileFilterOptions) {
        self.selectedFilter = filter
    }
}

// MARK: - EditProfileControllerDelegate
extension ProfileViewController: EditProfileControllerDelegate {
    func handleLogout() {
        do {
            try Auth.auth().signOut()
            let nav = UINavigationController(rootViewController: SignInViewController())
            nav.modalPresentationStyle = .fullScreen
            nav.modalTransitionStyle = .flipHorizontal
            self.present(nav, animated: true, completion: nil)
            
            print("Did logout user")
        } catch let error {
            print("Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func controller(_ controller: EditProfileViewController, updated user: User) {
        controller.dismiss(animated: true, completion: nil)
        self.user = user
        self.collectionView.reloadData()
    }
}
