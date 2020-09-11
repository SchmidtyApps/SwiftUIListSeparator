//
//  List+Separator.swift
//  ListSeparator
//
//  Created by Mike Schmidt on 9/10/20.
//  Copyright © 2020 SchmidtyApps. All rights reserved.
//

import UIKit
import SwiftUI

extension View {
    /// Sets the separator style on Lists within this View
    /// - Parameters:
    ///   - style: Style of List separator
    ///   - color: Color of the List separator
    ///   - inset: Edge insets of the List separator
    /// - Returns: The List with the separator modified
    public func separator(style: ListSeparatorStyle, color: UIColor? = nil, inset: EdgeInsets? = nil) -> some View {
        self.separator(style: style, color: color, inset: inset, hideOnEmptyRows: false)
    }

    /// Sets the separator style on Lists within this View
    /// - Parameters:
    ///   - style: Style of List separator
    ///   - color: Color of the List separator
    ///   - inset: Edge insets of the List separator
    ///   - hideOnEmptyRows: If true hides divders on any empty rows ie rows shown in the footer
    /// - Returns: The List with the separator modified
    public func separator(style: ListSeparatorStyle, color: UIColor? = nil, inset: EdgeInsets? = nil, hideOnEmptyRows: Bool) -> some View {
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
        return AnyView(
            ZStack {
                DividerLineSeekerView(divider: { divider in
                    //If we encounter a separator view in this heirachy hide it
                    divider.isHidden = self.style == .none

                    if let color = self.color {
                        divider.backgroundColor = color
                    }

                    if let inset = self.inset {
                        divider.frame.origin.x = inset.left

                        if let parentWidth = divider.superview?.frame.size.width {
                            divider.frame.size.width = parentWidth - inset.left - inset.right
                        }
                    }

                }, table: { table in

                    if self.hideOnEmptyRows {
                        table.tableFooterView = UIView()
                    }

                    //Only set this pre ios14 otherwise it breaks our above hax
                    if #available(iOS 14, *) {
                        //Do nothing
                    } else {
                        table.separatorStyle = self.style == .none ? .none : .singleLine

                        if let color = self.color {
                            table.separatorColor = color
                        }

                        if let inset = self.inset {
                            table.separatorInset = inset
                        }
                    }
                })
                content
        })
    }
}

private struct DividerLineSeekerView : UIViewRepresentable {

    var divider: (UIView) -> Void
    var table: (UITableView) -> Void

    func makeUIView(context: Context) -> UIView  {
        InjectView(divider: divider, table: table)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

//View to inject so we can access UIKit views
class InjectView: UIView {
    var divider: (UIView) -> Void
    var table: (UITableView) -> Void

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
        let hostingView = self.getHostingView(view: self)
        self.hideDividerLineSubviews(of: hostingView)
    }

    func getHostingView(view: UIView) -> UIView {
        //crawl up the view hierarchy til we find the hosting view container
        if "\(type(of: view))".contains("HostingView") {
            return view
        }

        if let sup = view.superview {
            return getHostingView(view: sup)
        }

        return view
    }

    func hideDividerLineSubviews<T : UIView>(of view:T) {
        //If we encounter a separator view in this heirachy hide it
        if "\(type(of: view))".contains("Separator"), view.frame.height < 3 {
            divider(view)
            //                //view.isHidden = true
            //                view.backgroundColor = .red
            //                view.frame.origin.x = 50
        }

        if let table = view as? UITableView {
            self.table(table)
        }
        //
        //            //Only set this pre ios14 otherwise it breaks our above hax
        //            if #available(iOS 14, *) {
        //                //Do nothing
        //            } else {
        //                if let table = view as? UITableView {
        //                    table.separatorStyle = .none
        //                    // table.separatorColor = .red
        //                }
        //            }

        //Continue to iterate thru subview hierarchy
        for subview in view.subviews {
            hideDividerLineSubviews(of: subview)
        }
    }
}