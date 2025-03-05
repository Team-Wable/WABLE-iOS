//
//  ReuseIdentifiable.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/4/25.
//

import UIKit

/// `ReuseIdentifiable` 프로토콜은 `UITableViewCell`, `UITableViewHeaderFooterView`, `UICollectionReusableView`의 재사용 식별자(`reuseIdentifier`)를 자동으로 생성하는 기능을 제공합니다.
///
/// - `reuseIdentifier`: 클래스명을 문자열로 변환하여 재사용 식별자로 사용
///
/// 이 확장을 통해 `UITableView` 및 `UICollectionView`에서 셀을 등록하고 재사용할 때 식별자를 별도로 지정하지 않고도 사용할 수 있습니다.
///
/// 사용 예시:
/// ```swift
/// tableView.register(MyTableViewCell.self, forCellReuseIdentifier: MyTableViewCell.reuseIdentifier)
/// let cell = tableView.dequeueReusableCell(withIdentifier: MyTableViewCell.reuseIdentifier, for: indexPath) as! MyTableViewCell
/// ```
protocol ReuseIdentifiable {}

extension ReuseIdentifiable {
    /// 클래스명을 기반으로 한 `reuseIdentifier`를 자동으로 생성합니다.
    ///
    /// - Returns: 현재 클래스명을 문자열로 변환하여 반환
    ///
    /// 사용 예시:
    /// ```swift
    /// let reuseIdentifier = MyCollectionViewCell.reuseIdentifier  // "MyCollectionViewCell"
    /// ```
    static var reuseIdentifier: String { String(describing: self) }
}

extension UITableViewCell: ReuseIdentifiable {}
extension UITableViewHeaderFooterView: ReuseIdentifiable {}
extension UICollectionReusableView: ReuseIdentifiable {}
