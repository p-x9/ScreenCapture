//
//  UIInterfaceOrientation+.swift
//  
//
//  Created by p-x9 on 2023/05/21.
//  
//

import UIKit

extension UIInterfaceOrientation {
    var angle: CGFloat? {
        switch self {
        case .unknown:
            return nil
        case .portrait:
            return 0
        case .portraitUpsideDown:
            return .pi
        case .landscapeLeft:
            return .pi / 2
        case .landscapeRight:
            return 3 * .pi / 2
        @unknown default:
            fatalError()
        }
    }

    func angle(to toOrientation: UIInterfaceOrientation) -> CGFloat? {
        guard let from = angle,
              let to = toOrientation.angle else {
            return nil
        }

        return to - from
    }
}

extension UIInterfaceOrientation {
    var numberOfRightAngleRotations: Int?{
        switch self {
        case .unknown:
            return nil
        case .portrait:
            return 0
        case .portraitUpsideDown:
            return 2
        case .landscapeLeft:
            return 1
        case .landscapeRight:
            return 3
        @unknown default:
            fatalError()
        }
    }

    func numberOfRightAngleRotations(to toOrientation: UIInterfaceOrientation) -> Int? {
        guard let from = numberOfRightAngleRotations,
              let to = toOrientation.numberOfRightAngleRotations else {
            return nil
        }

        return to - from
    }
}
