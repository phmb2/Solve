//
//  FeedViewController.swift
//  Solve
//
//  Created by Pedro Barbosa on 22/11/21.
//

import UIKit
import SDWebImage

class FeedViewController: UICollectionViewController {
    // MARK: - Properties
    var user: User? {
        didSet {
            configureLeftBarButton()
        }
    }
    
    private var complaints = [Complaint]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        configureUI()
        fetchComplaints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "SOLVE"
    }
    
    // MARK: - API Service
    func fetchComplaints() {
//        collectionView.refreshControl?.beginRefreshing()
        showLoadingView()
        ComplaintService.shared.fetchComplaints { [weak self] complaints in
            guard let self = self else { return }
//            self.collectionView.refreshControl?.endRefreshing()
            self.dismissLoadingView()
            if complaints.count > 0 {
                self.complaints = complaints.sorted(by: { $0.timestamp > $1.timestamp })
                self.checkUserLikedComplaint()
            }
//            else {
//                let message = "Não há reclamações!"
//                self.showEmptyStateView(with: message, in: self.view)
//            }
        }
    }
    
    func checkUserLikedComplaint() {
        self.complaints.forEach { complaint in
            ComplaintService.shared.checkUserLikedComplaint(complaint) { [weak self] didLike in
                guard let self = self else { return }
                guard didLike == true else { return }

                if let index = self.complaints.firstIndex(where: { $0.complaintId == complaint.complaintId }) {
                    self.complaints[index].didLike = true
                }
            }
        }
    }
    
    // MARK: - Selectors
    @objc func handleRefresh() {
        fetchComplaints()
    }
    
    @objc func handleProfileImageTap() {
        guard let user = user else { return }
        let controller = ProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        collectionView.register(ComplaintCell.self, forCellWithReuseIdentifier: ComplaintCell.reuseId)
        collectionView.backgroundColor = .white
        
        let refreshControl = UIRefreshControl()
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    func configureLeftBarButton() {
        guard let user = user else { return }
        
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap))
        profileImageView.addGestureRecognizer(tap)
        
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
}

// MARK: UICollectionViewDelegate/Datasource
extension FeedViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return complaints.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ComplaintCell.reuseId, for: indexPath) as! ComplaintCell
        cell.delegate = self
        cell.complaint = complaints[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = ComplaintViewController(complaint: complaints[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let complaintViewModel = ComplaintViewModel(complaint: complaints[indexPath.row])
        let captionHeight = complaintViewModel.size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: captionHeight + 80)
    }
}

// MARK: ComplaintCellDelegate
extension FeedViewController: ComplaintCellDelegate {
    func handleProfileImageTapped(_ cell: ComplaintCell) {
        guard let user = cell.complaint?.user else { return }
        let controller = ProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleReplyTapped(_ cell: ComplaintCell) {
        guard let complaint = cell.complaint else { return }
        let viewController = UploadComplaintViewController(user: complaint.user, config: .reply(complaint))
        let nav = UINavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func handleLikeTapped(_ cell: ComplaintCell) {
        guard let complaint = cell.complaint else { return }
        
        ComplaintService.shared.likeComplaint(complaint: complaint) { (error, ref) in
            cell.complaint?.didLike.toggle()
            let likes = complaint.didLike ? complaint.likes - 1 : complaint.likes + 1
            cell.complaint?.likes = likes
            
            guard !complaint.didLike else { return }
            NotificationService.shared.uploadNotification(toUser: complaint.user, type: .like, complaintId: complaint.complaintId)
        }
    }
    
    func handleShareTapped(_ cell: ComplaintCell) {
        guard let complaint = cell.complaint else { return }
        
        let textToShare = [ complaint.caption ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view

        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook, UIActivity.ActivityType.postToTwitter ]

        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func handleFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(withUsername: username) { [weak self] user in
            guard let self = self else { return }
            let controller = ProfileViewController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
