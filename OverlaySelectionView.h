//
//  OverlaySelectionView.h
//  TestRect
//
//  Created by liucc on 3/20/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>

@protocol OverlaySelectionViewDelegate
// callback when user finishes selecting map region
- (void) areaSelected: (CGRect)screenArea;
@end


@interface OverlaySelectionView : UIView {
    UIView* dragArea;
    CGRect dragAreaBounds;
}

@property (nonatomic, assign) id<OverlaySelectionViewDelegate> delegate;

@end