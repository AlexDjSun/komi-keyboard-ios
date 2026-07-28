// KeyBase.swift

import UIKit
import AudioToolbox

protocol KeyDelegate: AnyObject {
    func keyDidTap(character: String)
    func startContinuousDelete()
    func stopContinuousDelete()
    func handleDoubleTap(character: String)
    func handleCursorMove(cursorMovement: Int)
    func setGlobeKeySelector(globeKey: SpecialKey)
    func isShifted() -> Bool
}

class KeyBase: UIButton {
    weak var delegate: KeyDelegate?
    let basePadding: CGFloat = 3
    var fontSize: CGFloat = 22
    
    let clickFeedback = UIImpactFeedbackGenerator(style: .light)
    let longPressFeedback = UIImpactFeedbackGenerator(style: .heavy)

    var keyColor: UIColor = .dynamicKeyColor

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureDrawing()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureDrawing()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        let adjustedRect: CGRect
        if #available(iOSApplicationExtension 26.0, *) {
            // Rows provide the outer keyboard margin. A 3 pt inset leaves the
            // same 6 pt gap between adjacent iOS 26 keycaps.
            let verticalInset: CGFloat = rect.height >= 50 ? 5.5 : 4
            adjustedRect = rect.insetBy(dx: 3, dy: verticalInset)
        } else {
            adjustedRect = rect.adjustedForPadding(basePadding: basePadding)
        }
        drawRoundedRectangle(in: adjustedRect, context: context)
        context.restoreGState()
        drawKeyTitle(in: adjustedRect)
    }

    private func drawRoundedRectangle(in rect: CGRect, context: CGContext) {
        let cornerRadius: CGFloat
        if #available(iOSApplicationExtension 26.0, *) {
            // The system keycap is a rounded rectangle, not a capsule. On the
            // 27.5 pt character keys its corner becomes flat after about 7 pt.
            cornerRadius = 7
        } else {
            cornerRadius = 5
        }
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        configureShadow(in: context)
        context.addPath(path.cgPath)
        context.setFillColor(keyColor.cgColor)
        context.fillPath()
    }

    private func drawKeyTitle(in rect: CGRect) {
        guard let title = title(for: .normal) else { return }

        let attributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize),
            NSAttributedString.Key.foregroundColor: UIColor.dynamicTextColor
        ]
        
        let attributedString = NSAttributedString(string: title == "space" ? NSLocalizedString(title, comment: "") : title, attributes: attributes)
        let stringSize = attributedString.size()
        let stringRect = CGRect(
            x: rect.midX - stringSize.width / 2,
            y: rect.midY - stringSize.height / 2,
            width: stringSize.width,
            height: stringSize.height
        )
        attributedString.draw(in: stringRect)
    }
    
    private func configureShadow(in context: CGContext) {
        if #available(iOSApplicationExtension 26.0, *) {
            // iOS 26 keyboard keycaps are flat fills without drop shadows.
        } else {
            context.setShadow(
                offset: CGSize(width: 0, height: 1),
                blur: 0.1,
                color: UIColor.dynamicShadowColor.cgColor
            )
        }
    }

    private func configureDrawing() {
        // Keyboard extensions are initially laid out at a provisional height.
        // Redraw instead of stretching that first backing store when the host
        // applies the final keyboard size.
        contentMode = .redraw
        isOpaque = false
        backgroundColor = .clear
    }
}

private extension CGRect {
    func adjustedForPadding(basePadding: CGFloat) -> CGRect {
            return CGRect(x: self.origin.x + basePadding,
                          y: self.origin.y - 1 + 3 * basePadding,
                          width: self.width - 2 * basePadding,
                          height: self.height - 4 * basePadding)
        }
    
}
