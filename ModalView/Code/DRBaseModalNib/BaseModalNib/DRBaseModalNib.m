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
@property (nonatomic, assign) DRBaseModalPosition position;
@property (nonatomic, assign) BOOL isVisible;

@end

@implementation DRBaseModalNib

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundView = [DRBackgroundView createView];
    self.backgroundView.delegate = self;
    if (self.shouldHideByTap) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedBackgroundView)];
        
        [self addGestureRecognizer:tapGesture];
    }
    
    
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
    self.position = viewPosition;
    [self scaleView];
    
    self.backgroundView.presentedColor = self.modaBackgroundColor;
    self.backgroundView.shouldHideByTap = self.shouldHideByTap;
    
    [self.backgroundView showOnView:nil withCompletionBlock:nil];
    
    [self presentNidOnView:self.backgroundView withPosition:viewPosition];
}

- (void)showOnView:(UIView *)baseView atPosition:(DRBaseModalPosition)viewPosition withAnimationType:(DRBaseModalAnimation)animationType;
{    
    self.shouldHideProgrammatically = NO;
    self.animationType = animationType;
    self.position = viewPosition;
    [self scaleView];
    
    self.backgroundView.presentedColor = self.modaBackgroundColor;
    self.backgroundView.shouldHideByTap = self.shouldHideByTap;
    
    [self.backgroundView showOnView:baseView withCompletionBlock:nil];
    
    [self presentNidOnView:baseView withPosition:viewPosition];
}

- (void)hide
{
    __weak DRBaseModalNib *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf hidePrivate];
        
        if (weakSelf.backgroundView) {
            weakSelf.shouldHideProgrammatically = YES;
            weakSelf.backgroundView.shouldHideByTap = YES;
            [weakSelf.backgroundView touchedBackgroundView];
        }
    });
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
    if (viewPosition == DRBaseModalPositionCenter) {
        deepRect.origin.x = (baseView.frame.size.width-self.frame.size.width)/2; //move to correct x position if Presented view Smaller than width
    }
    
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
    CGRect initialRect = self.frame;
    initialRect.origin.x = ([UIScreen mainScreen].bounds.size.width-self.self.frame.size.width)/2;
    initialRect.origin.y = -self.frame.size.height;
    self.frame = initialRect;
    
    CGRect inViewRect = self.frame;
    inViewRect.origin.y = 0;
    inViewRect.origin.x = ([UIScreen mainScreen].bounds.size.width-self.self.frame.size.width)/2;
    __weak DRBaseModalNib *weakSelf = self;
    
    if (self.animationType != DRBaseModalAnimationNone) {
        [UIView animateWithDuration:kDRDefaultAnimationDuration animations:^{
            weakSelf.frame = inViewRect;
        }];
    } else {
        self.frame = inViewRect;
    }
}

- (void)showViewAtBottom:(UIView *)baseView
{
    CGRect inViewRect = self.frame;
    inViewRect.origin.y = baseView.bounds.size.height - self.frame.size.height;
    if (self.animationType != DRBaseModalAnimationNone) {
        [self producePopUpAnimationWithFinalRect:inViewRect];
    } else {
        self.frame = inViewRect;
    }
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
            [self producePopUpAnimationWithFinalRect:CGRectMake((baseView.frame.size.width-self.frame.size.width)/2,
                                                                (baseView.frame.size.height-self.frame.size.height)/2,
                                                                self.frame.size.width,
                                                                self.frame.size.height)];
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
    [self endEditing:YES];
}

- (void)touchedBackgroundView
{
    
}

- (void)scaleView
{
    CGPoint actualCenter = self.center;
    CGRect actualFrame = self.frame;
    CGFloat width = [UIScreen mainScreen].bounds.size.width - (375 - self.frame.size.width);
    actualFrame.size.width = width;
    actualCenter.x = [UIScreen mainScreen].bounds.size.width/2;
    
    self.frame = actualFrame;
    self.center = actualCenter;
}

#pragma mark - Animation Methods

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
    deepRect.origin.y = (self.position == DRBaseModalPositionTop) ? -self.frame.size.height : self.backgroundView.bounds.size.height;
    
    __weak DRBaseModalNib *weakSelf = self;
    [UIView animateWithDuration:kDRDefaultAnimationDuration animations:^{
        weakSelf.frame = deepRect;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

@end
