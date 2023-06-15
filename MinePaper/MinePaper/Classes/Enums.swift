//
//  Enums.swift
//  MinePaper
//
//  Created by Timothy Lickteig on 6/7/23.
//

import Foundation

enum DownloadStatus {
    case Success
    case NetworkError
    case FileWriteError
    case InputDataError
}

enum NetworkError: Error {
    case GeneralError
    case DataFormatError
    case InputDataError
}

enum GeneralErrors: Error {
    case DataReadError
    case DataWriteError
    case GeneralError
}
