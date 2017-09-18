//
//  DRBaseBackgroundView.m
//  Denis Romashov
//
//  Created by Denis Romashov on 22.07.17.
//  Copyright (c) 2017 Denis Romashov. All rights reserved.
//

#import "DRBackgroundView.h"

static CGFloat const kDRDefaultAnimationDuration = 0.33;

@implementation DRBackgroundView

+ (DRBackgroundView *)createView
{
    return [[DRBackgroundView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}


#pragma mark -
#pragma mark Public Methods

- (void)showOnView:(UIView *)presentationView withCompletionBlock:(void (^)(void))completionBlock
{
    if (!presentationView) {
        [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    } else {
        [presentationView addSubview:self];
    }
    
    if (self.shouldHideByTap) {
        UIButton *hideButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        hideButton.frame = self.bounds;
        [hideButton addTarget:self action:@selector(touchedBackgroundView) forControlEvents:(UIControlEventTouchUpInside)];
        [self addSubview:hideButton];
    }
    
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

@end
