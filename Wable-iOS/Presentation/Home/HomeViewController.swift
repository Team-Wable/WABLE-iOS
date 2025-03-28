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
    
    /// Called after the view controller's view is loaded into memory.
    /// 
    /// In addition to the default setup, this method asynchronously fetches a content list using the content repository.
    /// The fetch operation is performed with a cursor of -1 and its results are received on the main dispatch queue.
    /// Upon completion, a debug message is logged, and when data is received, it is printed to the console.
    /// The Combine subscription is stored in the cancel bag to manage its lifecycle.
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
