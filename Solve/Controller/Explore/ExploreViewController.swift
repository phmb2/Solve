//
//  ExploreViewController.swift
//  Solve
//
//  Created by Pedro Barbosa on 22/11/21.
//

import UIKit

enum SearchControllerConfiguration {
    case messages
    case users
}

class ExploreViewController: UITableViewController {
    // MARK: - Properties
    private let config: SearchControllerConfiguration
    
    private var users = [User]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var filteredUsers = [User]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle
    init(config: SearchControllerConfiguration) {
        self.config = config
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchUsers()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - API Service
    func fetchUsers() {
        UserService.shared.fetchUsers { [weak self] users in
            guard let self = self else { return }
            self.users = users
        }
    }
    
    // MARK: - Selectors
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        
        navigationItem.title = config == .messages ? "Nova mensagem" : "Busca"
        UISearchBar.appearance().tintColor = .solveColor
        searchController.searchBar.setValue("Cancelar", forKey: "cancelButtonText")
        
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseId)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        if config == .messages {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        }
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Busca por um usuário"
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
}

// MARK: - UITableViewDelegate/Datasource
extension ExploreViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredUsers.count : users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseId, for: indexPath) as! UserCell
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        cell.selectionStyle = .none
        cell.user = user
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        let controller = ProfileViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension ExploreViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filteredUsers = users.filter({$0.username.contains(searchText) || $0.fullname.contains(searchText)})
//        if filteredUsers.count == 0 {
//            self.showEmptyStateView(with: "Busca não encontrada.", in: self.view)
//        }
    }
}
