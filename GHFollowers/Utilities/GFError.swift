//
//  GFError.swift
//  GHFollowers
//
//  Created by Sylvain Druaux on 22/08/2023.
//

import Foundation

enum GFError: String, Error {
    case invalidUsername = "This username created an invalid request. Please try again."
    case invalidRequest = "Unable to complete your request. Please check your internet connection."
    case invalidResponse = "Invalid response from the server. Please try again."
    case invalidData = "The data recieved from the server was invalid. Please try again."
    case unableToGetFavorite = "There was an error getting this user from favorites. Please try again."
    case unableToSaveFavorite = "There was an error saving this user to favorites. Please try again."
    case alreadyInFavorites = "You've already added this user."
}
