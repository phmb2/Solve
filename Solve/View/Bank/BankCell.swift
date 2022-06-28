//
//  BankCell.swift
//  Solve
//
//  Created by Pedro Barbosa on 12/01/22.
//

import UIKit

class BankCell: UITableViewCell {
    // MARK: - Properties
    static let reuseId = "BankCell"
    
    let padding: CGFloat = 12
    
    private lazy var bankNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private lazy var bankComplaintsCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
    }
    
    func setBank(bank: Bank) {
        bankNameLabel.text = "\(bank.code) - \(bank.name)"
        bankComplaintsCountLabel.text = "0 reclamações"
    }
    
    // MARK: - Private Methods
    private func configureUI() {
        contentView.backgroundColor = .solveColor
        contentView.layer.cornerRadius = 8.0
        
        contentView.addSubview(bankNameLabel)
        contentView.addSubview(bankComplaintsCountLabel)
        
        bankNameLabel.centerX(inView: contentView, topAnchor: contentView.topAnchor, paddingTop: padding)
        bankNameLabel.anchor(left: contentView.leftAnchor, right: contentView.rightAnchor, paddingLeft: padding, paddingRight: padding)
        
        bankComplaintsCountLabel.centerX(inView: bankNameLabel, topAnchor: bankNameLabel.bottomAnchor, paddingTop: padding)
        bankComplaintsCountLabel.anchor(left: contentView.leftAnchor, right: contentView.rightAnchor, paddingLeft: padding, paddingRight: padding)
    }
}
