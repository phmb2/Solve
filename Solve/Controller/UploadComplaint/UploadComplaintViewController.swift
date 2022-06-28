//
//  UploadComplaintViewController.swift
//  Solve
//
//  Created by Pedro Barbosa on 23/11/21.
//

import UIKit
import ActiveLabel

class UploadComplaintViewController: UIViewController {
    // MARK: - Properties
    private let user: User
    private let config: UploadComplaintConfiguration
    private lazy var uploadComplaintViewModel = UploadComplaintViewModel(config: config)
    private var keyboardHeight: CGFloat = 64
    private var originInitialPosition: CGFloat = 0
    var bank: Bank = Bank()
    
    var selectedBank: Bank? {
        didSet {
            if let selectedBank = selectedBank {
                bank = selectedBank
            }
        }
    }
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancelar", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.solveColor, for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .solveColor
        button.setTitle("Reclamação", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        
        button.frame = CGRect(x: 0, y: 0, width: 120, height: 32)
        button.layer.cornerRadius = 32 / 2
        
        button.addTarget(self, action: #selector(handleUploadComplaint), for: .touchUpInside)
        
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.setDimensions(width: 48, height: 48)
        imageView.layer.cornerRadius = 48 / 2
        imageView.backgroundColor = .solveColor
        return imageView
    }()
    
    private lazy var replyLabel: UILabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.mentionColor = .solveColor
        label.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        return label
    }()
    
    private let captionTextView = CaptionTextView()
    
    private lazy var bankContainerView: UIView = {
        let image = UIImage(systemName: "dollarsign.circle")
        if let image = image {
            let view = Utilities().inputContainerView(withImage: image, textField: bankTextField, color: .solveColor)
            return view
        }
        return UIView()
    }()
    
    private let bankTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .solveColor
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.addTarget(self, action: #selector(handleSelectBank), for: .touchDown)
        return textField
    }()
    
    // MARK: - Lifecycle
    init(user: User, config: UploadComplaintConfiguration) {
        self.user = user
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
        updateBankTextField(bank)
    }
    
    // MARK: - API Service
    fileprivate func uploadMentionNotification(forCaption caption: String, complaintId: String?) {
        guard caption.contains("@") else { return }
        
        let words = caption.components(separatedBy: .whitespacesAndNewlines)
        
        words.forEach { word in
            guard word.hasPrefix("@") else { return }
            
            var username = word.trimmingCharacters(in: .symbols)
            username = username.trimmingCharacters(in: .punctuationCharacters)
            
            UserService.shared.fetchUser(withUsername: username) { mentionedUser in
                NotificationService.shared.uploadNotification(toUser: mentionedUser, type: .mention, complaintId: complaintId)
            }
        }
    }
    
    // MARK: - Selectors
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleUploadComplaint() {
        guard let caption = captionTextView.text else { return }
        guard let selectBank = bankTextField.text else { return }
        
        if caption.count > 0 && caption != "" {
            if selectBank.isEmpty {
                self.presentAlertOnMainThread(title: "Solve", message: "Por favor, selecione o banco para realizar a reclamação.", buttonTitle: "Ok")
                return
            }
            
            ComplaintService.shared.uploadComplaint(caption: caption, bank: selectBank, type: config) { [weak self] (error, ref) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Failed to upload complaint with error \(error.localizedDescription)")
                    return
                }

                if case .reply(let complaint) = self.config {
                    NotificationService.shared.uploadNotification(toUser: complaint.user, type: .reply, complaintId: complaint.complaintId)
                }

                self.dismiss(animated: true, completion: nil)
            }
        } else {
            self.presentAlertOnMainThread(title: "Solve", message: "Por favor, escreva sua reclamação.", buttonTitle: "Ok")
        }
    }
    
    @objc func handleSelectBank() {
        let viewController = BankPickerViewController()
        viewController.bankPickerDelegate = self
        viewController.selectedBank = self.selectedBank
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.2) {
            self.view.frame.origin.y = self.originInitialPosition + self.keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Private Methods
    private func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .default
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        configureNavigationBar()
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [profileImageView, captionTextView])
        imageCaptionStack.axis = .horizontal
        imageCaptionStack.spacing = 12
        imageCaptionStack.alignment = .leading
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack])
        stack.axis = .vertical
        stack.spacing = 12
        
        view.addSubview(stack)
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(bankContainerView)
        bankContainerView.anchor(top: stack.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 36, paddingLeft: 16, paddingRight: 16)
        
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        
        actionButton.setTitle(uploadComplaintViewModel.actionButtonTitle, for: .normal)
        
        captionTextView.placeholderLabel.text = uploadComplaintViewModel.placeholderText
        
        replyLabel.isHidden = !uploadComplaintViewModel.showReplyLabel
        guard let replyText = uploadComplaintViewModel.replyText else { return }
        replyLabel.text = replyText
        
        bankContainerView.isHidden = uploadComplaintViewModel.showBankContainerView
    }
    
    private func updateBankTextField(_ bank: Bank) {
        if bank.code != "" {
            self.bankTextField.placeholder = "\(bank.code) - \(bank.name)"
            self.bankTextField.text = "\(bank.code) - \(bank.name)"
        } else {
            self.bankTextField.placeholder = "Selecione o banco para fazer a reclamação"
            self.bankTextField.text = ""
        }
    }
}

// MARK: - BankPickerDelegate
extension UploadComplaintViewController: BankPickerDelegate {
    func selectBankOnTap(_ bank: Bank) {
        self.selectedBank = bank
        if let selectedBank = self.selectedBank {
            self.updateBankTextField(selectedBank)
        }
    }
}
