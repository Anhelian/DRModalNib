//
//  DRBaseBackgroundView.m
//  Denis Romashov
//
//  Created by Denis Romashov on 22.07.15.
//  Copyright (c) 2015 InMotion Soft. All rights reserved.
//

#import "DRBackgroundView.h"

static CGFloat const kDRDefaultAnimationDuration = 0.33;

@implementation DRBackgroundView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.shouldHideByTap = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedBackgroundView)];
        
        [self addGestureRecognizer:tapGesture];
    }
    
    return self;
}

+ (DRBackgroundView *)createView
{
    return [[DRBackgroundView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}


#pragma mark -
#pragma mark Public Methods

- (void)showWithCompletionBlock:(void (^)())completionBlock
{
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];

    
    UIColor *finalColor = (self.presentedColor) ? self.presentedColor : [UIColor colorWithWhite:0 alpha:0.5];
    self.backgroundColor = [UIColor clearColor];
    
    __weak DRBackgroundView *weakSelf = self;
    [UIView animateWithDuration:kDRDefaultAnimationDuration animations:^{
        weakSelf.backgroundColor = finalColor;
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)touchedBackgroundView
{
    if (self.shouldHideByTap) {
        
        if ([self.delegate respondsToSelector:@selector(backgroundViewWillHide:withCompletionBlock:)]) {
            [self.delegate backgroundViewWillHide:self withCompletionBlock:^{
                
                __weak DRBackgroundView *weakSelf = self;
                [UIView animateWithDuration:kDRDefaultAnimationDuration animations:^{
                    weakSelf.alpha = 0;
                } completion:^(BOOL finished) {
                    [weakSelf removeFromSuperview];
                }];
            }];
        }
    }
}

@end
