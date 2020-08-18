#import <RemoteLog.h>
//#import <ControlCenterUI/CCUIContentModuleContainerView.h>
//#import <ControlCenterUI/CCUIModuleCollectionViewController.h>
//#import <SpringBoardHome/SBCloseBoxView.h>

//#import <SpringBoardHome/SBXCloseBoxView.h>

@interface SBXCloseBoxView : UIButton
@end

@interface CCUIStatusBar:UIView
-(void)heldForALongTime:(UILongPressGestureRecognizer *)Gesture;
@end

@interface CCUIModuleCollectionViewController : UIViewController
@property(nonatomic, assign) BOOL enabled;
-(void)toggleWiggleMode;
@end

@interface CCUIContentModuleContainerView: UIView
-(void)addShakeAnimation;
-(void)removeCrossButton;
-(void)removeShakeAnimation;
-(void)animatedAddCrossButton;
-(void)animatedRemoveCrossButton;
@end


CCUIModuleCollectionViewController* moduleViewController= nil;


%hook CCUIContentModuleContainerView




%new
-(void)addShakeAnimation{    
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];

    CGFloat wobbleAngle = 0.04f;

    NSValue* valLeft = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(wobbleAngle, 0.0f, 0.0f, 1.0f)];
    NSValue* valRight = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-wobbleAngle, 0.0f, 0.0f, 1.0f)];
    animation.values = [NSArray arrayWithObjects:valLeft, valRight, nil];

    animation.autoreverses = YES;
    animation.duration = 0.125;
    animation.repeatCount = HUGE_VALF;
    [[self layer] removeAnimationForKey:@"position"];
    [[self layer] addAnimation:animation forKey:@"position"];
}

%new
-(void)removeShakeAnimation{
    [[self layer] removeAnimationForKey:@"position"];
}


%new
-(void)animatedAddCrossButton{
    UIButton *cancelButton = [%c(SBXCloseBoxView) buttonWithType:UIButtonTypeRoundedRect];
    //[cancelButton addTarget:self action:@selector(handleExit) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setFrame:CGRectMake(-11, -11, 26, 26)];
    //[cancelButton setTitle:@"x" forState:UIControlStateNormal];
    [cancelButton setTag:0010];
    cancelButton.alpha = 0.01;
    id view = [self viewWithTag:0010];
    while (view != nil){
        [view removeFromSuperview];
        view = [self viewWithTag:0010];
    }
    [self addSubview:cancelButton];
    UIView* newSubView = [self viewWithTag:0010];
    newSubView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration:0.2
        animations:^{newSubView.transform = CGAffineTransformMakeScale(1, 1); newSubView.alpha = 0.8;}
        completion:^(BOOL finished){}];


}


%new
-(void)animatedRemoveCrossButton{
    UIView* view = [self viewWithTag:0010];
    [UIView animateWithDuration:0.2
        animations:^{view.transform = CGAffineTransformMakeScale(0.4, 0.4); view.alpha = 0.01;}
        completion:^(BOOL finished){[self removeCrossButton];}];
}


%new
-(void)removeCrossButton{
    id view = [self viewWithTag:0010];
    [view removeFromSuperview];
}

%end


%hook CCUIModuleCollectionViewController
//- (id)_moduleInstances


%property(nonatomic, assign) BOOL enabled;

%new
-(void)toggleWiggleMode{
    if (!self.enabled){
        for (CCUIContentModuleContainerView* view in self.view.subviews){
            [view addShakeAnimation];
            [view animatedAddCrossButton];
        }
    }
    else{
        for (CCUIContentModuleContainerView* view in self.view.subviews){
            [view removeShakeAnimation];
            [view animatedRemoveCrossButton];
        }
    }
    self.enabled = !self.enabled;
}

- (void)viewWillAppear:(_Bool)arg1{
    if (arg1){
        moduleViewController = self;
        //RLog(@"%@",[self _moduleInstances][0]);
        //RLog(@"%@",self.view.subviews);
        //for (CCUIContentModuleContainerView* x in self.view.subviews){
            //RLog(@"%@",x.subviews);
        //    [x addShakeAnimation]; 
        //    [x animatedAddCrossButton];
        //}
    }
    %orig;
}

- (void)viewWillDisappear:(_Bool)arg1{
    if (arg1){
        for (id x in self.view.subviews){
            [x animatedRemoveCrossButton];
            [x removeShakeAnimation];
        }
        self.enabled = NO;
    }
    %orig;
}

%end


%hook CCUIStatusBar

%new
-(void)heldForALongTime:(UILongPressGestureRecognizer *)Gesture{
    if (Gesture.state == UIGestureRecognizerStateBegan) {
        UIImpactFeedbackGenerator *feedbackGenerator = [UIImpactFeedbackGenerator alloc];
        feedbackGenerator = [feedbackGenerator initWithStyle:UIImpactFeedbackStyleMedium];
        [feedbackGenerator performSelector:@selector(impactOccurred) withObject:nil afterDelay:0.0f];
        [moduleViewController toggleWiggleMode];
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = (CCUIStatusBar *)%orig;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(heldForALongTime:)];
    longPress.minimumPressDuration = 0.6;
    [self addGestureRecognizer:longPress];
    return self;
}
%end


