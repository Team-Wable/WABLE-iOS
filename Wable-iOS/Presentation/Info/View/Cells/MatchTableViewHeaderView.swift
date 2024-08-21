//
//  MatchTableViewHeaderView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/20/24.
//

import UIKit

import SnapKit

final class MatchTableViewHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    
    static let identifier = "MatchTableViewHeaderView"
    
    // MARK: - Components
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "07. 18 (목)"
        label.font = .head2
        label.textColor = .wableBlack
        return label
    }()
    // MARK: - inits
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setHierarchy()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Functions

    private func setHierarchy() {
        self.contentView.addSubview(dateLabel)
    }
    
    private func setLayout() {
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(16.adjusted)
        }
    }
    
    // 나중에 ViewModel에서 사용
//    private func dateFomatter(date: String, _ to: String) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" // 서버로부터 받은 날짜 형식
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 시간대 일관성을 위해 사용
//
//        // 문자열을 Date 객체로 변환
//        if let date = dateFormatter.date(from: date) {
//            // 날짜만 추출
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            let dateString = dateFormatter.string(from: date)
//
//            // 시간만 추출
//            dateFormatter.dateFormat = "HH:mm"
//            let timeString = dateFormatter.string(from: date)
//
//            // 결과 출력
//            print("Date: \(dateString)") // 출력: Date: 2024-08-22
//            print("Time: \(timeString)") // 출력: Time: 16:07
//        } else {
//            print("잘못된 날짜 형식입니다.")
//        }
//    }
    
    func bind(isToday: Bool, date: String) {
        if isToday {
            dateLabel.text = StringLiterals.Info.today + date
            dateLabel.asColor(targetString: StringLiterals.Info.today, color: .info)
        } else {
            dateLabel.text = date
        }
    }
}
