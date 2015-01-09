//
//  ViewController.h
//  SimpleCache
//
//  Created by kishikawa katsumi on 2015/01/08.
//  Copyright (c) 2015 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UITableViewController

@end

@interface ImageCell : UITableViewCell

@property (nonatomic) IBOutlet UIImageView *photoView;
@property (nonatomic) NSURL *imageURL;

@end
