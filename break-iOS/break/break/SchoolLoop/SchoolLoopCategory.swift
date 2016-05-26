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
        name = aDecoder.decodeObjectForKey("name") as? String ?? ""
        score = aDecoder.decodeObjectForKey("score") as? String ?? ""
        weight = aDecoder.decodeObjectForKey("weight") as? String ?? ""
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(score, forKey: "score")
        aCoder.encodeObject(weight, forKey: "weight")
    }
}