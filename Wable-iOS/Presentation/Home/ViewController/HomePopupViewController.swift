//
//  HomePopupViewController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 1/12/25.
//

import Combine
import UIKit

import CombineCocoa
import SnapKit

final class HomePopupViewController: UIViewController {
    
    // MARK: - Properties
    
    var deleteButtonDidTapAction: ((Int) -> Void)?
    var ghostButtonDidTapAction: ((Int) -> Void)?
    var banButtonDidTapAction: ((Int) -> Void)?
    var reportButtonDidTapAction: (() -> Void)?
    
    private let viewModel: PopupViewModel
    private let rootView: WablePopupView
    private let cancelBag = CancelBag()
    
    private let deleteButtonTapSubject = PassthroughSubject<Void, Never>()
    private let reportButtonDidTapSubject = PassthroughSubject<Void, Never>()
    private let banButtonDidTapSubject = PassthroughSubject<Void, Never>()
    private let ghostButtonDidTapSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Initializer
    
    init(viewModel: PopupViewModel, popupType: PopupViewType) {
        self.viewModel = viewModel
        self.rootView = WablePopupView(popupType: popupType)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycles
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        rootView.delegate = self
    }
}

private extension HomePopupViewController {
    func setupBinding() {
        let input = PopupViewModel.Input(
            deleteButtonDidTap: deleteButtonTapSubject.eraseToAnyPublisher(),
            reportButtonDidTap: reportButtonDidTapSubject.eraseToAnyPublisher(),
            banButtonDidTap: banButtonDidTapSubject.eraseToAnyPublisher(),
            ghostButtonDidTap: ghostButtonDidTapSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.dismissView
            .receive(on: RunLoop.main)
            .sink { [weak self] data, type in
                guard let self else { return }
                dismiss(animated: true)
                switch type {
                case .delete:
                    deleteButtonDidTap()
                case .report:
                    reportButtonDidTap()
                case .ghost:
                    ghostButtonDidTap()
                case .ban:
                    banButtonDidTap()
                }
            }
            .store(in: cancelBag)
    }
}

extension HomePopupViewController {
    
    func deleteButtonDidTap() {
        deleteButtonDidTapAction?(viewModel.data.contentID ?? -1)
    }
    
    func reportButtonDidTap() {
        reportButtonDidTapAction?()
    }
    
    func ghostButtonDidTap() {
        ghostButtonDidTapAction?(viewModel.data.memberID)
    }
    
    func banButtonDidTap() {
        banButtonDidTapAction?(viewModel.data.memberID)
    }
}

// MARK: - WablePopupDelegate

extension HomePopupViewController: WablePopupDelegate {
    func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    func confirmButtonTapped() {
        switch rootView.popupType {
        case .delete:
            deleteButtonTapSubject.send(())
        case .report:
            reportButtonDidTapSubject.send(())
        case .ghost:
            ghostButtonDidTapSubject.send(())
        case .ban:
            banButtonDidTapSubject.send(())
        }
    }
    
    func singleButtonTapped() {
        self.dismiss(animated: true)
    }

}
