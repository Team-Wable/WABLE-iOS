//
//  FeedContentView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/17/24.
//

import UIKit

import SnapKit

final class FeedContentView: UIView {
    
    // MARK: - UI Components
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .wableBlack
        label.font = .head2
        label.numberOfLines = 0
        return label
    }()
    
    var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    var contentLabel: CopyableLabel = {
        let label = CopyableLabel()
        label.lineBreakMode = .byCharWrapping
        label.textColor = .gray800
        label.font = .body4
        label.numberOfLines = 0
        return label
    }()
    
    let blindImageView: UIImageView = {
        let imageView = UIImageView(image: ImageLiterals.Image.imgFeedIsBlind)
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = true
        return imageView
    }()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setHierarchy()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension FeedContentView {
    private func setHierarchy() {
        self.addSubviews(titleLabel,
                         photoImageView,
                         contentLabel,
                         blindImageView)
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        photoImageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10.adjusted)
            $0.height.equalTo(192.adjusted)
            $0.leading.trailing.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(photoImageView.snp.bottom).offset(10.adjusted)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    
    // URL을 하이퍼링크로 바꾸는 함수
    private func attributedString(for text: String) -> NSAttributedString {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return NSAttributedString(string: text)
        }
        
        let attributedString = NSMutableAttributedString(string: text)
        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        for match in matches {
            guard let range = Range(match.range, in: text) else { continue }
            let url = text[range]
            attributedString.addAttribute(.link, value: url, range: NSRange(range, in: text))
        }
        
        return attributedString
    }
    
    func bind(title: String, content: String, image: String?, isBlind: Bool?) {
        isFeedBlind(isBlind: isBlind ?? false)
        guard isBlind == false else { return }
        
        titleLabel.text = title
        contentLabel.text = content
        photoImageView.loadContentImage(url: image ?? "")
        
        if image != "" {
            // 이미지 o
            photoImageView.isHidden = false
            
            if title == "" {
                // 제목 + 이미지
                contentLabel.isHidden = true
                photoImageView.snp.remakeConstraints {
                    $0.top.equalTo(titleLabel.snp.bottom).offset(10.adjusted)
                    $0.height.equalTo(192.adjusted)
                    $0.leading.trailing.bottom.equalToSuperview()
                }
                
                contentLabel.snp.remakeConstraints {
                    $0.height.equalTo(0)
                }
            } else {
                // 제목 + 이미지 + 본문
                contentLabel.isHidden = false

                photoImageView.snp.remakeConstraints {
                    $0.top.equalTo(titleLabel.snp.bottom).offset(10.adjusted)
                    $0.height.equalTo(192.adjusted)
                    $0.leading.trailing.equalToSuperview()
                }
                
                contentLabel.snp.remakeConstraints {
                    $0.top.equalTo(photoImageView.snp.bottom).offset(10.adjusted)
                    $0.leading.trailing.bottom.equalToSuperview()
                }
            }
            
        } else {
            // 이미지 x
            photoImageView.isHidden = true
            
            if title == "" {
                // 제목
                contentLabel.isHidden = true
                self.snp.remakeConstraints {
                    $0.bottom.equalTo(titleLabel.snp.bottom)
                }
                
                photoImageView.snp.remakeConstraints {
                    $0.height.equalTo(0)
                }
                
                contentLabel.snp.remakeConstraints {
                    $0.height.equalTo(0)
                }
                
            } else {
                // 제목 + 본문
                contentLabel.isHidden = false

                photoImageView.snp.remakeConstraints {
                    $0.height.equalTo(0)
                }
                contentLabel.snp.remakeConstraints {
                    $0.top.equalTo(titleLabel.snp.bottom).offset(4.adjusted)
                    $0.leading.trailing.bottom.equalToSuperview()
                }
            }
        }
        
        titleLabel.attributedText = attributedString(for: title)
        contentLabel.attributedText = attributedString(for: content)
        
        let tapTitleLabelGesture = UITapGestureRecognizer(target: self, action: #selector(handleTitleLabelTap(_:)))
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(tapTitleLabelGesture)
        
        let tapContentLabelGesture = UITapGestureRecognizer(target: self, action: #selector(handleContentLabelTap(_:)))
        contentLabel.isUserInteractionEnabled = true
        contentLabel.addGestureRecognizer(tapContentLabelGesture)

    }
    
    private func isFeedBlind(isBlind: Bool) {
        contentLabel.isHidden = isBlind
        titleLabel.isHidden = isBlind
        photoImageView.isHidden = isBlind
        blindImageView.isHidden = !isBlind
        if isBlind {
            
            titleLabel.removeConstraints(blindImageView.constraints)
            photoImageView.removeConstraints(blindImageView.constraints)
            contentLabel.removeConstraints(blindImageView.constraints)
            
            blindImageView.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(98.adjustedH)
            }
            
        } else {
            
            blindImageView.removeConstraints(blindImageView.constraints)
            
            titleLabel.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview()
            }
            
            photoImageView.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(10.adjusted)
                $0.height.equalTo(192.adjusted)
                $0.leading.trailing.equalToSuperview()
            }
            
            contentLabel.snp.makeConstraints {
                $0.top.equalTo(photoImageView.snp.bottom).offset(10.adjusted)
                $0.leading.trailing.bottom.equalToSuperview()
            }
        }
    }
    
    @objc func handleTitleLabelTap(_ gesture: UITapGestureRecognizer) {
        guard let attributedText = titleLabel.attributedText else { return }
        
        let location = gesture.location(in: titleLabel)
        let index = titleLabel.indexOfAttributedTextCharacterAtPoint(point: location)
        
        var isLinkTapped = false

        attributedText.enumerateAttribute(.link, in: NSRange(location: 0, length: attributedText.length), options: []) { value, range, _ in
            if let url = value as? String, NSLocationInRange(index, range) {
                var urlString = url
                if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
                    urlString = "https://\(urlString)"
                }
                if let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                }
                isLinkTapped = true
            }
        }
        
        if !isLinkTapped,
           let collectionView = self.superview(of: UICollectionView.self),
           let cell = self.superview(of: UICollectionViewCell.self),
           let indexPath = collectionView.indexPath(for: cell) {
            
            collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
        }
    }
    
    @objc func handleContentLabelTap(_ gesture: UITapGestureRecognizer) {
        guard let attributedText = contentLabel.attributedText else { return }
        
        let location = gesture.location(in: contentLabel)
        let index = contentLabel.indexOfAttributedTextCharacterAtPoint(point: location)
        
        var isLinkTapped = false

        attributedText.enumerateAttribute(.link, in: NSRange(location: 0, length: attributedText.length), options: []) { value, range, _ in
            if let url = value as? String, NSLocationInRange(index, range) {
                var urlString = url
                if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
                    urlString = "https://\(urlString)"
                }
                if let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                }
                isLinkTapped = true
            }
        }
        
        if !isLinkTapped,
           let collectionView = self.superview(of: UICollectionView.self),
           let cell = self.superview(of: UICollectionViewCell.self),
           let indexPath = collectionView.indexPath(for: cell) {
            
            collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
        }
    }
}
