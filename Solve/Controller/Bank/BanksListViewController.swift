//
//  BanksViewController.swift
//  Solve
//
//  Created by Pedro Barbosa on 11/01/22.
//

import UIKit

class BanksListViewController: UIViewController {
    // MARK: - Properties
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(BankCell.self, forCellReuseIdentifier: BankCell.reuseId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.layoutMargins = .zero
        tableView.rowHeight = 100
    
        return tableView
    }()
    
    var banksData: [Bank] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        banksData = BankService.shared.banks.sorted(by: { $0.name < $1.name })
    }
    
    // MARK: - Private Methods
    private func configureUI() {
        navigationItem.title = "Bancos"
        view.addSubview(tableView)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension BanksListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return banksData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BankCell.reuseId) as? BankCell,
              indexPath.row < banksData.count
        else { return UITableViewCell() }
        
        let bank = banksData[indexPath.row]
        cell.setBank(bank: bank)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bank = banksData[indexPath.row]
        guard let url = URL(string: bank.url) else {
            presentAlertOnMainThread(title: "URL inválida", message: "A url pesquisada é inválida.", buttonTitle: "Ok")
            return
        }
        
        openSafariViewController(with: url)
    }
}
