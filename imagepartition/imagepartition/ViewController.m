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
@property (nonatomic) CGRect selection;
@property (nonatomic) NSMutableSet *points;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // disable multitouch - this messes with touch events when drawing
    [self.view setMultipleTouchEnabled:FALSE];
    
    // initialise the empty set of points
    _points = [[NSMutableSet alloc] init];
    
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

- (void)updatePartition {
    CGImageRef imageRef = CGImageCreateWithImageInRect([_imageView.image CGImage], _selection);
    UIImage *partitionImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    _partitionImageView.image = partitionImage;
}

- (void)handleTouches:(NSSet<UITouch *> *)touches {
   
    // There should be exactly one touch
    assert(touches.count == 1);
    
    // Add the starting point to the set of points
    for (UITouch *touch in touches) {
        CGPoint position = [touch preciseLocationInView:_imageView];
        [_points addObject:[NSValue valueWithCGPoint:position]];
    }
}

- (void)calculateBoundingRect {
    
    // There must be at least one point
    assert(_points.count > 0);
    
    // Choose any point first the intial comparison
    CGPoint point = ((NSValue *)_points.anyObject).CGPointValue;
    
    CGFloat minX = point.x;
    CGFloat maxX = point.x;
    CGFloat minY = point.y;
    CGFloat maxY = point.y;
    
    for (NSValue *value in _points) {
        CGPoint point = value.CGPointValue;
        
        minX = MIN(minX, point.x);
        maxX = MAX(maxX, point.x);
        minY = MIN(minY, point.y);
        maxY = MAX(maxY, point.y);
    }
    
    _selection = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    NSLog(@"%@", [NSValue valueWithCGRect:_selection]);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // Empty the previous set of points
    [_points removeAllObjects];
    
    // Add the starting point to the set of points
    [self handleTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Add the current point to the set of points
    [self handleTouches:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Add the end point to the set of points
    [self handleTouches:touches];
    
    // Calculate the bounding rect for the set of points
    [self calculateBoundingRect];
    
    // Update the partition
    [self updatePartition];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
