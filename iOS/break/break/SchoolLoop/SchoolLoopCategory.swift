//
//  SchoolLoopCategory.swift
//  break
//
//  Created by Saagar Jha on 5/20/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

@objc(SchoolLoopCategory)
class SchoolLoopCategory: NSObject, NSCoding {
    var name: String
    var score: String
    var weight: String
    
    init(name: String, score: String, weight: String) {
        self.name = name
        self.score = score
        self.weight = weight
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        score = aDecoder.decodeObject(forKey: "score") as? String ?? ""
        weight = aDecoder.decodeObject(forKey: "weight") as? String ?? ""
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(score, forKey: "score")
        aCoder.encode(weight, forKey: "weight")
    }
}
