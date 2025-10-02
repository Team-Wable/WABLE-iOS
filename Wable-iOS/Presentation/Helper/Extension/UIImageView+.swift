//
//  UIImageView+.swift
//  Wable-iOS
//
//  Created by YOUJIM on 10/1/25.
//

import Kingfisher
import UIKit

extension UIImageView {
    func setProfileImage(with url: URL?, placeholder: UIImage? = nil) {
        guard let url else {
            self.image = placeholder ?? DefaultProfileType.random().image
            return
        }

        if let defaultType = DefaultProfileType.from(uppercased: url.absoluteString) {
            self.image = defaultType.image
        } else {
            self.kf.setImage(
                with: url,
                placeholder: placeholder ?? DefaultProfileType.random().image
            )
        }
    }
}
