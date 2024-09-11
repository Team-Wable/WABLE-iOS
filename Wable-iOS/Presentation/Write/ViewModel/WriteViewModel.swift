//
//  WriteViewModel.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/23/24.
//

import Combine
import Foundation
import UIKit

final class WriteViewModel: ViewModelType {
    
    private let cancelBag = CancelBag()
    private let networkProvider: NetworkServiceType
    
    private let pushOrPopViewController = PassthroughSubject<Int, Never>()
    
    struct Input {
        let postButtonTapped: AnyPublisher<WriteContentImageRequestDTO, Never>
    }
    
    struct Output {
        let pushOrPopViewController: PassthroughSubject<Int, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.postButtonTapped
            .sink { value in
                Task {
                    do {
                        try await self.postWriteContentAPI(
                            contentTitle: value.contentTitle,
                            contentText: value.contentText,
                            photoImage: value.photoImage
                        )
                        self.pushOrPopViewController.send(1)
                    } catch {
                        print("Error posting content:", error)
                    }
                }
            }
            .store(in: cancelBag)
        
        return Output(pushOrPopViewController: pushOrPopViewController)
    }
    
    init(networkProvider: NetworkServiceType) {
        self.networkProvider = networkProvider
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WriteViewModel {
    private func postWriteContentAPI(contentTitle: String, contentText: String, photoImage: UIImage?) async throws -> Void {
        guard let url = URL(string: Config.baseURL + "v2/content") else { return }
        guard let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") else { return }
        
        let parameters: [String: Any] = [
            "contentTitle": contentTitle,
            "contentText": contentText
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Multipart form data 생성
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        var requestBodyData = Data()
        
        // 게시글 본문 데이터 추가
        requestBodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
        requestBodyData.append("Content-Disposition: form-data; name=\"text\"\r\n\r\n".data(using: .utf8)!)
        requestBodyData.append(try! JSONSerialization.data(withJSONObject: parameters, options: []))
        requestBodyData.append("\r\n".data(using: .utf8)!)
        
        if let image = photoImage {
            let imageData = image.jpegData(compressionQuality: 0.1)!
            
            // 게시글 이미지 데이터 추가
            requestBodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
            requestBodyData.append("Content-Disposition: form-data; name=\"image\"; filename=\"dontbe.jpeg\"\r\n".data(using: .utf8)!)
            requestBodyData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            requestBodyData.append(imageData)
            requestBodyData.append("\r\n".data(using: .utf8)!)
        }
        
        requestBodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // HTTP body에 데이터 설정
        request.httpBody = requestBodyData
        
        // URLSession으로 비동기 요청 보내기
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 응답 처리
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        print("Response status code:", httpResponse.statusCode)
        
        if httpResponse.statusCode != 201 {
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed with status code \(httpResponse.statusCode)"])
        }
        
        guard let responseString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty response"])
        }
        
        print("Response data:", responseString)  // 서버 응답 데이터를 처리한 후 출력
        
        return
    }
}
