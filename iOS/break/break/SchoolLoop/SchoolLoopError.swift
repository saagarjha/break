//
//  SchoolLoopError.swift
//  break
//
//  Created by Saagar Jha on 1/28/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

/// A mapping of possible errors from SchoolLoop's API.
///
/// - noError: There was no error.
/// - unknownError: There was an error, but its exact nature cannot be
///   determined.
/// - doesNotExistError: A task which reqires a reference to an object could not
///   find that object.
/// - authenticationError: There was an issue with authenticiation; most likely
///   this means that SchoolLoop returned a 401 Unauthorized status.
/// - networkError: There was an issue with the network.
/// - parseError: There was an issue parsing the response; most likely this
///   means there was unexpected content in the JSON response.
/// - trendScoreError: A request which returns trend score data could not find
///   it.
public enum SchoolLoopError: Error {
	case noError
	case unknownError
	case doesNotExistError
	case authenticationError
	case networkError
	case parseError
	case trendScoreError
}
