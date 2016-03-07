//
//  SchoolLoopCourse.swift
//  break
//
//  Created by Saagar Jha on 1/19/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

class SchoolLoopCourse {
    var courseName: String
    var period: String
    var teacherName: String
    var grade: String
    var score: String
    var periodID: String
    
    var grades: [SchoolLoopGrade] = []
    
    init(courseName: String, period: String, teacherName: String, grade: String, score: String, periodID: String) {
        self.courseName = courseName
        self.period = period
        self.teacherName = teacherName
        self.grade = grade
        self.score = score
        self.periodID = periodID
    }
}
