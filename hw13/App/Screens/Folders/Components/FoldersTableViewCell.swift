//
//  FoldersTableViewCell.swift
//  hw13
//
//  Created by Chernousova Maria on 26.10.2021.
//

import UIKit

final class CustomTableViewCell: UITableViewCell {
    private enum Constant {
        static let imageInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 0)
        static let titleInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 12)
        static let infoButtonInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 20)
        static let folderImageSystemName = "folder"
        static let infoButtonSystemName = "info.circle"
    }
    
    private(set) lazy var folderImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: Constant.folderImageSystemName)
        return imageView
    }()
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .preferredFont(forTextStyle: .body,
                                    compatibleWith: .current)
        return label
    }()
    
    private(set) lazy var infoButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(systemName: Constant.infoButtonSystemName),
                        for: .normal)
        button.addTarget(self,
                         action: #selector(infoButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    var completionHandler: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        setupAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
        setupAutoLayout()
    }
    
    private func setupSubviews() {
        contentView.addSubview(folderImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoButton)
        
        contentView.backgroundColor = .systemBackground
    }
    
    private func setupAutoLayout() {
        folderImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            folderImageView.widthAnchor.constraint(equalTo: folderImageView.heightAnchor),
            folderImageView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                                 constant: Constant.imageInsets.top),
            folderImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                     constant: Constant.imageInsets.left),
            folderImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                    constant: -Constant.imageInsets.bottom),
            
            titleLabel.topAnchor.constraint(equalTo: folderImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: folderImageView.trailingAnchor,
                                                constant: Constant.titleInsets.left),
            titleLabel.bottomAnchor.constraint(equalTo: folderImageView.bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: infoButton.leadingAnchor,
                                                 constant: -Constant.titleInsets.right),

            infoButton.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            infoButton.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            infoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                 constant: -Constant.infoButtonInsets.right)
        ])
    }
    
    @objc private func infoButtonTapped() {
        completionHandler?()
    }
}
