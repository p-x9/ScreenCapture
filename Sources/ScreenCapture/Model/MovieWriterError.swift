//
//  MovieWriterError.swift
//  
//
//  Created by p-x9 on 2023/05/20.
//  
//

import Foundation

enum MovieWriterError: Error {
    case notStarted
    case alreadyRunning
    case failedToStart
    case failedToAppendBuffer
    case invalidTime
    case notReadyForWriteMoreData
}
