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

  }
}
