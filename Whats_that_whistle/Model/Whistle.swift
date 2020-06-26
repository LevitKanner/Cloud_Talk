//
//  Whistle.swift
//  Whats_that_whistle
//
//  Created by Levit Kanner on 26/06/2020.
//  Copyright © 2020 Levit Kanner. All rights reserved.
//

import UIKit
import CloudKit

class Whistle: NSObject {
    var recordID: CKRecord.ID!
    var genre: String!
    var comment: String!
    var audio: URL!
}
