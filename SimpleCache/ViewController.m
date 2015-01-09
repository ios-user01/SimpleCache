//
//  ViewController.m
//  SimpleCache
//
//  Created by kishikawa katsumi on 2015/01/08.
//  Copyright (c) 2015 kishikawa katsumi. All rights reserved.
//

#import "ViewController.h"
#import "SimpleCache.h"

@interface ViewController ()

@property (nonatomic) SimpleCache *imageCache;
@property (nonatomic) NSArray *imageURLs;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageCache = [[SimpleCache alloc] init];
    
    NSMutableArray *imageURLs = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 15; i++) {
        [imageURLs addObject:[NSString stringWithFormat:@"https://raw.githubusercontent.com/kishikawakatsumi/SimpleCache/image_api/SampleImages/%d.jpg", i]];
    }
    self.imageURLs = imageURLs;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.imageURLs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSURL *imageURL = [NSURL URLWithString:self.imageURLs[indexPath.row]];
    cell.imageURL = imageURL;
    
    [self.imageCache cancelDownloadURL:imageURL];
    
    UIImage *image = [self.imageCache imageWithURL:imageURL placeholderImage:nil completionHandler:^(UIImage *image, NSURL *imageURL, NSError *error) {
        if ([cell.imageURL isEqual:imageURL]) {
            cell.photoView.image = [self resizedImageWithImage:image];
        }
    }];
    cell.photoView.image = [self resizedImageWithImage:image];
    
    return cell;
}

- (UIImage *)resizedImageWithImage:(UIImage *)image {
    if (!image) {
        return nil;
    }
    
    CGSize size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.05, 0.05));
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    [image drawInRect:(CGRect){CGPointZero, size}];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

@end

@implementation ImageCell

@end
