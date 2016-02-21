//
//  SelectImageView.m
//  imagepartition
//
//  Created by Jonathan King on 20/02/2016.
//  Copyright © 2016 Jonathan King. All rights reserved.
//

#import "SelectImageView.h"

// TODO: add padding to the delegate
#define HORIZONTAL_PADDING 5 // Padding of 5 pts either side
#define VERTICAL_PADDING 8 // Padding of 5 pts either side

@interface SelectImageView()
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
    
    // Add padding
    minX -= HORIZONTAL_PADDING;
    maxX += HORIZONTAL_PADDING;
    minY -= VERTICAL_PADDING;
    maxY += VERTICAL_PADDING;
    
    // Scale the coordinates
    minX *= scale;
    maxX *= scale;
    minY *= scale;
    maxY *= scale;
    
    // Bound the coordinates to the image
    minX = MAX(minX, 0);
    minY = MAX(minY, 0);
    maxX = MIN(maxX, self.image.size.width);
    maxY = MIN(maxY, self.image.size.height);
    
    CGRect selection = CGRectMake(minX,
                            minY,
                            maxX - minX,
                            maxY - minY);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.image CGImage], selection);
    UIImage *selectedArea = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    // Borrowed with love from
    // http://www.raywenderlich.com/69855/image-processing-in-ios-part-1-raw-bitmap-modification
    
    #define Mask8(x) ( (x) & 0xFF )
    #define R(x) ( Mask8(x) )
    #define G(x) ( Mask8(x >> 8 ) )
    #define B(x) ( Mask8(x >> 16) )
    #define A(x) ( Mask8(x >> 24) )
    #define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )
    
    // 1. Get the raw pixels of the image
    UInt32 * inputPixels;
    
    CGImageRef inputCGImage = [selectedArea CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGImage);
    NSUInteger inputHeight = CGImageGetHeight(inputCGImage);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), inputCGImage);

    // 2.  Convert the image to Black & White and keep track of the all 'white' rows
    
    boolean_t *emptyRow = (boolean_t *)calloc(inputHeight, sizeof(boolean_t));
    
    for (NSUInteger j = 0; j < inputHeight; j++) {
        emptyRow[j] = 0;
        for (NSUInteger i = 0; i < inputWidth; i++) {
            UInt32 * currentPixel = inputPixels + (j * inputWidth) + i;
            UInt32 color = *currentPixel;
            
            // Average of RGB = greyscale
            UInt32 averageColor = (R(color) + G(color) + B(color)) / 3.0;
            averageColor = (averageColor > 45) ? 255 : 0;
            
            emptyRow[j] |= (255 - averageColor);
            
            *currentPixel = RGBAMake(averageColor, averageColor, averageColor, A(color));
        }
    }
    
    // 3. Find longest chain where there are no more than 5 consective empty rows
    
    #define MAX_ZERO 5
    
    // The start and end of the maximum sequence
    int start = 0;
    int end = 0;
    
    int count = 0; // number of consecutive empty rows encountered, initially zero
    int new_start = 0;
    
    for (int j = 0; j < inputHeight; j++) {
        if (emptyRow[j] == 0) {
            if (count == 0) {
                // We have reached the end of the sequence, or we have yet to begin a sequence
                new_start = j+1;
            } else {
                count --;
            }
        } else {
            // We have a one
            if (j - new_start > end - start) {
                // if we have a new max sequence, set it
                start = new_start;
                end = j;
            }
            // Reset the count to MAX_ZERO
            count = MAX_ZERO;
        }
    }
    
    NSLog(@"Max of length: %d, between (%d, %d)", end - start, start, end);
    
    CGFloat croppedHeight = end - start;
    
    CGRect cropped = CGRectMake(minX, minY + start, maxX - minX, croppedHeight);
    
    // 4. Cleanup!
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(inputPixels);
    free(emptyRow);
    
    id<SelectImageViewDelegate> strongDelegate = self.delegate;
    
    // Our delegate method is optional, so we should
    // check that the delegate implements it
    if ([strongDelegate respondsToSelector:@selector(selectionWasMade:)]) {
        [strongDelegate selectionWasMade:cropped];
    }
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
