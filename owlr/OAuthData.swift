//
//  OAuthData.swift
//  owlr
//
//  Created by Kevin Carbone on 6/20/15.
//  Copyright (c) 2015 Kevin Carbone. All rights reserved.
//

import Foundation
import OAuthSwift

let oauthswiftTwitter = OAuth1Swift(
    consumerKey:    "tkbaXySRl6Fd8XictSd9S9vlr",
    consumerSecret: "2M87groo1SJlNAQti2JLdToZiD6IGUQce5ykOk50UIkyz8gxKC",
    requestTokenUrl: "https://api.twitter.com/oauth/request_token",
    authorizeUrl:    "https://api.twitter.com/oauth/authorize",
    accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
)