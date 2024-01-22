//
//  UIView+Ext.swift
//  GHFolowers
//
//  Created by Sylvain Druaux on 22/01/2024.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}
