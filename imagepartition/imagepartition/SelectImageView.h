//
//  SelectImageView.h
//  imagepartition
//
//  Created by Jonathan King on 20/02/2016.
//  Copyright © 2016 Jonathan King. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectImageViewDelegate;

@interface SelectImageView : UIImageView
@property (nonatomic, weak) id<SelectImageViewDelegate> delegate;
@end

@protocol SelectImageViewDelegate <NSObject>
- (void)selectionWasMade:(CGRect)selection;
@end