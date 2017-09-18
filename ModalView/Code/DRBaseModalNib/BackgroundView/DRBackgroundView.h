//
//  DRBaseBackgroundView.h
//  Denis Romashov
//
//  Created by Denis Romashov on 22.07.15.
//  Copyright (c) 2015 InMotion Soft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRBackgroundView;
@protocol DRBackgroundViewDelegate <NSObject>

- (void)backgroundViewWillHide:(DRBackgroundView *)backgroundVew withCompletionBlock:(void(^)())completionBlock;

@end


@interface DRBackgroundView : UIView

@property (nonatomic, weak) id<DRBackgroundViewDelegate> delegate;
@property (nonatomic, strong) UIColor *presentedColor;
@property (nonatomic, assign) BOOL shouldHideByTap;

+ (DRBackgroundView *)createView;

- (void)showOnView:(UIView *)presentationView withCompletionBlock:(void (^)())completionBlock;
- (void)touchedBackgroundView;

@end
