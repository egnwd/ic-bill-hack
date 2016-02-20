//
//  SelectImageView.m
//  imagepartition
//
//  Created by Jonathan King on 20/02/2016.
//  Copyright © 2016 Jonathan King. All rights reserved.
//

#import "SelectImageView.h"

#define PADDING 5 // Padding of 5 pts either side

@interface SelectImageView()
@property (readwrite, nonatomic) CGRect selection;
@property (nonatomic) NSMutableSet *points;
@end

@implementation SelectImageView

// WARNING: You may need to override initWithFrame if you create a SelectImageView outside interface builder

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        // disable multitouch - this messes with touch events when drawing
        [self setMultipleTouchEnabled:FALSE];
        
        // initialise the empty set of points
        _points = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)updateBoundingRect {
    
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
    
    // Scale the points, so it gives pixel data
    float scale =  self.image.size.width / self.frame.size.width;
    _selection = CGRectMake(MAX((minX - PADDING), 0),
                            MAX((minY - PADDING), 0),
                            (maxX + 2*PADDING - minX) * scale,
                            (maxY + 2*PADDING - minY) * scale);
    
    NSLog(@"%@", [NSValue valueWithCGRect:_selection]);
}


- (void)handleTouches:(NSSet<UITouch *> *)touches {
    
    // There should be exactly one touch
    assert(touches.count == 1);
    
    // Add the starting point to the set of points
    CGPoint position = [((UITouch *)touches.anyObject) preciseLocationInView:self];
    [_points addObject:[NSValue valueWithCGPoint:position]];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // Empty the previous set of points
    [_points removeAllObjects];
    
    // Add the starting point to the set of points
    [self handleTouches:touches];
    
    NSLog(@"Touches began");
    CGPoint position = [((UITouch *)touches.anyObject) preciseLocationInView:self];
    NSLog(@"%f %f", position.x, position.y);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Add the current point to the set of points
    [self handleTouches:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Add the end point to the set of points
    [self handleTouches:touches];
    
    // Calculate the bounding rect for the set of points
    [self updateBoundingRect];
}

@end