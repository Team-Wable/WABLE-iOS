//
//  UITextView+.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/23/24.
//

import UIKit

import SnapKit

extension UITextView {
    func addPlaceholder(_ placeholder: String, padding: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)) {
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholder
        placeholderLabel.textColor = .gray500
        placeholderLabel.textAlignment = .left
        placeholderLabel.font = self.font
        placeholderLabel.numberOfLines = 0

        self.addSubview(placeholderLabel)

        placeholderLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(padding)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(textViewTextDidChange), name: UITextView.textDidChangeNotification, object: nil)

        updatePlaceholderVisibility(placeholderLabel)
    }

    @objc private func textViewTextDidChange() {
        for subview in self.subviews {
            if let placeholderLabel = subview as? UILabel, placeholderLabel.textColor == .gray500 {
                updatePlaceholderVisibility(placeholderLabel)
            }
        }
    }

    private func updatePlaceholderVisibility(_ placeholderLabel: UILabel) {
        placeholderLabel.isHidden = !self.text.isEmpty
    }
}
