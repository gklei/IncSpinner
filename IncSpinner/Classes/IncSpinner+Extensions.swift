//
//  IncSpinner+Extensions.swift
//  Pods
//
//  Created by Gregory Klein on 11/7/16.
//
//

import Foundation

extension UILabel {
   convenience init(incSpinnerText text: String, font: UIFont? = nil) {
      self.init()
      self.text = text
      self.font = font ?? UIFont.boldSystemFont(ofSize: 26)
      textAlignment = .center
      numberOfLines = 0
   }
}

extension DispatchQueue {
   func incSpinner_delay(_ seconds: Double, completion: @escaping () -> Void) {
      let popTime = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * seconds)) / Double(NSEC_PER_SEC)
      asyncAfter(deadline: popTime) {
         completion()
      }
   }
}

extension UIView {
   func incSpinner_addAndFill(subview: UIView) {
      addSubview(subview)
      subview.translatesAutoresizingMaskIntoConstraints = false
      subview.topAnchor.constraint(equalTo: topAnchor).isActive = true
      subview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
      subview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
      subview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
   }
}

extension CABasicAnimation {
   static var incSpinner_scale: CABasicAnimation {
      let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
      scaleAnim.fromValue = 0
      scaleAnim.toValue = 1
      scaleAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
      return scaleAnim
   }
   
   static var incSpinner_fadeIn: CABasicAnimation {
      let alphaAnim = CABasicAnimation(keyPath: "opacity")
      alphaAnim.toValue = NSNumber(value: 1.0)
      alphaAnim.fromValue = NSNumber(value: 0.0)
      alphaAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
      return alphaAnim
   }
   
   static var incSpinner_fadeOut: CABasicAnimation {
      let alphaAnim = CABasicAnimation(keyPath: "opacity")
      alphaAnim.toValue = NSNumber(value: 0.0)
      alphaAnim.fromValue = NSNumber(value: 1.0)
      alphaAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
      return alphaAnim
   }
}
