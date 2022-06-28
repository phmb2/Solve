//
//  BankPickerViewController.swift
//  Solve
//
//  Created by Pedro Barbosa on 23/12/21.
//

import UIKit

protocol BankPickerDelegate: AnyObject {
    func selectBankOnTap(_ bank: Bank)
}

class BankPickerViewController: UIViewController {
    // MARK: - Properties
    private let reuseIdentifier = "bankCell"
    var banks = BankService.shared.banks
    var filteredBanks: [Bank] = []
    var searchIsActive: Bool = false
    var selectedBank: Bank?
    weak var bankPickerDelegate: BankPickerDelegate?
    
    private lazy var closeButton: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "xmark")
        imageView.tintColor = .solveColor
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(handleCloseButton))
        imageView.addGestureRecognizer(closeTap)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var selectButton: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle")
        imageView.tintColor = .solveColor
        let selectTap = UITapGestureRecognizer(target: self, action: #selector(handleSelectButton))
        imageView.addGestureRecognizer(selectTap)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.tintColor = .solveColor
        searchBar.placeholder = "Busca por um banco"
        return searchBar
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorColor = .black
        tableView.separatorInset = .zero
        tableView.layoutMargins = .zero
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        constraintsUI()
    }
    
    // MARK: - Selectors
    @objc func handleCloseButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSelectButton() {
        if let bank = selectedBank {
            bankPickerDelegate?.selectBankOnTap(bank)
            navigationController?.popViewController(animated: true)
        } else {
            self.presentAlertOnMainThread(title: "Solve", message: "Por favor, selecione um banco para realizar a reclamação.", buttonTitle: "Ok")
        }
    }
    
    // MARK: - Private Methods
    private func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.title = "Selecionar Banco"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: selectButton)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        self.searchBar.text = ""
        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    private func constraintsUI() {
        searchBar.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: .zero, paddingLeft: .zero, paddingRight: .zero, height: 56)
        
        tableView.anchor(top: searchBar.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: .zero, paddingLeft: .zero, paddingBottom: .zero, paddingRight: .zero)
    }
}

// MARK: - UITableViewDelegate
extension BankPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.textLabel?.textColor = .white
            cell.contentView.backgroundColor = .solveColor
            self.selectedBank = searchIsActive ? filteredBanks[indexPath.row] : banks[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.textLabel?.textColor = .black
            cell.contentView.backgroundColor = .white
        }
    }
}

// MARK: - UITableViewDataSource
extension BankPickerViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchIsActive ? filteredBanks.count : banks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        cell.textLabel?.textAlignment = .center
        
        if cell.isSelected || (self.selectedBank == banks[indexPath.row]) {
            cell.textLabel?.textColor = .white
            cell.contentView.backgroundColor = .solveColor
        } else {
            cell.textLabel?.textColor = .black
            cell.contentView.backgroundColor = .white
        }
        
        if searchIsActive {
            filteredBanks = filteredBanks.sorted(by: { $0.name < $1.name })
            cell.textLabel?.text = "\(filteredBanks[indexPath.row].code) - \(filteredBanks[indexPath.row].name)"
        } else {
            banks = banks.sorted(by: { $0.name < $1.name })
            cell.textLabel?.text = "\(banks[indexPath.row].code) - \(banks[indexPath.row].name)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - UISearchBarDelegate
extension BankPickerViewController: UISearchBarDelegate {
    private func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchIsActive = true;
    }

    private func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchIsActive = false;
    }

    private func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchIsActive = false;
    }

    private func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchIsActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredBanks = banks.filter({ bank -> Bool in
            let tmp: NSString = bank.name as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        
        filteredBanks.count == 0 ? (searchIsActive = false) : (searchIsActive = true)
        
        self.tableView.reloadData()
    }
}

// MARK: - UITextFieldDelegate
extension BankPickerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
