//
//  HelperFunctions.swift
//  Proximity
//
//  Created by Christopher Perkins on 10/7/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON

// Returns the height of the status bar (battery view, etc)
func getStatusBarHeight() -> CGFloat {
    let statusBarSize = UIApplication.shared.statusBarFrame.size
    return Swift.min(statusBarSize.width, statusBarSize.height)
}


// MARK: Extensions
extension UIView {
    @objc func setDefaultProperties() {
        // Override me!
    }
    
    // Add an array of views to a main view with equal vertical spacing
    func addSubviewsToViewWithYPadding(subviews: [UIView], spacing: CGFloat = -1) {
        var trueSpacing: CGFloat = spacing
        var headerFooterSpacing: CGFloat = 0
        
        // Get current height of all subviews
        var totalVerticalHeight:CGFloat = 0
        for view in subviews {
            totalVerticalHeight += view.frame.height
        }
        
        // If unassigned (or invalid), space equally through whole view
        if spacing < 0 {
            // Divide by subviews.count - 1 as we don't wait trailing spacing.
            // Example: 2 views needs 1 thing of padding (not two)
            trueSpacing = (self.frame.height - totalVerticalHeight) / CGFloat(subviews.count - 1)
        } else {
            // Divide by two because... there's a header and footer. 1 + 1 = 2
            headerFooterSpacing = (self.frame.height - totalVerticalHeight -
                spacing * (CGFloat(subviews.count) - 1)) / 2
        }
        
        // Add in each frame with appropriate spacing
        // Keep track of current forced height to prevent overlap
        var currentHeight: CGFloat = headerFooterSpacing
        for (index, view) in subviews.enumerated() {
            view.frame = CGRect(x: view.frame.minX,
                                y: currentHeight + trueSpacing * CGFloat(index),
                                width: view.frame.width, height: view.frame.height)
            currentHeight += view.frame.height
            
            self.addSubview(view)
        }
    }
    
    // Removes all subviews from a given view
    func removeAllSubviews() {
            for subview in self.subviews {
                subview.removeFromSuperview()
            }
    }
    
    // Removes itself from this superview by sliding up and fading out
    func removeSelfNicelyWithAnimation() {
        // Prevent user interaction with all subviews
        for subview in self.subviews {
            subview.isUserInteractionEnabled = false
        }
        
        // Slide up, then remove from view
        UIView.animate(withDuration: 0.5, animations: {
            self.frame = CGRect(x: 0,
                                y: -self.frame.height,
                                width: self.frame.width,
                                height: self.frame.height)
        }, completion: {
            (finished:Bool) -> Void in
            self.removeFromSuperview()
        })
    }
}

extension UITextField {
    override func setDefaultProperties() {
        // View select / deselect events
        self.addTarget(self, action: #selector(textfieldSelected(sender:)), for: .editingDidBegin)
        self.addTarget(self, action: #selector(textfieldDeselected(sender:)), for: .editingDidEnd)
        
        // View prettiness
        self.textAlignment = .center
        
        self.textfieldDeselected(sender: self)
    }
    
    func isNumeric() -> Bool {
        if self.text?.characters.count == 0 { return true }
        
        let setNums: Set<Character> = Set(arrayLiteral: "1", "2", "3", "4",
                                          "5", "6", "7", "8",
                                          "9", "0")
        
        return Set(self.text!.characters).isSubset(of: setNums)
    }
    
    // MARK: Textfield events
    
    @objc func textfieldSelected(sender: UITextField) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.backgroundColor = UIColor.niceYellow()
            sender.textColor = UIColor.white
        })
    }
    
    @objc func textfieldDeselected(sender: UITextField) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.backgroundColor = UIColor.white
            sender.textColor = UIColor.black
        })
    }
}

extension UILabel {
    override func setDefaultProperties() {
        self.font = UIFont.boldSystemFont(ofSize: 18.0)
        self.textAlignment = .center
        self.textColor = UIColor.white
    }
}

