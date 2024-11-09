//
//  ReuseIdentifiable.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/9/24.
//

import UIKit

protocol ReuseIdentifiable {}

extension ReuseIdentifiable {
    static var identifier: String { String(describing: self) }
}

extension UITableViewCell: ReuseIdentifiable {}
extension UICollectionReusableView: ReuseIdentifiable {}
