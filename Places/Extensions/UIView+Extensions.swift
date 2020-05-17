//  Created by Alex Cuello Ortiz on 13/05/2020.
//  Copyright © 2020 Chama. All rights reserved.
//  Source: https://github.com/bhlvoong/LBTAComponents/blob/master/LBTAComponents/Classes/UIView%2BAnchors.swift
import UIKit

extension UIView {
    func addSubviewWithAutolayout(_ view: UIView) {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    func fillSuperview(withEdges edges: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
        guard let superView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: edges.left),
            trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -edges.right),
            topAnchor.constraint(equalTo: superView.topAnchor, constant: edges.top),
            bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -edges.bottom),
        ])
    }

    func anchor(
        top: NSLayoutYAxisAnchor? = nil,
        left: NSLayoutXAxisAnchor? = nil,
        bottom: NSLayoutYAxisAnchor? = nil,
        right: NSLayoutXAxisAnchor? = nil,
        topConstant: CGFloat = 0,
        leftConstant: CGFloat = 0,
        bottomConstant: CGFloat = 0,
        rightConstant: CGFloat = 0,
        widthConstant: CGFloat = 0,
        heightConstant: CGFloat = 0
    ) {
        translatesAutoresizingMaskIntoConstraints = false
        var anchors = [NSLayoutConstraint]()
        if let top = top { anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant)) }
        if let left = left { anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant)) }
        if let bottom = bottom { anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant)) }
        if let right = right { anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant)) }
        if widthConstant > 0 { anchors.append(widthAnchor.constraint(equalToConstant: widthConstant)) }
        if heightConstant > 0 { anchors.append(heightAnchor.constraint(equalToConstant: heightConstant)) }
        NSLayoutConstraint.activate(anchors)
    }

    func anchorCenterXToSuperview(constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
    }

    func anchorCenterYToSuperview(constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
    }

    func anchorCenterSuperview() {
        anchorCenterXToSuperview()
        anchorCenterYToSuperview()
    }
}
