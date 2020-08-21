#import "ManagerHook.h"
#import "ccUIClasses.h"
CCUIModuleCollectionViewController* moduleViewController = nil;

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
        //CCUILayoutOptions* manager = MSHookIvar<id>(self, "_layoutOptions");
        //[manager _loadSettings];
        //RLog(@"%@",manager);
        //[self orderedEnabledModuleIdentifiersChangedForSettingsManager:manager];
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
