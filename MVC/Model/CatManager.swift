//
//  CatManager.swift
//  MVC
//
//  Created by Will Larche on 10/6/18.
//  Copyright © 2018 Will Larche. All rights reserved.
//

import Foundation

enum ImageType {
  case gif
  case jpg
}

enum CatSite {
  case randomCat
  case theCatAPI(ofType: ImageType)

  var url: URL? {
    var components = URLComponents()
    components.scheme = "https"

    switch self {
    case .randomCat:
      components.host = "aws.random.cat"
      components.path = "meow"
    case .theCatAPI(let ofType):
      components.host = "api.thecatapi.com"
      components.path = "v1/images/search"
      components.queryItems = [URLQueryItem(name: "size", value: "small")]

      switch ofType {
      case .gif:
        components.queryItems? += [URLQueryItem(name: "mime_types", value: "gif")]
      case .jpg:
        components.queryItems? += [URLQueryItem(name: "mime_types", value: "jpg")]
      }
    }
    return components.url
  }
}

func fetchCat(service site: CatSite, type: ImageType) -> Cat {
  return Cat(identifier: "", url: URL(string: ""))
}

func getImage() {
  
}
