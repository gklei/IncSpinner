//
//  ViewController.swift
//  IncSpinner
//
//  Created by gklei on 10/26/2016.
//  Copyright (c) 2016 gklei. All rights reserved.
//

import UIKit
import IncSpinner

private extension DispatchQueue {
   func delay(_ seconds: Double, completion: @escaping () -> Void) {
      let popTime = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * seconds)) / Double(NSEC_PER_SEC)
      asyncAfter(deadline: popTime) {
         completion()
      }
   }
}

class ViewController: UIViewController {
   @IBAction private func _spinButtonPressed() {
      IncSpinner.show(withTitle: "Loading...", color: .magenta)
      DispatchQueue.main.delay(3.75) {
         IncSpinner.hide()
      }
   }
}

