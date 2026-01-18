import AppKit

extension NSView {
    
    /// 从当前状态动画到：相对位移 + 缩放 + 透明度变化
    /// - Parameters:
    ///   - translateXDelta: X 方向相对位移（正值向右）
    ///   - translateYDelta: Y 方向相对位移（正值向下）
    ///   - scale: 目标缩放倍数（相对于当前尺寸，例如 0.8 表示缩小到 80%）
    ///   - alpha: 目标透明度
    ///   - duration: 动画时长
    ///   - timing: 动画曲线
    ///   - completion: 完成回调
    func animate(
        translateXDelta: CGFloat = 0,
        translateYDelta: CGFloat = 0,
        scale: CGFloat = 1.0,
        alpha: CGFloat = 1.0,
        duration: TimeInterval = 0.45,
        timing: CAMediaTimingFunctionName = .easeInEaseOut,
        completion: (() -> Void)? = nil
    ) {
        // 确保支持 layer 动画
        wantsLayer = true
        guard let layer = self.layer else { return }
        
        // 当前 transform 作为起点
        let currentTransform = layer.presentation()?.transform ?? layer.transform
        
        // 目标 transform：先缩放，再相对位移
        let scaleTransform = CATransform3DMakeScale(scale, scale, 1)
        let translateTransform = CATransform3DMakeTranslation(translateXDelta, translateYDelta, 0)
        let targetTransform = CATransform3DConcat(scaleTransform, translateTransform)
        
        // === 透明度动画（AppKit 隐式，最丝滑）===
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: timing)
            self.animator().alphaValue = alpha
        }
        
        // === Transform 动画（显式 CABasicAnimation，保证缩放+位移一定有动画）===
        let anim = CABasicAnimation(keyPath: "transform")
        anim.fromValue = NSValue(caTransform3D: currentTransform)
        anim.toValue = NSValue(caTransform3D: targetTransform)
        anim.duration = duration
        anim.timingFunction = CAMediaTimingFunction(name: timing)
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        
        layer.add(anim, forKey: "smoothTransform")
        
        // 设置最终模型值（防止动画结束弹回）
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.transform = targetTransform
        CATransaction.commit()
        
        // 完成回调
        if let completion = completion {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                completion()
            }
        }
    }
}
