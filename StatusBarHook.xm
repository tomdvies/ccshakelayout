
#import "ccUIClasses.h"
#import "ManagerHook.h"

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


