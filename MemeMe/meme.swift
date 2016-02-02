//
//  meme.swift
//  MemeMe
//
//  Created by Klaudyna Marciniak on 24.11.2015.
//  Copyright © 2015 Klaudyna Marciniak. All rights reserved.
//

import Foundation
import UIKit

class meme: NSObject {

    var topString : String
    var bottomString : String
    var pickedImage: UIImage
    var memeImage: UIImage
    
   
    init(topString: String, bottomString: String, pickedImage: UIImage, memeImage: UIImage){
        self.topString = topString
        self.bottomString = bottomString
        self.pickedImage = pickedImage
        self.memeImage = memeImage
    }

}
