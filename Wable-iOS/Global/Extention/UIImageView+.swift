//
//  UIImageView+.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/24/24.
//

import UIKit

import Kingfisher

extension UIImageView {
    
    // 기본 이미지 딕셔너리 고정
    private var defaultImages: [UIImage : String] {
        return [
            ImageLiterals.Image.imgProfile1 : "PURPLE",
            ImageLiterals.Image.imgProfile2 : "BLUE",
            ImageLiterals.Image.imgProfile3 : "GREEN"
        ]
    }
    
    func load(url: String) {
        // "PURPLE", "BLUE", "GREEN"과 같은 값을 처리
        if let defaultImage = defaultImages.first(where: { $0.value == url })?.key {
            // 기본 이미지 적용
            self.image = defaultImage
            self.layer.cornerRadius = self.frame.size.width / 2.adjusted
            self.contentMode = .scaleAspectFill
            self.clipsToBounds = true
        } else if let imageURL = URL(string: url) {
            self.kf.indicatorType = .activity
            self.kf.setImage(
                with: imageURL,
                placeholder: nil,
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage
                ]) { result in
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
                    self.layer.cornerRadius = 8.adjusted
                    self.contentMode = .scaleAspectFill
                    self.clipsToBounds = true
                }
            case .failure(let error):
                print("Error loading image: \(error)")
                
                self.layer.cornerRadius = 8.adjusted
                self.contentMode = .scaleAspectFill
                self.clipsToBounds = true
            }
        }
    }
    
    func loadContentImage(url: String, completion: @escaping (UIImage) -> Void) {
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
                    self.layer.cornerRadius = 8.adjusted
                    self.contentMode = .scaleAspectFill
                    self.clipsToBounds = true
                    
                    // 이미지 로드 후 completion 핸들러 호출
                    completion(value.image)
                }
            case .failure(let error):
                print("Error loading image: \(error)")
                
                DispatchQueue.main.async {
                    self.layer.cornerRadius = 8.adjusted
                    self.contentMode = .scaleAspectFill
                    self.clipsToBounds = true
                }
            }
        }
    }
}
