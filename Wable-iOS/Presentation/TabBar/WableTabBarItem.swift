//
//  WableTabBarItem.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/8/24.
//

import UIKit

import SnapKit
enum WableTabBarItem: CaseIterable {
    case home
    case info
    case noti
    case my
    
    var icon: UIImage {
        switch self {
        case .home: return ImageLiterals.Icon.icHomeDefault
        case .info: return ImageLiterals.Icon.icInfoDefault
        case .noti: return ImageLiterals.Icon.icNotiDefault
        case .my: return ImageLiterals.Icon.icMyDefault
        }
    }
    
    var selectedIcon: UIImage {
        switch self {
        case .home: return ImageLiterals.Icon.icHomePress
        case .info: return ImageLiterals.Icon.icInfoPress
        case .noti: return ImageLiterals.Icon.icNotiPress
        case .my: return ImageLiterals.Icon.icMyPress
        }
    }
    
    var title: String {
        switch self {
        case .home: return StringLiterals.TabBar.home
        case .info: return StringLiterals.TabBar.info
        case .noti: return StringLiterals.TabBar.noti
        case .my: return StringLiterals.TabBar.my
        }
    }
    
    var targetViewController: UIViewController? {
        switch self {
        case .home: return HomeViewController(viewModel: HomeViewModel(), likeViewModel: LikeViewModel(networkProvider: NetworkService()))
        case .info: return InfoViewController()
        case .noti: return NotificationViewController()
        case .my: return MyPageViewController(viewModel: MyPageViewModel(networkProvider: NetworkService()), likeViewModel: LikeViewModel(networkProvider: NetworkService()))
        }
    }
}
