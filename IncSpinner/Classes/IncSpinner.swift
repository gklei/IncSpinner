//
//  IncipiaSpinner.swift
//  IncipiaSpinner
//
//  Created by Gregory Klein on 10/25/16.
//  Copyright © 2016 Incipia. All rights reserved.
//

import UIKit

private extension DispatchQueue {
   func incSpinner_delay(_ seconds: Double, completion: @escaping () -> Void) {
      let popTime = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * seconds)) / Double(NSEC_PER_SEC)
      asyncAfter(deadline: popTime) {
         completion()
      }
   }
}

private extension UIView {
   func incSpinner_addAndFill(subview: UIView) {
      addSubview(subview)
      subview.translatesAutoresizingMaskIntoConstraints = false
      subview.topAnchor.constraint(equalTo: topAnchor).isActive = true
      subview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
      subview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
      subview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
   }
}

private extension CABasicAnimation {
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

private class IncSpinner_PulsingCircleReplicatorLayer: CAReplicatorLayer {
   private let _padding: CGFloat = 20
   
   required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   override init() {
      super.init()
   }
   
   convenience init(circleCount count: Int,
                    circleSize size: CGFloat,
                    circleColor color: UIColor,
                    animationDuration: CFTimeInterval) {
      self.init()
      _setupFrame(withCircleCount: CGFloat(count), circleSize: size)
      
      let layer = _addShapeLayer(withCircleSize: size, color: color)
      _addAnimation(toShapeLayer: layer, withDuration: animationDuration)
      
      instanceCount = count
      instanceDelay = animationDuration / CFTimeInterval(count)
      instanceTransform = CATransform3DMakeTranslation(size + _padding, 0, 0)
   }
   
   private func _setupFrame(withCircleCount count: CGFloat, circleSize size: CGFloat) {
      frame = CGRect(x: 0, y: 0, width: (size + _padding) * count - _padding, height: size)
   }
   
   private func _addShapeLayer(withCircleSize size: CGFloat, color: UIColor) -> CAShapeLayer {
      let lineWidth: CGFloat = 4.0
      let pathFrame = CGRect(origin: .zero, size: CGSize(width: size, height: size))
      let circleLayer = CAShapeLayer()
      circleLayer.path = UIBezierPath(ovalIn: pathFrame).cgPath
      circleLayer.frame = pathFrame
      circleLayer.cornerRadius = size * 0.5
      circleLayer.borderWidth = lineWidth
      circleLayer.borderColor = UIColor(white: 1, alpha: 0.2).cgColor
      circleLayer.fillColor = color.cgColor
      circleLayer.opacity = 0
      addSublayer(circleLayer)
      
      return circleLayer
   }
   
   private func _addAnimation(toShapeLayer layer: CAShapeLayer, withDuration duration: TimeInterval) {
      let group = CAAnimationGroup()
      group.animations = [CABasicAnimation.incSpinner_scale, CABasicAnimation.incSpinner_fadeIn]
      group.duration = duration
      group.repeatCount = Float.infinity
      group.autoreverses = true
      
      layer.add(group, forKey: nil)
   }
}

public class IncSpinner {
   private static let shared = IncSpinner()
   public static var animationDuration: TimeInterval = 0.8
   
   private weak var container: UIView?
   private var effectView: UIVisualEffectView?
   private var replicatorLayer: CAReplicatorLayer?
   private var fadeDuration: TimeInterval = 0.5
   
   public class func show(inView view: UIView? = nil,
                          withStyle style: UIBlurEffectStyle = .dark,
                          usingColor color: UIColor) {
      let container = view ?? UIApplication.shared.keyWindow
      guard let unwrappedContainer = container else { return }
      
      shared._startUsing(container: unwrappedContainer)
      
      let effectView = shared._addEffectView(toContainer: unwrappedContainer)
      shared.effectView = effectView
      
      let layer = shared._addSpinnerLayer(to: effectView.contentView,
                                          withCircleColor: color,
                                          animationDuration: animationDuration)
      layer.position = CGPoint(x: unwrappedContainer.bounds.midX, y: unwrappedContainer.bounds.midY)
      shared.replicatorLayer = layer
      
      shared._animateBlurIn(withDuration: shared.fadeDuration, style: style)
   }
   
   public class func hide(completion: (() -> Void)? = nil) {
      let fadeDuration = shared.fadeDuration
      shared._fadeReplicatorLayerOut(withDuration: fadeDuration * 0.8)
      DispatchQueue.main.incSpinner_delay(fadeDuration * 0.5) {
         shared._animateBlurOut(withDuration: fadeDuration) {
            DispatchQueue.main.async {
               shared._reset()
               completion?()
            }
         }
      }
   }
   
   private func _startUsing(container c: UIView) {
      _reset()
      container = c
   }
   
   private func _reset() {
      replicatorLayer?.removeFromSuperlayer()
      effectView?.removeFromSuperview()
      replicatorLayer = nil
      effectView = nil
      container = nil
   }
   
   private func _addEffectView(toContainer container: UIView) -> UIVisualEffectView {
      let blurView = UIVisualEffectView(effect: nil)
      container.incSpinner_addAndFill(subview: blurView)
      return blurView
   }
   
   private func _addSpinnerLayer(to view: UIView,
                                 withCircleColor color: UIColor,
                                 animationDuration: TimeInterval) -> CAReplicatorLayer {
      let replicatorLayer = IncSpinner_PulsingCircleReplicatorLayer(circleCount: 3,
                                                                    circleSize: 60,
                                                                    circleColor: color,
                                                                    animationDuration: animationDuration)
      view.layer.addSublayer(replicatorLayer)
      return replicatorLayer
   }
   
   private func _animateBlurIn(withDuration duration: TimeInterval, style: UIBlurEffectStyle) {
      UIView.animate(withDuration: duration) {
         self.effectView?.effect = UIBlurEffect(style: style)
      }
   }
   
   private func _animateBlurOut(withDuration duration: TimeInterval, completion: (() -> Void)?) {
      UIView.animate(withDuration: duration, animations: {
         self.effectView?.effect = nil
      }) { (finished) in
         completion?()
      }
   }
   
   private func _fadeReplicatorLayerOut(withDuration duration: TimeInterval) {
      let anim = CABasicAnimation.incSpinner_fadeOut
      anim.duration = duration
      anim.fillMode = kCAFillModeForwards
      anim.isRemovedOnCompletion = false
      replicatorLayer?.add(anim, forKey: nil)
   }
}
