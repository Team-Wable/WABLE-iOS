//
//  String+.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import Foundation

extension String {
    // 글자가 자음인지 체크
    var isConsonant: Bool {
        guard let scalar = UnicodeScalar(self)?.value else {
            return false
        }
        let consonantScalarRange: ClosedRange<UInt32> = 12593...12622
        return consonantScalarRange ~= scalar
    }
    
    // 특정 글자수를 넘어가면 ... 처리
    func truncated(to length: Int) -> String {
        guard self.count > length else { return self }
        
        let endIndex = self.index(self.startIndex, offsetBy: length)
        return String(self[..<endIndex]) + "..."
    }
}
