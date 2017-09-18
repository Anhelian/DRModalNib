//
//  DRBaseBackgroundView.h
//  Denis Romashov
//
//  Created by Denis Romashov on 22.07.17.
//  Copyright (c) 2017 Denis Romashov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRBackgroundView;
@protocol DRBackgroundViewDelegate <NSObject>

- (void)backgroundViewWillHide:(DRBackgroundView *)backgroundVew withCompletionBlock:(void(^)(void))completionBlock;

@end


@interface DRBackgroundView : UIView

@property (nonatomic, weak) id<DRBackgroundViewDelegate> delegate;
@property (nonatomic, strong) UIColor *presentedColor;
@property (nonatomic, assign) BOOL shouldHideByTap;

+ (DRBackgroundView *)createView;

- (void)showOnView:(UIView *)presentationView withCompletionBlock:(void (^)(void))completionBlock;
- (void)touchedBackgroundView;

@end
