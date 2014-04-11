//
//  OverlaySelectionView.m
//  TestRect
//
//  Created by liucc on 3/20/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import "OverlaySelectionView.h"

@interface OverlaySelectionView()
@property (nonatomic, retain) UIView* dragArea;
@end

@implementation OverlaySelectionView

@synthesize dragArea;
@synthesize delegate;

- (void) initialize {
    dragAreaBounds = CGRectMake(0, 0, 0, 0);
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}
- (id) initWithCoder: (NSCoder*) coder {
    self = [super initWithCoder: coder];
    if (self != nil) {
        [self initialize];
    }
    return self;
}

- (id) initWithFrame: (CGRect) frame {
    self = [super initWithFrame: frame];
    if (self != nil) {
        [self initialize];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // do nothing
}

#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [[event allTouches] anyObject];
    dragAreaBounds.origin = [touch locationInView:self];
}
- (void)handleTouch:(UIEvent *)event {
    UITouch* touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self];
    
    dragAreaBounds.size.height = location.y - dragAreaBounds.origin.y;
    dragAreaBounds.size.width = location.x - dragAreaBounds.origin.x;
    
    if (self.dragArea == nil) {
        UIView* area = [[UIView alloc] initWithFrame: dragAreaBounds];
        area.backgroundColor = [UIColor blueColor];
        area.opaque = NO;
        area.alpha = 0.3f;
        area.userInteractionEnabled = NO;
        self.dragArea = area;
        [self addSubview: self.dragArea];
    } else {
        self.dragArea.frame = dragAreaBounds;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouch: event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouch: event];
    
    if (self.delegate != nil) {
        [delegate areaSelected: dragAreaBounds];
    }
    [self initialize];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self initialize];
    [self.dragArea removeFromSuperview];
    self.dragArea = nil;
}

#pragma mark -


@end
