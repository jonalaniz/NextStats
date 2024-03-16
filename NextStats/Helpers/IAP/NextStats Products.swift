//
//  NextStats Products.swift
//  NextStats
//
//  Created by Jon Alaniz on 11/17/20.
//  Copyright © 2020 Jon Alaniz.
//

import Foundation

public struct NextStatsProducts {

    public static let SmallTip = "com.jonalaniz.nextstats.smalltip"
    public static let MediumTip = "com.jonalaniz.nextstats.mediumtip"
    public static let LargeTip = "com.jonalaniz.nextstats.largetip"
    public static let MassiveTip = "com.jonalaniz.nextstats.massivetip"

    private static let productIdentifiers: Set<ProductIdentifier> = [NextStatsProducts.SmallTip,
                                                                     NextStatsProducts.MediumTip,
                                                                     NextStatsProducts.LargeTip,
                                                                     NextStatsProducts.MassiveTip]

    public static let store = IAPHelper(productIds: NextStatsProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
