#import <UIKit/UIKit.h>

@interface EOBOTEROverlay : NSObject
@property(nonatomic,strong) UIWindow *overlayWindow;
@property(nonatomic,strong) UIButton *bubble;
@property(nonatomic,strong) UIView *panel;
@end

@implementation EOBOTEROverlay
+ (instancetype)shared {
    static EOBOTEROverlay *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [EOBOTEROverlay new]; });
    return instance;
}

- (void)install {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.overlayWindow) return;

        CGRect screen = UIScreen.mainScreen.bounds;
        self.overlayWindow = [[UIWindow alloc] initWithFrame:screen];
        self.overlayWindow.windowLevel = UIWindowLevelAlert + 100;
        self.overlayWindow.backgroundColor = UIColor.clearColor;
        self.overlayWindow.userInteractionEnabled = YES;

        UIViewController *root = [UIViewController new];
        root.view.backgroundColor = UIColor.clearColor;
        self.overlayWindow.rootViewController = root;
        self.overlayWindow.hidden = NO;

        UIButton *bubble = [UIButton buttonWithType:UIButtonTypeSystem];
        bubble.frame = CGRectMake(screen.size.width - 72, 150, 56, 56);
        bubble.layer.cornerRadius = 28;
        bubble.backgroundColor = [UIColor colorWithWhite:0.08 alpha:0.94];
        [bubble setTitle:@"EO" forState:UIControlStateNormal];
        [bubble setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        bubble.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [bubble addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragBubble:)];
        [bubble addGestureRecognizer:pan];
        [root.view addSubview:bubble];
        self.bubble = bubble;
    });
}

- (void)dragBubble:(UIPanGestureRecognizer *)gesture {
    CGPoint delta = [gesture translationInView:gesture.view.superview];
    gesture.view.center = CGPointMake(gesture.view.center.x + delta.x, gesture.view.center.y + delta.y);
    [gesture setTranslation:CGPointZero inView:gesture.view.superview];
}

- (void)togglePanel {
    if (self.panel) {
        [self.panel removeFromSuperview];
        self.panel = nil;
        return;
    }

    CGFloat width = UIScreen.mainScreen.bounds.size.width - 40;
    UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(20, 110, width, 330)];
    panel.backgroundColor = [UIColor colorWithWhite:0.07 alpha:0.97];
    panel.layer.cornerRadius = 22;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(22, 18, width - 44, 34)];
    title.text = @"EOBOTER";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont boldSystemFontOfSize:25];
    [panel addSubview:title];

    UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(22, 65, width - 44, 55)];
    status.text = @"Overlay active\nEngine ready";
    status.numberOfLines = 2;
    status.textColor = [UIColor colorWithWhite:0.82 alpha:1.0];
    [panel addSubview:status];

    UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(22, 140, 60, 34)];
    toggle.on = NO;
    [panel addSubview:toggle];

    UILabel *engine = [[UILabel alloc] initWithFrame:CGRectMake(90, 140, width - 112, 34)];
    engine.text = @"Bot engine";
    engine.textColor = UIColor.whiteColor;
    [panel addSubview:engine];

    UITextView *log = [[UITextView alloc] initWithFrame:CGRectMake(18, 195, width - 36, 105)];
    log.editable = NO;
    log.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1.0];
    log.textColor = UIColor.whiteColor;
    log.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    log.text = @"[EOBOTER] dylib loaded\n[EOBOTER] overlay installed";
    log.layer.cornerRadius = 12;
    [panel addSubview:log];

    [self.overlayWindow.rootViewController.view addSubview:panel];
    self.panel = panel;
}
@end

__attribute__((constructor))
static void EOBOTERInitialize(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [[EOBOTEROverlay shared] install];
    });
}
