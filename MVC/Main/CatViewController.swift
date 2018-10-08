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
    static let minimumTouchTarget: CGFloat = 48.0
    static let topToImageViewOffset: CGFloat = 32.0
  }

  private enum StringConstants {
    static let generalError = "Oops! No kitty."
    static let generalErrorComment = "Generic error for no cat image."
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
    catNameLabel.translatesAutoresizingMaskIntoConstraints = false
    return catNameLabel
  }()

  let catView: UIImageView = {
    let catView = UIImageView()
    catView.clipsToBounds = true
    catView.contentMode = .scaleAspectFill
    catView.isOpaque = false
    catView.layer.cornerRadius = 8.0
    catView.translatesAutoresizingMaskIntoConstraints = false
    return catView
  }()

  let errorLabel: UILabel = {
    let errorLabel = UILabel()
    errorLabel.translatesAutoresizingMaskIntoConstraints = false
    errorLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    errorLabel.text = NSLocalizedString(StringConstants.generalError,
                                        comment: StringConstants.generalErrorComment)
    return errorLabel
  }()

  let closeButton: UIButton = {
    let closeButton = UIButton(type: .system)
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    closeButton.setTitle(NSLocalizedString("Close", comment: "Close this screen and go back to home."),
                         for: .normal)
    return closeButton
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
    setupCloseButton()
    view.backgroundColor = .white

    view.addSubview(activityIndicator)
    view.addSubview(catView)
    view.addSubview(catNameLabel)
    view.addSubview(errorLabel)

    NSLayoutConstraint.activate([
      catView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                       constant: LayoutConstants.generalOffset),
      catView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                        constant: -1 * LayoutConstants.generalOffset),
      catView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor,
                                   constant: LayoutConstants.topToImageViewOffset),

      errorLabel.topAnchor.constraint(equalTo: catView.bottomAnchor,
                                      constant: LayoutConstants.generalOffset),
      errorLabel.leadingAnchor.constraint(equalTo: catView.layoutMarginsGuide.leadingAnchor),
      errorLabel.trailingAnchor.constraint(equalTo: catView.layoutMarginsGuide.trailingAnchor),

      activityIndicator.bottomAnchor.constraint(equalTo: catView.bottomAnchor,
                                      constant: -1 * LayoutConstants.generalOffset),
      activityIndicator.centerXAnchor.constraint(equalTo: catView.centerXAnchor)

      ])
  }

  func setupCloseButton() {
    closeButton.addTarget(self,
                          action: #selector(CatViewController.closeButtonDidTouch),
                          for: .touchUpInside)
    view.addSubview(closeButton)

    NSLayoutConstraint.activate([
      closeButton.heightAnchor.constraint(greaterThanOrEqualToConstant: LayoutConstants.minimumTouchTarget),
      closeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: LayoutConstants.minimumTouchTarget),
      closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
      constant: LayoutConstants.generalOffset),
      closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
      constant: -1 * LayoutConstants.generalOffset)
      ])
  }

  func update() {
    updateState()
    updateViews()
  }

  func updateState() {
    if cat != nil {
      if cat?.url != nil {
        state = .doneLoading
      } else {
        state = .inError
      }
    } else if imageRequest != nil {
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
      errorLabel.text = nil

    case .needsLoading:
      // If there's an image loading, we are in the wrong state.
      guard imageRequest == nil else {
        update()
        return
      }

      activityIndicator.startAnimating()
      errorLabel.text = nil

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
                          placeholderImage: UIImage(named: "CatPlaceholder"),
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
                            self?.update()
      }

    }
  }

  @objc func closeButtonDidTouch() {
    dismiss(animated: true, completion: nil)
  }
}
