//
//  FollowerCell.swift
//  GHFollowers
//
//  Created by Sylvain Druaux on 22/08/2023.
//

import SwiftUI
import UIKit

class FollowerCell: UICollectionViewCell {
    static let reuseID = "FollowerCell"
    private let avatarImageView = GFAvatarImageView(frame: .zero)
    private let usernameLabel = GFTitleLabel(textAlignment: .center, fontSize: 16)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(follower: Follower) {
        if #available(iOS 16.0, *) {
            contentConfiguration = UIHostingConfiguration { FollowerView(follower: follower) }
        } else {
            usernameLabel.text = follower.login
            avatarImageView.downloadImage(fromURL: follower.avatarUrl)
        }
    }

    private func configure() {
        addSubviews(avatarImageView, usernameLabel)
        let padding: CGFloat = 8

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            avatarImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),

            usernameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            usernameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            usernameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            usernameLabel.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
}
