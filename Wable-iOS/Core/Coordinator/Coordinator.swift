//
//  Coordinator.swift
//  Wable-iOS
//
//  Created by 김진웅 on 9/12/25.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}