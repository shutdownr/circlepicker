//
//  CirclePickerDelegate.swift
//  CirclePicker
//
//  Created by Tim Kreuzer on 20.01.18.
//  Copyright © 2018 Tim Kreuzer. All rights reserved.
//

import UIKit

@objc protocol CirclePickerDelegate {
    @objc optional func didStartSelection(in circlePicker: CirclePicker)
    @objc optional func circlePicker(_ circlePicker: CirclePicker, didSelectRowAt index: Int)
    @objc optional func circlePicker(_ circlePicker: CirclePicker, didEndSelectionAt index: Int)
    @objc optional func circlePicker(_ circlePicker: CirclePicker, didDeselectRowAt index: Int)
}
