//
//  List+Separator.swift
//  ListSeparator
//
//  Created by Mike Schmidt on 9/10/20.
//  Copyright © 2020 SchmidtyApps. All rights reserved.
//
//  https://github.com/SchmidtyApps/SwiftUIListSeparator

import UIKit
import SwiftUI

extension View {
    /// Sets the separator style on Lists within this View
    /// - Parameters:
    ///   - style: Style of List separator
    ///   - color: Color of the List separator
    ///   - inset: Edge insets of the List separator
    /// - Returns: The List with the separator modified
    public func listSeparatorStyle(_ style: ListSeparatorStyle, color: UIColor? = nil, inset: EdgeInsets? = nil) -> some View {
        self.listSeparatorStyle(style, color: color, inset: inset, hideOnEmptyRows: false)
    }

    /// Sets the separator style on Lists within this View
    /// - Parameters:
    ///   - style: Style of List separator
    ///   - color: Color of the List separator
    ///   - inset: Edge insets of the List separator
    ///   - hideOnEmptyRows: If true hides divders on any empty rows ie rows shown in the footer
    /// - Returns: The List with the separator modified
    @available(iOS, obsoleted:14.0, message:"hideOnEmptyRows is no longer needed because SwiftUI as of iOS14 always hides empty row separators in the footer")
    public func listSeparatorStyle(_ style: ListSeparatorStyle, color: UIColor? = nil, inset: EdgeInsets? = nil, hideOnEmptyRows: Bool) -> some View {
        self.modifier(ListSeparatorModifier(style: style, color: color, inset: inset, hideOnEmptyRows: hideOnEmptyRows))
    }
}

public enum ListSeparatorStyle {
    case none
    case singleLine
}

private enum ListConstants {
    static let maxDividerHeight: CGFloat = 2
    static let customDividerTag = 8675309
}

/// Modifier to set the separator style on List
private struct ListSeparatorModifier: ViewModifier {

    private let style: ListSeparatorStyle
    private let color: UIColor?
    private let inset: UIEdgeInsets?
    private let hideOnEmptyRows: Bool

    public init(style: ListSeparatorStyle, color: UIColor?, inset: EdgeInsets?, hideOnEmptyRows: Bool) {
        self.style = style
        self.color = color

        if let inset = inset {
            self.inset = UIEdgeInsets(top: inset.top, left: inset.leading, bottom: inset.bottom, right: inset.trailing)
        } else {
            self.inset = nil
        }

        self.hideOnEmptyRows = hideOnEmptyRows
    }

    public func body(content: Content) -> some View {
        ZStack {
            content
            DividerLineSeekerView(divider: { divider in
                //If we encounter a separator view in this heirachy hide it
                switch self.style {
                case .none:
                    divider.isHidden = true
                    divider.backgroundColor = .clear
                case .singleLine:
                    guard divider.tag != ListConstants.customDividerTag else { return  }
                    divider.isHidden = true
                    divider.backgroundColor = .clear

                    let customDivider = UIView()
                    customDivider.frame = divider.frame
                    customDivider.tag = ListConstants.customDividerTag

                    divider.superview?.addSubview(customDivider)
                    self.adjust(divider: customDivider)

                }

            }, table: { table in

                if self.hideOnEmptyRows {
                    table.tableFooterView = UIView()
                }

                if #available(iOS 14, *) {
                    table.separatorStyle = .none
                    table.separatorColor = .clear
                } else {
                    switch self.style {
                    case .none:
                        table.separatorStyle = .none
                        table.separatorColor = .clear
                    case .singleLine:
                        table.separatorStyle = .singleLine

                        if let color = self.color {
                            table.separatorColor = color
                        }

                        if let inset = self.inset {
                            table.separatorInset = inset
                        }
                    }
                }
            })
            //Set frame to +1 of max divider height that way we dont also attempt to change this view
            .frame(width: 1, height: ListConstants.maxDividerHeight + 1, alignment: .leading)
        }
    }

    private func adjust(divider: UIView) {
        divider.backgroundColor = self.color ?? .lightGray

        if let inset = self.inset {
            let leftInset = inset.left
            //So we dont continually trigger layout subviews
            guard divider.frame.origin.x != leftInset else { return }

            divider.frame.origin.x = leftInset

            guard let parentWidth = divider.superview?.frame.size.width else { return }

            let width = parentWidth - inset.left - inset.right

            guard divider.frame.size.width != width else { return }
            divider.frame.size.width = width
        }
    }
}

private struct DividerLineSeekerView : UIViewRepresentable {

    var divider: (UIView) -> Void
    var table: (UITableView) -> Void

    func makeUIView(context: Context) -> InjectView  {
        let view = InjectView(divider: divider, table: table)
        return view
    }

    func updateUIView(_ uiView: InjectView, context: Context) {
    }
}

//View to inject so we can access UIKit views
class InjectView: UIView {
    var divider: (UIView) -> Void
    var table: (UITableView) -> Void

    var didInjectDividerHandler: Bool = false

    init(divider: @escaping (UIView) -> Void, table: @escaping (UITableView) -> Void) {
        self.divider = divider
        self.table = table

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        injectDividerHandler()
    }

    private var scrollViewContentObserver: NSKeyValueObservation?

    private func injectDividerHandler() {
        guard !didInjectDividerHandler, let parentVC = findViewController(), let scrollView = findScrollView(in: parentVC.view) else { return }
        print("Attempt to add divider handler to scroll view")

        let dividerHandler = DividerHandlingView(divider: self.divider, table: self.table)
        dividerHandler.backgroundColor = .red
        dividerHandler.frame = CGRect(x: 0, y: 0, width: 200, height: 10)
        scrollView.addSubview(dividerHandler)
        scrollView.bringSubviewToFront(dividerHandler)

        scrollViewContentObserver = scrollView.observe(\UIScrollView.contentOffset, options: .new) { (_, _) in
            dividerHandler.updateDividers()
        }

        self.didInjectDividerHandler = true
    }

    private func findScrollView(in view: UIView) -> UIScrollView? {

        if let scrollView = view as? UIScrollView {
            print("Found scroll view")
            return scrollView
        }

        //Continue to iterate thru subview hierarchy
        for subview in view.subviews {
            return findScrollView(in: subview)
        }

        return nil
    }
}

//View to inject so we can access UIKit views
class DividerHandlingView: UIView {
    var divider: (UIView) -> Void
    var table: (UITableView) -> Void

    var count: Int = 0

    init(divider: @escaping (UIView) -> Void, table: @escaping (UITableView) -> Void) {
        self.divider = divider
        self.table = table

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateDividers()
        print("layout subviews")

    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        print("draw rect")
        updateDividers()
    }

    func updateDividers() {
        count += 1
        print("BB: \(count)")
        guard let hostingView = self.getHostingView(view: self) else { return }
        self.handleDividerLineSubviews(of: hostingView)
    }

    func getHostingView(view: UIView) -> UIView? {
        findViewController()?.view
    }

    /// If we encounter a separator view in this heirachy hide it
    func handleDividerLineSubviews<T : UIView>(of view:T) {

        if view.frame.height < ListConstants.maxDividerHeight {
            divider(view)
        }

        if let table = view as? UITableView {
            self.table(table)
        }

        //Continue to iterate thru subview hierarchy
        for subview in view.subviews {
            handleDividerLineSubviews(of: subview)
        }
    }
}


private extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
