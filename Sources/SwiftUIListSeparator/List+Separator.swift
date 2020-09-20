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
        self.modifier(ListSeparatorModifier(style: style, color: color, inset: inset, hideOnEmptyRows: false))
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
        content
            .overlay(dividerSeeker())
    }
    
    private func dividerSeeker() -> some View {
        DividerLineSeekerView(divider: { divider in
            //If we encounter a separator view in this heirachy hide it
            switch self.style {
            case .none:
                divider.isHidden = true
                divider.backgroundColor = .clear
            case .singleLine:
                guard divider.tag != ListConstants.customDividerTag else { return  }

                //Hide the system divider
                divider.isHidden = true
                divider.backgroundColor = .clear

                //TODO: only add the custom divider 1 time

                //Add our custom divider which we have more control over
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
        uiView.dividerHandler.updateDividers()
    }
}

//View to inject so we can access UIKit views
class InjectView: UIView {
    var divider: (UIView) -> Void
    var table: (UITableView) -> Void
    
    //So we only inject the handler once
    private var didInjectDividerHandler: Bool = false
    //KVO on ScrollView so we can trigger continuing to update dividers on scroll
    private var scrollViewContentObserver: NSKeyValueObservation?
    
    lazy var dividerHandler: DividerHandlingView = {
        let dividerHandler = DividerHandlingView(divider: self.divider, table: self.table)
        dividerHandler.backgroundColor = .clear
        dividerHandler.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        return dividerHandler
    }()
    
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
    
    private func injectDividerHandler() {
        self.dividerHandler.updateDividers()
        
        guard !didInjectDividerHandler, let parentVC = findViewController(), let scrollView = findScrollView(in: parentVC.view) else { return }
        
        scrollView.addSubview(dividerHandler)
        scrollView.bringSubviewToFront(dividerHandler)
        
        //Update the dividers anytime content offset changes indicating a scroll event
        self.scrollViewContentObserver = scrollView.observe(\UIScrollView.contentOffset, options: .new) { (_, _) in

            //TODO: this happens for every offset change including fast scroll/fling. We should make it more performant

            self.dividerHandler.updateDividers()
        }
        
        self.didInjectDividerHandler = true
    }
    
    //Recursive search for scroll view in subviews
    private func findScrollView(in view: UIView) -> UIScrollView? {
        
        //Found the scrollview so just retunr it
        if let scrollView = view as? UIScrollView {
            return scrollView
        }
        
        //Continue to iterate thru subview hierarchy
        for subview in view.subviews {
            return findScrollView(in: subview)
        }
        
        return nil
    }
}

//View that will be injected into the scroll view and handles modifying divider lines
class DividerHandlingView: UIView {
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
        updateDividers()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateDividers()
    }
    
    func updateDividers() {
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
