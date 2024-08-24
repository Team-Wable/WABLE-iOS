//
//  UIImageView+.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/24/24.
//

import UIKit

import Kingfisher

extension UIImageView {
    func load(url: String) {
        guard let url = URL(string: url) else { return }
        
        self.kf.indicatorType = .activity
        self.kf.setImage(
            with: url,
            placeholder: nil,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ]
        ) { result in
            switch result {
            case .success(let value):
                DispatchQueue.main.async { [weak self] in
                    self?.image = value.image
                    self?.layer.cornerRadius = (self?.frame.size.width ?? 0) / 2.adjusted
                    self?.contentMode = .scaleAspectFill
                    self?.clipsToBounds = true
                }
            case .failure(let error):
                print("Error loading image: \(error)")
                
                DispatchQueue.main.async { [weak self] in
                    self?.layer.cornerRadius = (self?.frame.size.width ?? 0) / 2.adjusted
                    self?.contentMode = .scaleAspectFill
                    self?.clipsToBounds = true
                }
            }
        }
    }
    
    func loadContentImage(url: String) {
        guard let url = URL(string: url) else { return }
        self.kf.indicatorType = .activity
        self.kf.setImage(
            with: url,
            placeholder: nil,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ]
        ) { result in
            switch result {
            case .success(let value):
                DispatchQueue.main.async {
                    self.image = value.image
                    self.layer.cornerRadius = 4.adjusted
                    self.contentMode = .scaleAspectFill
                    self.clipsToBounds = true
                }
            case .failure(let error):
                print("Error loading image: \(error)")
                
                self.layer.cornerRadius = 4.adjusted
                self.contentMode = .scaleAspectFill
                self.clipsToBounds = true
            }
        }
    }
}
