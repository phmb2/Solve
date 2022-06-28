//
//  EditProfileViewController.swift
//  Solve
//
//  Created by Pedro Barbosa on 07/12/21.
//

import UIKit

private let editProfileCell = "EditProfileCell"

protocol EditProfileControllerDelegate: AnyObject {
    func controller(_ controller: EditProfileViewController, updated user: User)
    func handleLogout()
}

class EditProfileViewController: UITableViewController {
    // MARK: - Properties
    private var user: User
    private lazy var headerView = EditProfileHeader(user: user)
    private let footerView = EditProfileFooter()
    private let imagePicker = UIImagePickerController()
    weak var delegate: EditProfileControllerDelegate?
    private var userInfoChanged = false
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancelar", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Salvar", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    private var profileImageChanged: Bool {
        return selectedImage != nil
    }
    
    private var selectedImage: UIImage? {
        didSet {
            headerView.profileImageView.image = selectedImage
        }
    }
    
    // MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureImagePicker()
        configureNavigationBar()
        configureTableView()
    }
    
    // MARK: - API Service
    func updateUserData() {
        if profileImageChanged && !userInfoChanged {
            updateProfileImage()
        }
        
        if userInfoChanged && !profileImageChanged {
            UserService.shared.saveUserData(user: user) { [weak self] (error, ref) in
                guard let self = self else { return }
                //self.dismiss(animated: true, completion: nil)
                self.delegate?.controller(self, updated: self.user)
            }
        }
        
        if profileImageChanged && userInfoChanged {
            UserService.shared.saveUserData(user: user) { [weak self] (error, ref) in
                guard let self = self else { return }
                self.updateProfileImage()
            }
        }
    }
    
    func updateProfileImage() {
        guard let image = selectedImage else { return }
        
        UserService.shared.updateProfileImage(image: image) { [weak self] profileImageUrl in
            guard let self = self else { return }
            self.user.profileImageUrl = profileImageUrl
            self.delegate?.controller(self, updated: self.user)
        }
    }
    
    // MARK: - Selectors
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSave() {
        view.endEditing(true)
        guard profileImageChanged || userInfoChanged else { return }
        
        updateUserData()
    }
    
    // MARK: - Helpers
    func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .solveColor
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.title = "Editar Perfil"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }
    
    func configureTableView() {
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
        headerView.delegate = self
        
        footerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        tableView.tableFooterView = footerView
        footerView.delegate = self
        
        tableView.register(EditProfileCell.self, forCellReuseIdentifier: editProfileCell)
    }
    
    func configureImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
}

// MARK: - UITableViewDataSource
extension EditProfileViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditProfileOptions.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: editProfileCell, for: indexPath) as! EditProfileCell
        
        cell.delegate = self
        
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return cell }
        cell.editProfileViewModel = EditProfileViewModel(user: user, option: option)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension EditProfileViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return 0 }
        return option == .bio ? 100 : 50
    }
}

// MARK: - EditProfileHeaderDelegate
extension EditProfileViewController: EditProfileHeaderDelegate {
    func didChangeProfilePhoto() {
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        self.selectedImage = image
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - EditProfileCellDelegate
extension EditProfileViewController: EditProfileCellDelegate {
    func updateUserInfo(_ cell: EditProfileCell) {
        guard let viewModel = cell.editProfileViewModel else { return }
        
        userInfoChanged = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        switch viewModel.option {
        case .fullname:
            guard let fullname = cell.infoTextField.text else { return }
            user.fullname = fullname
        case .username:
            guard let username = cell.infoTextField.text else { return }
            user.username = username
        case .bio:
            user.bio = nil
        }
    }
    
}

// MARK: - EditProfileFooterDelegate
extension EditProfileViewController: EditProfileFooterDelegate {
    
    func handleLogout() {
        let alert = UIAlertController(title: nil, message: "Tem certeza que deseja sair?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { _ in
            self.dismiss(animated: true) {
                self.delegate?.handleLogout()
            }
        }))

        alert.addAction(UIAlertAction(title: "Não", style: .default, handler: nil))

        present(alert, animated: true, completion: nil)
    }
}
