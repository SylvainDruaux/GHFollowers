//
//  GFFollowerItemVC.swift
//  GHFollowers
//
//  Created by Sylvain Druaux on 20/01/2024.
//

import UIKit

protocol GFFollowerItemVCDelegate: AnyObject {
    func didTapGetFollowers(for user: User)
}

class GFFollowerItemVC: GFItemInfoVC {
    weak var delegate: GFFollowerItemVCDelegate!

    init(user: User, delegate: GFFollowerItemVCDelegate!) {
        super.init(user: user)
        self.delegate = delegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()
    }

    private func configureItems() {
        itemInfoViewOne.set(itemInfoType: .followers, with: user.followers)
        itemInfoViewTwo.set(itemInfoType: .following, with: user.following)
        actionButton.set(color: .systemGreen, title: "Get Followers", systemImage: SFSymbols.person3)
    }

    override func actionButtonTapped() {
        delegate.didTapGetFollowers(for: user)
    }
}
