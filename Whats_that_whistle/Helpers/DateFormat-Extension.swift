//
//  DateFormatter.swift
//  Whats_that_whistle
//
//  Created by Levit Kanner on 25/06/2020.
//  Copyright © 2020 Levit Kanner. All rights reserved.
//

import Foundation

extension Date {
    func toString(dateFormat format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}


func getCreationDate(for file: URL) -> Date {
    guard let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any] else { return Date() }
    guard let creationDate = attributes[FileAttributeKey.creationDate] as?  Date else { return Date() }
    return creationDate
}
