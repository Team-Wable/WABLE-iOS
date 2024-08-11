//
//  Adjusted+.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/6/24.
//

import UIKit

extension CGFloat {
    var adjusted: CGFloat {
        return adjustedW
    }

    var adjustedW: CGFloat {
        return self * adjustedRatio
    }

    var adjustedH: CGFloat {
        return self * adjustedHRatio
    }

    private var adjustedRatio: CGFloat {
        return UIScreen.main.bounds.width / 375
    }

    private var adjustedHRatio: CGFloat {
        return UIScreen.main.bounds.height / 667
    }
}

extension Int {
    var adjusted: CGFloat {
        return CGFloat(self).adjusted
    }

    var adjustedW: CGFloat {
        return CGFloat(self).adjustedW
    }

    var adjustedH: CGFloat {
        return CGFloat(self).adjustedH
    }
}

extension Double {
    var adjusted: CGFloat {
        return CGFloat(self).adjusted
    }

    var adjustedW: CGFloat {
        return CGFloat(self).adjustedW
    }

    var adjustedH: CGFloat {
        return CGFloat(self).adjustedH
    }
}
