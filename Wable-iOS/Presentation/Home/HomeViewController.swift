//
//  HomeViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/10/25.
//


import UIKit

final class HomeViewController: UIViewController {
    
    // MARK: Property

    let contentRepostiory: ContentRepository
    let cancelBag = CancelBag()
    
    // MARK: - LifeCycle

    init(contentRepostiory: ContentRepository) {
        self.contentRepostiory = contentRepostiory
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentRepostiory.fetchContentList(cursor: -1)
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { completion in
                WableLogger.log("fetchContentList 실행 완", for: .debug)
            } receiveValue: { owner, list in
                print(list)
            }
            .store(in: cancelBag)
    }
}
