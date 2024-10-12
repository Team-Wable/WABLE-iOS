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
                         contentLabel)
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
    
    func bind(title: String, content: String, image: String?) {
        titleLabel.text = title
        contentLabel.text = content
        photoImageView.loadContentImage(url: image ?? "")
        if image != "" {
            photoImageView.isHidden = false
            
            photoImageView.snp.remakeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(10.adjusted)
                $0.height.equalTo(192.adjusted)
                $0.leading.trailing.equalToSuperview()
            }
            
            contentLabel.snp.remakeConstraints {
                $0.top.equalTo(photoImageView.snp.bottom).offset(10.adjusted)
                $0.leading.trailing.bottom.equalToSuperview()
            }
        } else {
            photoImageView.isHidden = true
            contentLabel.snp.remakeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(4.adjusted)
                $0.leading.trailing.bottom.equalToSuperview()
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
    
    // 탭 제스처 처리 함수
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
        
        // 하이퍼링크가 아닌 부분을 클릭한 경우에만 `didSelectRowAt` 호출
        if !isLinkTapped, let tableView = self.superview(of: UITableView.self), let cell = self.superview(of: UITableViewCell.self), let indexPath = tableView.indexPath(for: cell) {
            tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
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
        
        // 하이퍼링크가 아닌 부분을 클릭한 경우에만 `didSelectRowAt` 호출
        if !isLinkTapped, let tableView = self.superview(of: UITableView.self), let cell = self.superview(of: UITableViewCell.self), let indexPath = tableView.indexPath(for: cell) {
            tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
        }
    }
}
