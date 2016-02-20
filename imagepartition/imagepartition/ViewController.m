//
//  ViewController.m
//  imagepartition
//
//  Created by Jonathan King on 20/02/2016.
//  Copyright © 2016 Jonathan King. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *partitionImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // disable multitouch - this messes with touch events when drawing
    [self.view setMultipleTouchEnabled:FALSE];
    
    UIImage *image = [UIImage imageNamed:@"sainsbury.jpg"];
    NSLog(@"%@", image);
    _imageView.image = image;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // Partition the image
    CGRect cropRect = CGRectMake(900, 800, 400, 100);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *partitionImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    _partitionImageView.image = partitionImage;
    _partitionImageView.contentMode = UIViewContentModeScaleAspectFit;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
