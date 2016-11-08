//
//  IncipiaSpinner.swift
//  IncipiaSpinner
//
//  Created by Gregory Klein on 10/25/16.
//  Copyright © 2016 Incipia. All rights reserved.
//

import UIKit

// TODO: User this class to wrap the replicator layer
private class IncSpinner_PlusingCircleView: UIView {
   required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
   }
   
   override init(frame: CGRect) {
      super.init(frame: frame)
   }
   
   convenience init(frame: CGRect, circleCount count: Int) {
      self.init(frame: frame)
   }
}

private class IncSpinner_PulsingCircleReplicatorLayer: CAReplicatorLayer {
   private let _padding: CGFloat = 20
   
   required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
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
   public static var pulseDuration: TimeInterval = 0.8
   public static var fadeDuration: TimeInterval = 0.8
   
   private weak var container: UIView?
   private var blurredEffectView: UIVisualEffectView?
   private var vibrancyEffectView: UIVisualEffectView?
   private var replicatorLayer: CAReplicatorLayer?
   private var textLabel: UILabel?
   
   public class func show(inView view: UIView? = nil,
                          withTitle title: String? = nil,
                          usingFont font: UIFont? = nil,
                          style: UIBlurEffectStyle = .dark,
                          color: UIColor) {
      let container = view ?? UIApplication.shared.keyWindow
      guard let unwrappedContainer = container else { return }
      
      shared._startUsing(container: unwrappedContainer)
      
      let blurredEffectView = shared._addEffectView(toContainer: unwrappedContainer)
      shared.blurredEffectView = blurredEffectView
      
      let layer = shared._addSpinnerLayer(to: blurredEffectView.contentView,
                                          withCircleColor: color,
                                          pulseDuration: pulseDuration)
      
      let yOffset: CGFloat = title != nil ? -20 : 0
      layer.position = CGPoint(x: unwrappedContainer.bounds.midX, y: unwrappedContainer.bounds.midY + yOffset)
      shared.replicatorLayer = layer
      
      if let title = title {
         let label = UILabel(incSpinnerText: title, font: font)
         let vibrancyEffectView = shared._addEffectView(toContainer: unwrappedContainer)
         
         vibrancyEffectView.contentView.addSubview(label)
         label.translatesAutoresizingMaskIntoConstraints = false
         
         [label.centerYAnchor.constraint(equalTo: vibrancyEffectView.centerYAnchor, constant: 60),
         label.centerXAnchor.constraint(equalTo: vibrancyEffectView.centerXAnchor),
         label.leftAnchor.constraint(equalTo: vibrancyEffectView.leftAnchor, constant: 40),
         label.rightAnchor.constraint(equalTo: vibrancyEffectView.rightAnchor, constant: -40)
         ].forEach { $0.isActive = true }
         
         label.textAlignment = .center
         
         shared.textLabel = label
         shared.vibrancyEffectView = vibrancyEffectView
      }
      
      shared._animateBlurIn(withDuration: fadeDuration, style: style)
   }
   
   public class func hide(completion: (() -> Void)? = nil) {
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
      blurredEffectView?.removeFromSuperview()
      vibrancyEffectView?.removeFromSuperview()
      replicatorLayer = nil
      blurredEffectView = nil
      vibrancyEffectView = nil
      container = nil
   }
   
   private func _addEffectView(toContainer container: UIView) -> UIVisualEffectView {
      let effectView = UIVisualEffectView(effect: nil)
      container.incSpinner_addAndFill(subview: effectView)
      return effectView
   }
   
   private func _addSpinnerLayer(to view: UIView,
                                 withCircleColor color: UIColor,
                                 pulseDuration: TimeInterval) -> CAReplicatorLayer {
      let replicatorLayer = IncSpinner_PulsingCircleReplicatorLayer(circleCount: 3,
                                                                    circleSize: 60,
                                                                    circleColor: color,
                                                                    animationDuration: pulseDuration)
      view.layer.addSublayer(replicatorLayer)
      return replicatorLayer
   }
   
   private func _animateBlurIn(withDuration duration: TimeInterval, style: UIBlurEffectStyle) {
      textLabel?.textColor = .clear
      let blurEffect = UIBlurEffect(style: style)
      
      UIView.animate(withDuration: duration, animations: {
         self.blurredEffectView?.effect = blurEffect
         }) { finished in
            guard let effectView = self.vibrancyEffectView, let label = self.textLabel else { return }
            UIView.animate(withDuration: duration * 0.5, animations: {
               effectView.effect = UIVibrancyEffect(blurEffect: blurEffect)
               label.textColor = .white
            })
      }
   }
   
   private func _animateBlurOut(withDuration duration: TimeInterval, completion: (() -> Void)?) {
      UIView.animate(withDuration: duration, animations: {
         self.blurredEffectView?.effect = nil
         self.vibrancyEffectView?.effect = nil
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
