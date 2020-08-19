#import <RemoteLog.h>
#import "ccUIClasses.h"
//#import <ControlCenterUI/CCUIContentModuleContainerView.h>
//#import <ControlCenterUI/CCUIModuleCollectionViewController.h>
//#import <SpringBoardHome/SBCloseBoxView.h>

//#import <SpringBoardHome/SBXCloseBoxView.h>


CCUIModuleCollectionViewController* moduleViewController= nil;

float excc = 0;
%hook CCUIContentModuleContainerView

%new
-(void)disableGestureRecognisers{
    for (UIGestureRecognizer* recogniser in self.subviews[0].subviews[0].subviews[0].gestureRecognizers){
        recogniser.enabled=NO;
    }
}

%new
-(void)enableGestureRecognisers{
    for (UIGestureRecognizer* recogniser in self.subviews[0].subviews[0].subviews[0].gestureRecognizers){
        recogniser.enabled=YES;
    }
}

%new
-(void)addShakeAnimation{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    //  this is some trig to make the shaking look better on big modules, 
    //  it basically means you define distance not angles
    float distanceToWobble = 0.03f;
    float distanceToCorner = sqrt(pow(self.bounds.size.height/2,2) + pow(self.bounds.size.width/2,2));
    
    //  this uses cosine rule, it assumes the curved part of the circle is flat for ease of use.
    //CGFloat wobbleAngle = 0.04f;
    CGFloat wobbleAngle = acos(((2*pow(distanceToCorner, 2))-(pow(distanceToWobble, 2)))/(2*distanceToCorner*distanceToCorner)) * (180 / M_PI);
    NSValue* valLeft = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(wobbleAngle, 0.0f, 0.0f, 1.0f)];
    NSValue* valRight = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-wobbleAngle, 0.0f, 0.0f, 1.0f)];
    animation.values = [NSArray arrayWithObjects:valLeft, valRight, nil];
    excc += 0.005;
    animation.beginTime = CACurrentMediaTime() + excc;
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
            [view disableGestureRecognisers];
        }
    }
    else{
        for (CCUIContentModuleContainerView* view in self.view.subviews){
            [view removeShakeAnimation];
            [view animatedRemoveCrossButton];
            [view enableGestureRecognisers];
        }
    }
    self.enabled = !self.enabled;
}

- (void)viewWillAppear:(_Bool)arg1{
    if (arg1){
        moduleViewController = self;
        //RLog(@"%@",[self _moduleInstances][0]);
        //RLog(@"%@",self.view.subviews);
        for (CCUIContentModuleContainerView* x in self.view.subviews){
            //RLog(@"%@",x.subviews);
            [x removeShakeAnimation]; 
            [x removeCrossButton];
            [x enableGestureRecognisers];
        }
        self.enabled = NO;
    }
    %orig;
}

- (void)viewWillDisappear:(_Bool)arg1{
    if (arg1){
        for (id x in self.view.subviews){
            [x animatedRemoveCrossButton];
            [x removeShakeAnimation];
            [x enableGestureRecognisers];
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
        RLog(@"%@",[moduleViewController _activePositionProvider]);
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


