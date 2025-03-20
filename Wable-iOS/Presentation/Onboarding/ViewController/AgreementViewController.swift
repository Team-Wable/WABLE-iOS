//
//  AgreementViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/21/25.
//


import SafariServices
import UIKit

final class AgreementViewController: NavigationViewController {
    
    // MARK: - UIComponent
    
    private let rootView = AgreementView()
    
    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupAction()
    }
}

// MARK: - Priviate Extension

private extension AgreementViewController {
    
    // MARK: - Setup Method
    
    func setupView() {
        view.addSubview(rootView)
    }
    
    func setupConstraint() {
        rootView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    func setupAction() {
        [
            rootView.personalInfoAgreementItemView.checkButton,
            rootView.privacyPolicyAgreementItemView.checkButton,
            rootView.ageAgreementItemView.checkButton,
            rootView.marketingAgreementItemView.checkButton
        ].forEach {
            $0.addTarget(self, action: #selector(checkButtonDidTap(_:)), for: .touchUpInside)
        }
        rootView.personalInfoAgreementItemView.infoButton.addTarget(self, action: #selector(infoButtonDidTap(_:)), for: .touchUpInside)
        rootView.privacyPolicyAgreementItemView.infoButton.addTarget(self, action: #selector(infoButtonDidTap(_:)), for: .touchUpInside)
        rootView.allAgreementItemView.checkButton.addTarget(self, action: #selector(allCheckButtonDidTap), for: .touchUpInside)
        rootView.nextButton.addTarget(self, action: #selector(nextButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - @objc Method
    
    @objc func checkButtonDidTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        configureNextButton()
    }
    
    @objc func infoButtonDidTap(_ sender: UIButton) {
        guard let url = URL(
            string: sender == rootView.personalInfoAgreementItemView.infoButton ? "https://joyous-ghost-8c7.notion.site/c6e26919055a4ff98fd73a8f9b29cb36?pvs=4" : "https://joyous-ghost-8c7.notion.site/fff08b005ea18052ae0bf9d056c2e830?pvs=4"
        ) else {
            return
        }
        
        let viewController = SFSafariViewController(url: url)
        viewController.modalPresentationStyle = .formSheet
        
        self.present(viewController, animated: true)
    }
    
    @objc func allCheckButtonDidTap() {
        rootView.allAgreementItemView.checkButton.isSelected.toggle()
        
        [
            rootView.personalInfoAgreementItemView.checkButton,
            rootView.privacyPolicyAgreementItemView.checkButton,
            rootView.ageAgreementItemView.checkButton,
            rootView.marketingAgreementItemView.checkButton
        ].forEach {
            $0.isSelected = rootView.allAgreementItemView.checkButton.isSelected
        }
        
        configureNextButton()
    }
    
    @objc func nextButtonDidTap() {
        navigationController?.pushViewController(AgreementViewController(type: .flow), animated: true)
    }
    
    // MARK: - Function Method
    
    func configureNextButton() {
        let condition = rootView.personalInfoAgreementItemView.checkButton.isSelected
        && rootView.privacyPolicyAgreementItemView.checkButton.isSelected
        && rootView.ageAgreementItemView.checkButton.isSelected
        
        rootView.nextButton.isUserInteractionEnabled = condition
        rootView.nextButton.updateStyle(condition ? .primary : .gray)
    }
}
