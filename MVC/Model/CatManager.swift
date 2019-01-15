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
    static let sslScheme = "https"
  }

  private enum TheCatAPIStringConstants {
    static let host = "api.thecatapi.com"
    static let idKey = "id"
    static let mimeKey = "mime_types"
    static let mimeValueJpg = "jpg"
    static let mimeValuePng = "png"
    static let path = "/v1/images/search"
    static let sizeKey = "size"
    static let sizeValue = "small"
    static let urlKey = "url"
  }

  enum ImageType {
    case jpg
    case png

    var url: URL? {
      var components = URLComponents()
      components.scheme = StringConstants.sslScheme

      components.host = TheCatAPIStringConstants.host
      components.path = TheCatAPIStringConstants.path
      components.queryItems = [URLQueryItem(name: TheCatAPIStringConstants.sizeKey,
                                            value: TheCatAPIStringConstants.sizeValue)]

      switch self {
      case .jpg:
        components.queryItems? += [URLQueryItem(name: TheCatAPIStringConstants.mimeKey,
                                                value: TheCatAPIStringConstants.mimeValueJpg)]
      case .png:
        components.queryItems? += [URLQueryItem(name: TheCatAPIStringConstants.mimeKey,
                                                value: TheCatAPIStringConstants.mimeValuePng)]
      }
      return components.url
    }
  }

  enum CatFetchingError: Error {
    case serverError
    case emptyOrUnexpectedValue
    case urlMissing
  }

  static func getCat(imageType: ImageType,
                     success: @escaping (Cat?) -> Void,
                     failure: @escaping (Error?) -> Void) {
    guard let url = imageType.url else {
      failure(CatFetchingError.urlMissing)
      return
    }

    fetchCatData(url: url, success: { (value) in
      guard let value = value else {
        failure(CatFetchingError.emptyOrUnexpectedValue)
        return
      }

      let jsonObject = JSON(value)
      var cat: Cat?
      var identifier: String

      let jsonDictionaryValue = jsonObject.arrayValue.first
      identifier = jsonDictionaryValue?[TheCatAPIStringConstants.idKey].string ?? ""
      cat = Cat(identifier: identifier,
                url: jsonDictionaryValue?[TheCatAPIStringConstants.urlKey].url)

      success(cat)
    }, failure: { (error) in
      failure(error)
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
