@interface SBXCloseBoxView : UIButton
@end

@interface CCUIStatusBar:UIView
-(void)heldForALongTime:(UILongPressGestureRecognizer *)Gesture;
@end

@interface CCUIModuleCollectionViewController : UIViewController
@property(nonatomic, assign) BOOL enabled;

- (void)orderedEnabledModuleIdentifiersChangedForSettingsManager:(id)arg1;
-(void)toggleWiggleMode;
- (id)_activePositionProvider;
@end

@interface CCUIContentModuleContainerView: UIView
@property(readonly, copy, nonatomic) NSString *moduleIdentifier;
-(void)addShakeAnimation;
-(void)disableGestureRecognisers;
-(void)enableGestureRecognisers;
-(void)removeCrossButton;
-(void)removeShakeAnimation;
-(void)animatedAddCrossButton;
-(void)animatedRemoveCrossButton;
@end

