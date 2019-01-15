//
//  CatViewController.swift
//  MVC
//
//  Created by Will Larche on 10/7/18.
//  Copyright © 2018 Will Larche. All rights reserved.
//

import UIKit

import AlamofireImage

class CatViewController: UIViewController {
  private enum LayoutConstants {
    static let generalOffset: CGFloat = 16.0
    static let topToImageViewOffset: CGFloat = 32.0
  }

  private enum StringConstants {
    static let closeComment = "Close this screen and go back to home."
    static let generalError = "Oops! No kitty."
    static let generalErrorComment = "Generic error for no cat image."
    static let placeholderFilename = "CatPlaceholder"
  }

  private enum State {
    case inError
    case isLoading
    case doneLoading
    case needsLoading
  }

  let activityIndicator: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView()
    activityIndicator.hidesWhenStopped = true
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.style = .gray
    return activityIndicator
  }()

  let catNameLabel: UILabel = {
    let catNameLabel = UILabel()
    catNameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
    catNameLabel.textAlignment = .center
    catNameLabel.translatesAutoresizingMaskIntoConstraints = false
    return catNameLabel
  }()

  let catView: UIImageView = {
    let catView = UIImageView()
    catView.clipsToBounds = true
    catView.contentMode = .scaleAspectFit
    catView.isOpaque = false
    catView.layer.cornerRadius = 8.0
    catView.image = UIImage(named: StringConstants.placeholderFilename)
    catView.translatesAutoresizingMaskIntoConstraints = false
    return catView
  }()

 let errorLabel: UILabel = {
    let errorLabel = UILabel()
    errorLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    errorLabel.text = NSLocalizedString(StringConstants.generalError,
                                        comment: StringConstants.generalErrorComment)
    errorLabel.translatesAutoresizingMaskIntoConstraints = false
    return errorLabel
  }()

  var cat: Cat?
  var error: Error?

  var imageRequest: URLRequest?

  private var state: State = .needsLoading

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    update()
  }

  func set(cat newCat: Cat?, error newError: Error?) {
    cat = newCat
    error = newError

    update()
  }

  func setupViews() {
    view.backgroundColor = .white

    view.addSubview(activityIndicator)
    view.addSubview(catView)
    view.addSubview(catNameLabel)
    view.addSubview(errorLabel)

    NSLayoutConstraint.activate([
      activityIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                             constant: LayoutConstants.generalOffset),
      activityIndicator.centerXAnchor.constraint(equalTo: catView.centerXAnchor),

      catNameLabel.topAnchor.constraint(equalTo: catView.bottomAnchor,
                                      constant: LayoutConstants.generalOffset),
      catNameLabel.leadingAnchor.constraint(equalTo: catView.layoutMarginsGuide.leadingAnchor),
      catNameLabel.trailingAnchor.constraint(equalTo: catView.layoutMarginsGuide.trailingAnchor),

      catView.heightAnchor.constraint(equalTo: catView.widthAnchor),
      catView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                       constant: LayoutConstants.generalOffset),
      catView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                        constant: -1 * LayoutConstants.generalOffset),
      catView.topAnchor.constraint(greaterThanOrEqualTo: activityIndicator.bottomAnchor,
                                   constant: LayoutConstants.topToImageViewOffset),

      errorLabel.topAnchor.constraint(equalTo: catNameLabel.bottomAnchor,
                                      constant: LayoutConstants.generalOffset),
      errorLabel.leadingAnchor.constraint(equalTo: catView.layoutMarginsGuide.leadingAnchor),
      errorLabel.trailingAnchor.constraint(equalTo: catView.layoutMarginsGuide.trailingAnchor)
      ])
  }

  func update() {
    updateState()
    updateViews()
  }

  func updateState() {
    guard state != .doneLoading else {
      return
    }

    if imageRequest != nil {
      state = .isLoading
    } else if error != nil {
      state = .inError
    } else {
      state = .needsLoading
    }
  }

  func updateViews() {
    switch state {
    case .doneLoading:
      catNameLabel.text = cat?.identifier
      errorLabel.text = nil

      activityIndicator.stopAnimating()
      return

    case .inError:
      activityIndicator.stopAnimating()
      guard let error = error else {
        errorLabel.text = NSLocalizedString(StringConstants.generalError,
                                            comment: StringConstants.generalErrorComment)
        return
      }
      errorLabel.text = NSLocalizedString(error.localizedDescription,
                                          comment: StringConstants.generalErrorComment)

    case .isLoading:
      activityIndicator.startAnimating()
      catNameLabel.text = cat?.identifier
      errorLabel.text = nil

    case .needsLoading:
      // If there's an image loading, we are in the wrong state.
      guard imageRequest == nil else {
        update()
        return
      }

      activityIndicator.startAnimating()
      catNameLabel.text = cat?.identifier
      errorLabel.text = nil
      handleImage()
    }
  }

  func handleImage() {
    // If there's nothing to load from, we must wait for it to be set.
    guard let url = cat?.url else {
      return
    }

    imageRequest = URLRequest(url: url)
    guard let imageRequest = imageRequest else {
      update()
      return
    }

    catView.af_setImage(withURLRequest: imageRequest,
                        placeholderImage: UIImage(named: StringConstants.placeholderFilename),
                        filter: nil,
                        progress: nil,
                        progressQueue: DispatchQueue.main,
                        imageTransition: .crossDissolve(0.2),
                        runImageTransitionIfCached: false) { [weak self] response  in
                          guard response.error == nil else {
                            self?.set(cat: self?.cat, error: response.error)
                            return
                          }
                          self?.state = .doneLoading
                          self?.imageRequest = nil
                          self?.update()
    }
  }

  @objc func closeButtonDidTouch() {
    dismiss(animated: true, completion: nil)
  }
}
