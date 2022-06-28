//
//  ComplaintViewController.swift
//  Solve
//
//  Created by Pedro Barbosa on 07/12/21.
//

import UIKit

private let complaintHeader = "complaintHeader"

class ComplaintViewController: UICollectionViewController {
    // MARK: - Properties
    private let complaint: Complaint
//    private var actionSheetLauncher: ActionSheetLauncher!
    private var replies = [Complaint]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    init(complaint: Complaint) {
        self.complaint = complaint
//        self.actionSheetLauncher = ActionSheetLauncher(user: complaint.user)
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        configureCollectionView()
        fetchReplies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: - API Service
    func fetchReplies() {
        ComplaintService.shared.fetchReplies(forComplaint: complaint) { [weak self] replies in
            guard let self = self else { return }
            self.replies = replies
        }
    }
    
    // MARK: - Helpers
    func configureCollectionView() {
        collectionView.backgroundColor = .white
        
        collectionView.register(ComplaintHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: complaintHeader)
        collectionView.register(ComplaintCell.self, forCellWithReuseIdentifier: ComplaintCell.reuseId)
    }
    
    fileprivate func showActionSheet(forUser user: User) {
//        actionSheetLauncher = ActionSheetLauncher(user: complaint.user)
//        actionSheetLauncher.delegate = self
//        actionSheetLauncher.show()
    }
}

// MARK: - UICollectionViewDataSource
extension ComplaintViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return replies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ComplaintCell.reuseId, for: indexPath) as! ComplaintCell
        cell.complaint = replies[indexPath.row]
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ComplaintViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let complaintViewModel = ComplaintViewModel(complaint: complaint)
        let captionHeight = complaintViewModel.size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: captionHeight + 260)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}

// MARK: - UICollectionViewDelegate
extension ComplaintViewController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: complaintHeader, for: indexPath) as! ComplaintHeader
        header.complaint = complaint
        header.delegate = self
        return header
    }
}

// MARK: - ComplaintHeaderDelegate
extension ComplaintViewController: ComplaintHeaderDelegate {
    func showActionSheet() {
        if complaint.user.isCurrentUser {
            showActionSheet(forUser: complaint.user)
        } else {
            UserService.shared.checkUserIsFollowed(uid: complaint.user.uid) { isFollowed in
                var user = self.complaint.user
                user.isFollowed = isFollowed
                self.showActionSheet(forUser: user)
            }
        }
    }
    
    func handleFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(withUsername: username) { user in
            let controller = ProfileViewController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: - ActionSheetLauncherDelegate
//extension ComplaintViewController: ActionSheetLauncherDelegate {
//    func didSelect(option: ActionSheetOptions) {
//        switch option {
//            case .follow(let user):
//                UserService.shared.followUser(uid: user.uid) { (error, ref) in
//                    print("Did follow user \(user.username)")
//                }
//            case .unfollow(let user):
//                UserService.shared.unfollowUser(uid: user.uid) { (error, ref) in
//                    print("Did unfollow user \(user.username)")
//                }
//            case .report:
//                print("Report complaint")
//            case .delete:
//                print("Delete complaint")
//        }
//    }
//    
//}
