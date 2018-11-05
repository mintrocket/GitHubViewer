import UIKit

public final class AttributeStringBuilder {
    private var attributes: [NSAttributedString.Key: AnyObject] = [:]
    private let paragraphStyle = NSMutableParagraphStyle()

    @discardableResult
    public func set(color: UIColor) -> AttributeStringBuilder {
        self.attributes[.foregroundColor] = color
        return self
    }

    @discardableResult
    public func set(font: UIFont) -> AttributeStringBuilder {
        self.attributes[.font] = font
        return self
    }

    @discardableResult
    public func set(align: NSTextAlignment) -> AttributeStringBuilder {
        self.paragraphStyle.alignment = align
        self.attributes[.paragraphStyle] = self.paragraphStyle
        return self
    }

    @discardableResult
    public func set(lineHeight: CGFloat) -> AttributeStringBuilder {
        self.paragraphStyle.minimumLineHeight = lineHeight
        self.attributes[.paragraphStyle] = self.paragraphStyle
        return self
    }

    @discardableResult
    public func set(kern: Float) -> AttributeStringBuilder {
        self.attributes[.kern] = NSNumber(value: kern)
        return self
    }

    @discardableResult
    public func set(underline: NSUnderlineStyle) -> AttributeStringBuilder {
        self.attributes[.underlineStyle] = underline.rawValue as AnyObject
        return self
    }

    public func build(_ text: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: text, attributes: self.attributes)
    }
}

public func + (lhs: NSMutableAttributedString,
               rhs: NSMutableAttributedString) -> NSMutableAttributedString {
    let final = NSMutableAttributedString(attributedString: lhs)
    final.append(rhs)
    return final
}

