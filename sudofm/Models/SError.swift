//
//  SError.swift
//  sudofm
//
//  Created by phucld on 6/4/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Foundation

enum SError: String, Error {
    case invalidEndpoint = "The endpoint is wrong."
    case unableToComplete = "Unable to complete your request. Please check your internet connection."
    case invalidResponse = "Invalid response from the server. Please try again."
    case invalidData = "The data received from server was invalid. Please try again."
    case cancel = "Cancel request"
    case unknownError = "Unknown error"
    case invalidURL = "This URL is invalid"
}
