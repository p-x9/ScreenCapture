//
//  CMTime+.swift
//  
//
//  Created by p-x9 on 2023/06/02.
//  
//

import Foundation
import CoreMedia

extension CMTime {
    static var current: CMTime {
        current()
    }
    
    static func current(clock: CMClock = CMClockGetHostTimeClock()) -> CMTime {
        CMClockGetTime(clock)
    }
}
