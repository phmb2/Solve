//
//  ComplaintCell.swift
//  Solve
//
//  Created by Pedro Barbosa on 07/12/21.
//

import UIKit
import ActiveLabel

protocol ComplaintCellDelegate: AnyObject {
    func handleProfileImageTapped(_ cell: ComplaintCell)
    func handleReplyTapped(_ cell: ComplaintCell)
    func handleLikeTapped(_ cell: ComplaintCell)
    func handleShareTapped(_ cell: ComplaintCell)
    func handleFetchUser(withUsername username: String)
}

class ComplaintCell: UICollectionViewCell {
    // MARK: - Properties
    static let reuseId = "ComplaintCell"
    
    var complaint: Complaint? {
        didSet {
            configureUI()
        }
    }
    
    weak var delegate: ComplaintCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.setDimensions(width: 48, height: 48)
        imageView.layer.cornerRadius = 48 / 2
        imageView.backgroundColor = .solveColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    private let replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.mentionColor = .solveColor
        return label
    }()
    
    private let nameInfoLabel = UILabel()
    
    private let bankLabel = UILabel()
    
    private let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.mentionColor = .solveColor
        label.hashtagColor = .solveColor
        return label
    }()
    
    private lazy var commentButton: UIButton = {
        let button = createButton(withImageName: "comment")
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = createButton(withImageName: "like")
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = createButton(withImageName: "share")
        button.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let captionStack = UIStackView(arrangedSubviews: [nameInfoLabel, bankLabel, captionLabel])
        captionStack.axis = .vertical
        captionStack.distribution = .fillProportionally
        captionStack.spacing = 4
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [profileImageView, captionStack])
        imageCaptionStack.distribution = .fillProportionally
        imageCaptionStack.spacing = 12
        imageCaptionStack.alignment = .leading
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack])
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillProportionally
        
        addSubview(stack)
        stack.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 6, paddingLeft: 12, paddingRight: 12)
        
        nameInfoLabel.font = UIFont.systemFont(ofSize: 14)
        bankLabel.font = UIFont.systemFont(ofSize: 14)
        
        let underlineView = UIView()
        underlineView.backgroundColor = .systemGroupedBackground
        addSubview(underlineView)
        underlineView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 1)
        
        let actionStack = UIStackView(arrangedSubviews: [commentButton, likeButton, shareButton])
        actionStack.axis = .horizontal
        actionStack.spacing = 96
        
        addSubview(actionStack)
        actionStack.centerX(inView: self)
        actionStack.anchor(bottom: bottomAnchor, paddingBottom: 8)
        
        configureMention()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Selectors
    @objc func handleProfileImageTapped() {
        delegate?.handleProfileImageTapped(self)
    }
    
    @objc func handleCommentTapped() {
        delegate?.handleReplyTapped(self)
    }
    
    @objc func handleLikeTapped() {
        delegate?.handleLikeTapped(self)
    }
    
    @objc func handleShareTapped() {
        delegate?.handleShareTapped(self)
    }
    
    // MARK: Private Methods
    func configureUI() {
        guard let complaint = complaint else { return }
        
        let complaintViewModel = ComplaintViewModel(complaint: complaint)
        
        profileImageView.sd_setImage(with: complaintViewModel.profileImageUrl)
        nameInfoLabel.attributedText = complaintViewModel.userInfoText
        bankLabel.text = complaintViewModel.bankText
        captionLabel.text = complaint.caption
        
        likeButton.tintColor = complaintViewModel.likeButtonTintColor
        likeButton.setImage(complaintViewModel.likeButtonImage, for: .normal)
        
        replyLabel.isHidden = complaintViewModel.hideReplyLabel
        replyLabel.text = complaintViewModel.replyText
    }
    
    func createButton(withImageName imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        return button
    }
    
    func configureMention() {
        captionLabel.handleMentionTap { username in
            self.delegate?.handleFetchUser(withUsername: username)
        }
    }
}
