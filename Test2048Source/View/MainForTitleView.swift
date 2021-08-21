//
//  MainForTitleView.swift
//  Test2048Source
//
//  Created by SathizMacMini on 21/08/21.
//

import UIKit

typealias ColorThemeScheme = [String : [String : String]]

class MainForTitleView: UIView {

    var destroy = false
    var position = (x: -1, y: -1)
    var cornerRadius: CGFloat = 0 {
        didSet {
            txtLbl.layer.cornerRadius = cornerRadius
        }
    }
    var value = -1 {
        didSet {
            if !valueHidden {
                txtLbl.text = "\(value)"
            }
            let str = value <= 2048 ? "\(value)" : "super"
            txtLbl.backgroundColor = colorType(str, key: "background")
            txtLbl.textColor = colorType(str, key: "text")
        }
    }
    var valueHidden = false {
        didSet {
            if valueHidden {
                txtLbl.text = ""
            }
        }
    }
    fileprivate func setup() {
        guard !isSetup else { return }
        isSetup = true
        alpha = 0
        
        txtLbl = UILabel()
        txtLbl.translatesAutoresizingMaskIntoConstraints = false
        txtLbl.font = UIFont.boldSystemFont(ofSize: 70)
        txtLbl.minimumScaleFactor = 0.4
        txtLbl.adjustsFontSizeToFitWidth = true
        txtLbl.textAlignment = .center
        txtLbl.clipsToBounds = true
        txtLbl.baselineAdjustment = .alignCenters
        txtLbl.backgroundColor = UIColor(white: 0.5, alpha: 0.2)
        
        self.addSubview(txtLbl)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-p-[valueLabel]-p-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: ["p": 5], views: ["valueLabel" : txtLbl]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-p-[valueLabel]-p-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: ["p": 5], views: ["valueLabel" : txtLbl]))
    }
    fileprivate func colorType(_ value: String, key: String) -> UIColor {
        if let colorScheme = theme {
            if let vDic = colorScheme[value], let s = vDic[key] {
                return UIColor.colorWithHex(s)
            } else {
                if let vDic = colorScheme["default"], let s = vDic[key] {
                    return UIColor.colorWithHex(s)
                }
            }
        }
        return UIColor.black
    }
    var theme: ColorThemeScheme?
    var txtLbl = UILabel()
    private var isSetup = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    
    
 
}

extension UIColor {
    class func colorWithHex(_ hex: String) -> UIColor {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("0X")) {
            cString = String(cString[cString.index(cString.startIndex, offsetBy: 2)..<cString.endIndex])
        }
        
        if (cString.count != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
