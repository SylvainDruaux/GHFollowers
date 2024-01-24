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

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(follower: Follower) {
        contentConfiguration = UIHostingConfiguration { FollowerView(follower: follower) }
    }
}
