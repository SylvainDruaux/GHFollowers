//
//  GFAvatarImageView.swift
//  GHFolowers
//
//  Created by Sylvain Druaux on 22/08/2023.
//

import UIKit

class GFAvatarImageView: UIImageView {
    private let placeholderImage = Images.avatarPlaceholder

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
        image = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
    }

    func downloadImage(fromURL url: String) {
        NetworkManager.shared.downloadImage(from: url) { [weak self] image in
            guard let self else { return }
            DispatchQueue.main.async { self.image = image }
        }
    }
}
