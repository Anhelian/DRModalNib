//
//  DRBaseModalNib.m
//  Denis Romashov
//
//  Created by Denis Romashov on 22.07.15.
//  Copyright (c) 2015 InMotion Soft. All rights reserved.
//

#import "DRBaseModalNib.h"
#import "DRBackgroundView.h"

static CGFloat const kDRDefaultAnimationDuration = 0.33;

@interface DRBaseModalNib () <DRBackgroundViewDelegate>

@property (nonatomic, strong) DRBackgroundView *backgroundView;
@property (nonatomic, assign) BOOL shouldHideProgrammatically;
@property (nonatomic, assign) DRBaseModalAnimation animationType;
@property (nonatomic, assign) BOOL isVisible;

@end

@implementation DRBaseModalNib

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundView = [DRBackgroundView createView];
    self.backgroundView.delegate = self;
    
    [self loadDefaultOptions];
}

- (void)loadDefaultOptions
{
    self.shouldHideByTap = YES;
}


#pragma mark -
#pragma mark Public methods

+ (instancetype)createView
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
}

- (void)showAtPosition:(DRBaseModalPosition)viewPosition withAnimationType:(DRBaseModalAnimation)animationType;
{
    self.shouldHideProgrammatically = NO;
    self.animationType = animationType;
    
    self.backgroundView.presentedColor = self.modaBackgroundColor;
    self.backgroundView.shouldHideByTap = self.shouldHideByTap;
    
    [self.backgroundView showWithCompletionBlock:nil];
    
    [self presentNidOnView:self.backgroundView withPosition:viewPosition];
}

- (void)showOnView:(UIView *)baseView atPosition:(DRBaseModalPosition)viewPosition withAnimationType:(DRBaseModalAnimation)animationType;
{    
    self.shouldHideProgrammatically = NO;
    self.animationType = animationType;
    
    [self presentNidOnView:baseView withPosition:viewPosition];
}

- (void)hide
{
    [self hidePrivate];

    if ([self.backgroundView.subviews containsObject:self]) {
        self.shouldHideProgrammatically = YES;
        self.backgroundView.shouldHideByTap = YES;
        [self.backgroundView touchedBackgroundView];
    }
}


#pragma mark -
#pragma mark KRBaseBackgroundViewDelegate

- (void)backgroundViewWillHide:(DRBackgroundView *)backgroundVew withCompletionBlock:(void (^)())completionBlock
{
    if ([self.baseModalNibDelegate respondsToSelector:@selector(baseModaViewBackgroundDidTapped:)]) {
        [self.baseModalNibDelegate baseModaViewBackgroundDidTapped:self];
    }
    
    if (!self.shouldHideProgrammatically) {
        [self hidePrivate];
    }
    
    if (completionBlock) {
        completionBlock();
    }
}


#pragma mark -
#pragma mark Helpers

- (void)presentNidOnView:(UIView *)baseView withPosition:(DRBaseModalPosition)viewPosition
{
    self.isVisible = YES;
    
    CGRect deepRect = self.frame;
    deepRect.origin.y = baseView.bounds.size.height;
    self.frame = deepRect;
    [baseView addSubview:self];
    
    switch (viewPosition) {
        case DRBaseModalPositionBottom:
            [self showViewAtBottom:baseView];
            break;
        case DRBaseModalPositionCenter:
            [self showViewAtCenter:baseView];
            break;
        case DRBaseModalPositionTop:
            [self showViewAtTop];
            break;
        default:
            break;
    }
}

- (void)showViewAtTop
{
    CGRect inViewRect = self.frame;
    inViewRect.origin = CGPointZero;
    
    __weak DRBaseModalNib *weakSelf = self;
    [UIView animateWithDuration:kDRDefaultAnimationDuration animations:^{
        weakSelf.frame = inViewRect;
    }];
}

- (void)showViewAtBottom:(UIView *)baseView
{
    CGRect inViewRect = self.frame;
    inViewRect.origin.y = baseView.bounds.size.height - self.frame.size.height;
    [self producePopUpAnimationWithFinalRect:inViewRect];
}

- (void)showViewAtCenter:(UIView *)baseView
{
    [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                    attribute:(NSLayoutAttributeCenterX)
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:baseView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1
                                                                     constant:0]];
    
    [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                    attribute:(NSLayoutAttributeCenterY)
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:baseView
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1
                                                                     constant:0]];
    switch (self.animationType) {
        case DRBaseModalAnimationFadeIn:
            [self produceFadeInAnimation];
            break;
        case DRBaseModalAnimationPopUp:
            [self producePopUpAnimationWithFinalRect:baseView.frame];
            break;
        case DRBaseModalAnimationNone:
            self.frame = baseView.frame;
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark Help Methods

- (void)hidePrivate
{
    switch (self.animationType) {
        case DRBaseModalAnimationPopUp:
            [self produceDropDownAnimation];
            break;
        case DRBaseModalAnimationFadeIn:
            [self produceFadeOutAnimation];
            break;
        default:
            [self produceDropDownAnimation];
            break;
    }
    
    self.isVisible = NO;
}


#pragma mark -
#pragma mark Animation Methods

- (void)produceFadeInAnimation
{
    self.alpha = 0;
    self.center = self.backgroundView.center;
    
    __weak DRBaseModalNib *weakSelf = self;
    [UIView animateWithDuration:kDRDefaultAnimationDuration animations:^{
        weakSelf.alpha = 1;
    }];
}

- (void)producePopUpAnimationWithFinalRect:(CGRect)finalRect
{
    __weak DRBaseModalNib *weakSelf = self;
    [UIView animateWithDuration:kDRDefaultAnimationDuration animations:^{
        weakSelf.frame = finalRect;
    }];
}

- (void)produceFadeOutAnimation
{
    __weak DRBaseModalNib *weakSelf = self;
    [UIView animateWithDuration:kDRDefaultAnimationDuration animations:^{
        weakSelf.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

- (void)produceDropDownAnimation
{
    CGRect deepRect = self.frame;
    deepRect.origin.y = self.backgroundView.bounds.size.height;
    
    __weak DRBaseModalNib *weakSelf = self;
    [UIView animateWithDuration:kDRDefaultAnimationDuration animations:^{
        weakSelf.frame = deepRect;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

@end
