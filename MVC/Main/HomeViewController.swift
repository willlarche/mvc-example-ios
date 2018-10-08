//
//  HomeViewController.swift
//  MVC
//
//  Created by Will Larche on 10/6/18.
//  Copyright © 2018 Will Larche. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

  @IBOutlet weak var apiControl: UISegmentedControl!
  @IBOutlet weak var imageTypeControl: UISegmentedControl!

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    refreshControls()
  }

  func refreshControls() {
    imageTypeControl.isEnabled = apiControl.selectedSegmentIndex == 1
  }

  @IBAction func catControlDidTouch(_ sender: Any) {
    refreshControls()
  }

  @IBAction func goDidTouch(_ sender: Any) {
    var site: CatManager.CatSite

    if apiControl.selectedSegmentIndex == 0 {
      site = .randomCat
    } else {
      if imageTypeControl.selectedSegmentIndex == 0 {
        site = .theCatAPI(ofType: .gif)
      } else {
        site = .theCatAPI(ofType: .jpg)
      }
    }

    let catViewController = CatViewController()
    present(catViewController, animated: true, completion: nil)
    
    CatManager.getCat(service: site, success: { cat in
      catViewController.set(cat: cat, error: nil)
    }, failure: { error in
      catViewController.set(cat: nil, error: error)
    })
  }
}
