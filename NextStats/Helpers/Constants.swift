//
//  Constants.swift
//  NextStats
//
//  Created by Jon Alaniz on 8/2/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import Foundation
import UIKit

// UIColors
let accentColor = UIColor(red: 87/255, green: 96/255, blue: 155/255, alpha: 1)
let backgroundColor = UIColor(displayP3Red: 22/255, green: 23/255, blue: 37/255, alpha: 1)
let cellBackgroundColor = UIColor(red: 44/255, green: 48/255, blue: 78/255, alpha: 1)
let placeholderTextColor = UIColor(red: 149/255, green: 152/255, blue: 167/255, alpha: 0.4)

// RegEx

// let urlRegEx = "^(https://|http://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
// let ipRegEx = #"(^192\.168\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])$)|(^172\.([1][6-9]|[2][0-9]|[3][0-1])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])$)|(^10\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])$)"#

let urlRegEx = #"^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$"#

let ipRegEx = #"(^192\.168\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])?\:([0-9]+)$)|(^172\.([1][6-9]|[2][0-9]|[3][0-1])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])?\:([0-9]+)$)|(^10\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])?\:([0-9]+)$)"#

// Endpoints

let statEndpoint = "/ocs/v2.php/apps/serverinfo/api/v1/info?format=json"
