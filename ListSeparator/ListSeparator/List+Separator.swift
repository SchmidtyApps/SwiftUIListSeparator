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
                    divider.isHidden = false

                    if let color = self.color {
                        divider.backgroundColor = color
                    }

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

            }, table: { table in

                if self.hideOnEmptyRows {
                    table.tableFooterView = UIView()
                }

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
            })
            //Set frame to +1 of max divider height that way we dont also attempt to change this view
            .frame(width: 1, height: ListConstants.maxDividerHeight + 1, alignment: .leading)
        }
    }
}

private struct DividerLineSeekerView : UIViewRepresentable {

    var divider: (UIView) -> Void
    var table: (UITableView) -> Void

    func makeUIView(context: Context) -> InjectView  {
        let view = InjectView(divider: divider, table: table)
        view.updateDividers()
        return view
    }

    func updateUIView(_ uiView: InjectView, context: Context) {
        uiView.updateDividers()
    }
}

private enum ListConstants {
    static let maxDividerHeight: CGFloat = 2
}

//View to inject so we can access UIKit views
class InjectView: UIView {
    var divider: (UIView) -> Void
    var table: (UITableView) -> Void

    //Used so we only set once in first layout subviews call. Subsequent layouts will get triggered by updateUIView in DividerLineSeekerView
    var updatedDividers: Bool = false

    init(divider: @escaping (UIView) -> Void, table: @escaping (UITableView) -> Void) {
        self.divider = divider
        self.table = table

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        updateDividers()
    }

    func updateDividers() {
        guard let hostingView = self.getHostingView(view: self) else { return }
        self.hideDividerLineSubviews(of: hostingView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !updatedDividers else { return }
        updateDividers()
        updatedDividers = true
    }

    func getHostingView(view: UIView) -> UIView? {
        findViewController()?.view
    }

    /// If we encounter a separator view in this heirachy hide it
    func hideDividerLineSubviews<T : UIView>(of view:T) {

        if view.frame.height < ListConstants.maxDividerHeight {
            divider(view)
        }

        if let table = view as? UITableView {
            self.table(table)
        }

        //Continue to iterate thru subview hierarchy
        for subview in view.subviews {
            hideDividerLineSubviews(of: subview)
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
