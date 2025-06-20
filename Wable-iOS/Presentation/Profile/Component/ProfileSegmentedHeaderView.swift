//
//  ProfileSegmentedHeaderView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import UIKit

import SnapKit
import Then

final class ProfileSegmentedHeaderView: UICollectionReusableView {
    
    private let segmentedControl = WableSegmentedControl(items: ["게시글", "댓글"]).then {
        $0.selectedSegmentIndex = 0
    }
    
    var onSegmentIndexChanged: ((Int) -> Void)?
    
    private let cancelBag = CancelBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .wableWhite
        setupView()
        setupAction()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let underlineView = UIView(backgroundColor: .gray200)
        
        addSubviews(segmentedControl, underlineView)
        
        segmentedControl.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.adjustedHeightEqualTo(48)
        }
        
        underlineView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func setupAction() {
        segmentedControl.publisher(for: \.selectedSegmentIndex)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] in self?.onSegmentIndexChanged?($0) }
            .store(in: cancelBag)
    }
}