extension NSDate {
    // Get the current day of the week (in string format) ex: "Monday"
    public func dayOfTheWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self as Date)
    }
    
    public func getDayOfWeek(_ today:String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
}

extension UIColor {
    public static func niceGray() -> UIColor {
        return UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1)
    }
    
    public static func niceRed() -> UIColor {
        return UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1)
    }
    
    public static func niceBlue() -> UIColor {
        return UIColor(red: 0.291269, green: 0.459894, blue: 0.909866, alpha: 1)
    }
    
    public static func niceLightBlue() -> UIColor {
        return UIColor(red: 0.8, green: 0.78, blue: 0.96, alpha: 1)
    }
    
    public static func niceYellow() -> UIColor {
        return UIColor(red: 0.90, green: 0.70, blue: 0.16, alpha: 1)
    }
    
    public static func niceGreen() -> UIColor {
        return UIColor(red: 0.27, green: 0.66, blue: 0.3, alpha: 1)
    }
    
    public static func niceLightGreen() -> UIColor {
        return UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 1)
    }
}

extension String {
    var floatValue: Float? {
        return Float(self)
    }
}

extension NSLayoutConstraint {
    
    // Return a constraint that will center a view inside a view
    public static func createCenterViewHorizontallyInViewConstraint(view: UIView,
                                                                    inView: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: inView,
                                  attribute: .centerX,
                                  relatedBy: .equal,
                                  toItem: view,
                                  attribute: .centerX,
                                  multiplier: 1,
                                  constant: 0)
    }
    
    // Return a constraint that will place a view below a view with padding
    public static func createViewBelowViewConstraint(view: UIView,
                                                     belowView: UIView,
                                                     withPadding: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: belowView,
                                  attribute: .bottom,
                                  relatedBy: .equal,
                                  toItem: view,
                                  attribute: .top,
                                  multiplier: 1,
                                  constant: -withPadding)
    }
    
    // Return a constraint that will place a view below's top a view with padding
    public static func createViewBelowViewTopConstraint(view: UIView,
                                                        belowView: UIView,
                                                        withPadding: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: belowView,
                                  attribute: .top,
                                  relatedBy: .equal,
                                  toItem: view,
                                  attribute: .top,
                                  multiplier: 1,
                                  constant: -withPadding)
    }
    
    // Return a constraint that will create a width constraint for the given view
    public static func createWidthConstraintForView(view: UIView,
                                                    width: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view,
                                  attribute: .width,
                                  relatedBy: .equal,
                                  toItem: nil,
                                  attribute: .notAnAttribute,
                                  multiplier: 1,
                                  constant: width)
    }
    
    // Return a constraint that will create a height constraint for the given view
    public static func createHeightConstraintForView(view: UIView,
                                                     height: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view,
                                  attribute: .height,
                                  relatedBy: .equal,
                                  toItem: nil,
                                  attribute: .notAnAttribute,
                                  multiplier: 1,
                                  constant: height)
    }
    
    public static func createWidthCopyConstraintForView(view: UIView,
                                                        withCopyView: UIView,
                                                        plusWidth: CGFloat) -> NSLayoutConstraint{
        return NSLayoutConstraint(item: withCopyView,
                                  attribute: .width,
                                  relatedBy: .equal,
                                  toItem: view,
                                  attribute: .width,
                                  multiplier: 1,
                                  constant: -plusWidth)
    }
    
    public static func clingToViewEdges(view: UIView, toView: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: toView,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: toView,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: toView,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: toView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
}

extension UITableView {
    
    // Returns all cells in a uitableview
    public func getAllCells() -> [UITableViewCell] {
        var cells = [UITableViewCell]()
        
        for i in 0...self.numberOfSections - 1 {
            for j in 0...self.numberOfRows(inSection: i) {
                if let cell = self.cellForRow(at: IndexPath(row: j, section: i)) {
                    cells.append(cell)
                }
            }
        }
        
        return cells
    }
}

extension JSON {
    func jsonToData(json: JSON) -> Data?{
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) as Data
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil;
    }
}
