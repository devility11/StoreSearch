//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Norbert Czirjak on 2017. 11. 15..
//  Copyright © 2017. Norbert Czirjak. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    //this will leave the searchviewvontroller visible when we tap on a row,
    //to get the detail view popup
    override var shouldRemovePresentersView: Bool {
        return false
    }
}
