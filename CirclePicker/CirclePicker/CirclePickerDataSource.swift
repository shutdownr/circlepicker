//
//  CirclePickerDataSource.swift
//  CirclePicker
//
//  Created by Tim Kreuzer on 22.01.18.
//  Copyright © 2018 Tim Kreuzer. All rights reserved.
//

import UIKit

protocol CirclePickerDataSource {
    func circlePicker(_ : CirclePicker, imageForIndex index: Int) -> UIImage
    func numberOfCells(in: CirclePicker) -> Int
}
