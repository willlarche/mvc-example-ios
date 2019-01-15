//
//  HomeViewController.swift
//  MVC
//
//  Created by Will Larche on 10/6/18.
//  Copyright © 2018 Will Larche. All rights reserved.
//

import UIKit

import AcknowList

class HomeViewController: UIViewController {

  @IBOutlet weak var storyboardLabel: UILabel!
  let programmaticLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Dynamic Type: Programmatic"
    label.font = UIFont.preferredFont(forTextStyle: .caption1)
    label.adjustsFontForContentSizeCategory = true
    return label
  }()

  @IBOutlet weak var imageTypeControl: UISegmentedControl!

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Cat Pics"
    setupDynamicTypeLabel()
  }

  @IBAction func goDidTouch(_ sender: Any) {
    var imageType: CatManager.ImageType

    if imageTypeControl.selectedSegmentIndex == 0 {
      imageType = .jpg
    } else {
      imageType = .png
    }

    let catViewController = CatViewController()
    self.navigationController?.pushViewController(catViewController, animated: true)

    CatManager.getCat(imageType: imageType, success: { cat in
      catViewController.set(cat: cat, error: nil)
    }, failure: { error in
      catViewController.set(cat: nil, error: error)
    })
  }

  @IBAction func infoDidTouch(_ sender: Any) {
    let acknowledgementsViewController = AcknowListViewController()
    self.navigationController?.pushViewController(acknowledgementsViewController, animated: true)
  }

  func setupDynamicTypeLabel() {
    view.addSubview(programmaticLabel)
    programmaticLabel.leadingAnchor.constraint(equalTo: storyboardLabel.leadingAnchor).isActive = true
    programmaticLabel.topAnchor.constraint(equalToSystemSpacingBelow: storyboardLabel.bottomAnchor, multiplier: 1).isActive = true
    programmaticLabel.trailingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: view.safeAreaLayoutGuide.trailingAnchor, multiplier: 1.0).isActive = true
  }
}
