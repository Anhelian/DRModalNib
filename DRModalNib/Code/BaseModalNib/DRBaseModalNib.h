//
//  DRBaseModalNib.h
//  Denis Romashov
//
//  Created by Denis Romashov on 22.07.15.
//  Copyright (c) 2015 InMotion Soft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DRBaseModalPosition)
{
    DRBaseModalPositionTop,
    DRBaseModalPositionBottom,
    DRBaseModalPositionCenter
};

typedef NS_ENUM(NSUInteger, DRBaseModalAnimation)
{
    DRBaseModalAnimationNone,
    DRBaseModalAnimationPopUp,
    DRBaseModalAnimationFadeIn,
};


@class DRBaseModalNib;
@protocol DRBaseModalNibDelegate <NSObject>

- (void)baseModaViewBackgroundDidTapped:(DRBaseModalNib *)baseView;

@end


@interface DRBaseModalNib : UIView

@property (nonatomic, weak) id<DRBaseModalNibDelegate> baseModalNibDelegate;
@property (nonatomic, strong) UIColor *modaBackgroundColor;
@property (nonatomic, assign) BOOL shouldHideByTap; // By default YES
@property (nonatomic, assign, readonly) BOOL isVisible;

+ (instancetype)createView;

- (void)showAtPosition:(DRBaseModalPosition)viewPosition withAnimationType:(DRBaseModalAnimation)animationType;
- (void)showOnView:(UIView *)baseView atPosition:(DRBaseModalPosition)viewPosition withAnimationType:(DRBaseModalAnimation)animationType;


- (void)hide;

@end
