//
//  CatManager.swift
//  MVC
//
//  Created by Will Larche on 10/6/18.
//  Copyright © 2018 Will Larche. All rights reserved.
//

import Alamofire
import SwiftyJSON

struct CatManager {

  private enum StringConstants {

  }

  private enum RandomCatStringConstants {

  }

  private enum TheCatAPIStringConstants {

  }

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
        components.path = "/meow"
      case .theCatAPI(let ofType):
        components.host = "api.thecatapi.com"
        components.path = "/v1/images/search"
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

  enum CatFetchingError: Error {
    case serverError
    case emptyOrUnexpectedValue
    case urlMissing
  }

  static func getCat(service site: CatSite,
                     success: @escaping (Cat) -> Void,
                     failure: @escaping (Error) -> Void) {
    guard let url = site.url else {
      failure(CatFetchingError.urlMissing)
      return
    }

    fetchCatData(url: url, success: { (value) in
      guard let value = value else {
        failure(CatFetchingError.emptyOrUnexpectedValue)
        return
      }

      let jsonObject = JSON(value)
      let cat = Cat(identifier: jsonObject["file"].stringValue, url: jsonObject["file"].url)
      success(cat)
    }, failure: { (error) in

    })

  }

  fileprivate static func fetchCatData(url: URL,
                                       success: @escaping (Any?) -> Void,
                                       failure: @escaping (Error?) -> Void) {
    Alamofire.request(url).responseJSON { response in
      if response.result.isSuccess {
        success(response.result.value)
      } else {
        failure(response.result.error)
      }
    }
  }

}
