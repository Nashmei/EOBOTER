#import <UIKit/UIKit.h>

@interface EOPassThroughWindow : UIWindow
@property(nonatomic,weak) UIView *interactiveRoot;
@end

@implementation EOPassThroughWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    if (!hit) return nil;
    if (hit == self || hit == self.rootViewController.view) return nil;
    if (self.interactiveRoot && [hit isDescendantOfView:self.interactiveRoot]) return hit;
    return nil;
}
@end

@interface EOBOTEROverlay : NSObject
@property(nonatomic,strong) EOPassThroughWindow *overlayWindow;
@property(nonatomic,strong) UIButton *bubble;
@property(nonatomic,strong) UIView *panel;
@property(nonatomic,strong) UITextView *logView;
@property(nonatomic,strong) UILabel *marketLabel;
@property(nonatomic,strong) UILabel *statusLabel;
@property(nonatomic,strong) UISwitch *engineSwitch;
@property(nonatomic,strong) NSArray<NSDictionary *> *lastCandidates;
@end

@implementation EOBOTEROverlay

+ (instancetype)shared {
    static EOBOTEROverlay *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [EOBOTEROverlay new]; });
    return instance;
}

- (void)appendLog:(NSString *)line {
    if (!line.length) return;
    NSLog(@"[EOBOTER] %@", line);
    if (!self.logView) return;
    NSString *old = self.logView.text ?: @"";
    NSString *next = old.length ? [old stringByAppendingFormat:@"\n%@", line] : line;
    NSArray *rows = [next componentsSeparatedByString:@"\n"];
    if (rows.count > 80) {
        next = [[rows subarrayWithRange:NSMakeRange(rows.count-80, 80)] componentsJoinedByString:@"\n"];
    }
    self.logView.text = next;
    NSRange bottom = NSMakeRange(self.logView.text.length, 0);
    [self.logView scrollRangeToVisible:bottom];
}

- (void)install {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.overlayWindow) return;
        CGRect screen = UIScreen.mainScreen.bounds;

        self.overlayWindow = [[EOPassThroughWindow alloc] initWithFrame:screen];
        self.overlayWindow.windowLevel = UIWindowLevelAlert + 100;
        self.overlayWindow.backgroundColor = UIColor.clearColor;

        UIViewController *root = [UIViewController new];
        root.view.backgroundColor = UIColor.clearColor;
        self.overlayWindow.rootViewController = root;
        self.overlayWindow.hidden = NO;

        UIButton *bubble = [UIButton buttonWithType:UIButtonTypeSystem];
        bubble.frame = CGRectMake(screen.size.width-72, 150, 56, 56);
        bubble.layer.cornerRadius = 28;
        bubble.backgroundColor = [UIColor colorWithWhite:0.08 alpha:0.94];
        [bubble setTitle:@"EO" forState:UIControlStateNormal];
        [bubble setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        bubble.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [bubble addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
        [root.view addSubview:bubble];
        self.bubble = bubble;
        self.overlayWindow.interactiveRoot = bubble;

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragBubble:)];
        [bubble addGestureRecognizer:pan];
        [self appendLog:@"dylib loaded; pass-through enabled"];
    });
}

- (void)dragBubble:(UIPanGestureRecognizer *)g {
    CGPoint d = [g translationInView:g.view.superview];
    CGPoint c = CGPointMake(g.view.center.x+d.x, g.view.center.y+d.y);
    CGFloat r = g.view.bounds.size.width/2.0;
    CGRect b = UIScreen.mainScreen.bounds;
    c.x = MAX(r, MIN(b.size.width-r, c.x));
    c.y = MAX(r+20, MIN(b.size.height-r-20, c.y));
    g.view.center = c;
    [g setTranslation:CGPointZero inView:g.view.superview];
}

- (UIButton *)button:(NSString *)title frame:(CGRect)frame action:(SEL)action {
    UIButton *b=[UIButton buttonWithType:UIButtonTypeSystem];
    b.frame=frame; b.layer.cornerRadius=10;
    b.backgroundColor=[UIColor colorWithWhite:0.16 alpha:1];
    [b setTitle:title forState:UIControlStateNormal];
    [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    b.titleLabel.font=[UIFont boldSystemFontOfSize:13];
    [b addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return b;
}

- (void)togglePanel {
    if (self.panel) {
        [self.panel removeFromSuperview]; self.panel=nil; self.logView=nil;
        self.overlayWindow.interactiveRoot=self.bubble;
        return;
    }

    CGRect s=UIScreen.mainScreen.bounds;
    CGFloat w=s.size.width-24, h=560;
    UIView *p=[[UIView alloc] initWithFrame:CGRectMake(12, 80, w, MIN(h,s.size.height-110))];
    p.backgroundColor=[UIColor colorWithWhite:0.055 alpha:0.97];
    p.layer.cornerRadius=22;
    p.layer.borderWidth=0.5;
    p.layer.borderColor=[UIColor colorWithWhite:0.35 alpha:1].CGColor;

    UILabel *title=[[UILabel alloc] initWithFrame:CGRectMake(18,14,w-100,34)];
    title.text=@"EOBOTER LAB"; title.textColor=UIColor.whiteColor;
    title.font=[UIFont boldSystemFontOfSize:24]; [p addSubview:title];

    UIButton *close=[self button:@"×" frame:CGRectMake(w-58,10,44,40) action:@selector(togglePanel)];
    [p addSubview:close];

    self.statusLabel=[[UILabel alloc] initWithFrame:CGRectMake(18,52,w-36,42)];
    self.statusLabel.text=@"UI execution test • Demo recommended";
    self.statusLabel.textColor=[UIColor colorWithWhite:0.75 alpha:1];
    self.statusLabel.font=[UIFont systemFontOfSize:13]; [p addSubview:self.statusLabel];

    self.marketLabel=[[UILabel alloc] initWithFrame:CGRectMake(18,94,w-36,60)];
    self.marketLabel.text=@"Market: not scanned\nControls: unknown";
    self.marketLabel.numberOfLines=3; self.marketLabel.textColor=UIColor.whiteColor;
    self.marketLabel.font=[UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightRegular];
    [p addSubview:self.marketLabel];

    UIButton *scan=[self button:@"SCAN UI" frame:CGRectMake(18,164,(w-48)/2,44) action:@selector(scanUI)];
    UIButton *refresh=[self button:@"REFRESH" frame:CGRectMake(30+(w-48)/2,164,(w-48)/2,44) action:@selector(scanUI)];
    [p addSubview:scan]; [p addSubview:refresh];

    UIButton *up=[self button:@"TEST UP" frame:CGRectMake(18,218,(w-48)/2,48) action:@selector(testUp)];
    UIButton *down=[self button:@"TEST DOWN" frame:CGRectMake(30+(w-48)/2,218,(w-48)/2,48) action:@selector(testDown)];
    [p addSubview:up]; [p addSubview:down];

    UILabel *engineLabel=[[UILabel alloc] initWithFrame:CGRectMake(18,278,w-90,34)];
    engineLabel.text=@"Bot engine (execution locked)"; engineLabel.textColor=UIColor.whiteColor;
    engineLabel.font=[UIFont systemFontOfSize:15]; [p addSubview:engineLabel];
    self.engineSwitch=[[UISwitch alloc] initWithFrame:CGRectMake(w-70,278,52,34)];
    self.engineSwitch.enabled=NO; [p addSubview:self.engineSwitch];

    self.logView=[[UITextView alloc] initWithFrame:CGRectMake(14,326,w-28,p.bounds.size.height-340)];
    self.logView.editable=NO; self.logView.selectable=YES;
    self.logView.backgroundColor=[UIColor colorWithWhite:0.10 alpha:1];
    self.logView.textColor=UIColor.whiteColor;
    self.logView.font=[UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    self.logView.layer.cornerRadius=12;
    [p addSubview:self.logView];

    [self.overlayWindow.rootViewController.view addSubview:p];
    self.panel=p; self.overlayWindow.interactiveRoot=p;
    [self appendLog:@"panel opened"];
}

- (UIWindow *)hostWindow {
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (scene.activationState != UISceneActivationStateForegroundActive || ![scene isKindOfClass:UIWindowScene.class]) continue;
        for (UIWindow *w in ((UIWindowScene *)scene).windows) {
            if (w != self.overlayWindow && !w.hidden && w.alpha > 0 && w.windowLevel == UIWindowLevelNormal) return w;
        }
    }
    return nil;
}

- (NSString *)textForView:(UIView *)v {
    NSString *t=nil;
    if ([v isKindOfClass:UILabel.class]) t=((UILabel *)v).text;
    else if ([v isKindOfClass:UIButton.class]) t=[((UIButton *)v) titleForState:UIControlStateNormal];
    else if ([v isKindOfClass:UITextField.class]) t=((UITextField *)v).text;
    if (!t.length && v.accessibilityLabel.length) t=v.accessibilityLabel;
    return [[t ?: @"" stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] uppercaseString];
}

- (void)collect:(UIView *)v into:(NSMutableArray *)out depth:(NSInteger)depth {
    if (!v || depth>18 || v.hidden || v.alpha<0.05) return;
    CGRect r=[v convertRect:v.bounds toView:nil];
    if (CGRectIsEmpty(r) || r.size.width<20 || r.size.height<16) return;
    NSString *txt=[self textForView:v];
    BOOL actionable=[v isKindOfClass:UIControl.class] || v.userInteractionEnabled || v.gestureRecognizers.count>0;
    if (txt.length || actionable) {
        [out addObject:@{@"view":v, @"text":txt ?: @"", @"class":NSStringFromClass(v.class),
                         @"x":@(r.origin.x),@"y":@(r.origin.y),@"w":@(r.size.width),@"h":@(r.size.height),
                         @"actionable":@(actionable)}];
    }
    for (UIView *s in v.subviews) [self collect:s into:out depth:depth+1];
}

- (void)scanUI {
    UIWindow *host=[self hostWindow];
    if (!host) { [self appendLog:@"SCAN failed: EO host window not found"]; return; }
    NSMutableArray *items=[NSMutableArray array];
    [self collect:host into:items depth:0];
    self.lastCandidates=items;

    NSMutableArray *trade=[NSMutableArray array];
    NSMutableArray *market=[NSMutableArray array];
    NSArray *upWords=@[@"شراء",@"BUY",@"UP",@"CALL"];
    NSArray *downWords=@[@"بيع",@"SELL",@"DOWN",@"PUT"];

    for (NSDictionary *d in items) {
        NSString *t=d[@"text"];
        BOOL isTrade=NO;
        for (NSString *w in upWords) if ([t containsString:[w uppercaseString]]) isTrade=YES;
        for (NSString *w in downWords) if ([t containsString:[w uppercaseString]]) isTrade=YES;
        if (isTrade) [trade addObject:d];
        if ([t containsString:@"/"] || [t containsString:@"OTC"] || [t containsString:@"USD"] ||
            [t containsString:@"EUR"] || [t containsString:@"SAR"]) [market addObject:d];
    }

    NSString *m=market.count ? market.firstObject[@"text"] : @"not identified";
    self.marketLabel.text=[NSString stringWithFormat:@"Market: %@\nViews: %lu • trade candidates: %lu",
                           m,(unsigned long)items.count,(unsigned long)trade.count];
    [self appendLog:[NSString stringWithFormat:@"SCAN: %lu views, %lu trade candidates",
                     (unsigned long)items.count,(unsigned long)trade.count]];
    NSInteger shown=0;
    for (NSDictionary *d in trade) {
        if (shown++>=8) break;
        [self appendLog:[NSString stringWithFormat:@"candidate: %@ | %@ | %.0fx%.0f @ %.0f,%.0f",
                         d[@"text"],d[@"class"],[d[@"w"] doubleValue],[d[@"h"] doubleValue],
                         [d[@"x"] doubleValue],[d[@"y"] doubleValue]]];
    }
}

- (NSArray *)matchesForDirection:(NSString *)direction {
    if (!self.lastCandidates.count) [self scanUI];
    NSArray *words=[direction isEqualToString:@"UP"] ? @[@"شراء",@"BUY",@"UP",@"CALL"] : @[@"بيع",@"SELL",@"DOWN",@"PUT"];
    NSMutableArray *matches=[NSMutableArray array];
    for (NSDictionary *d in self.lastCandidates ?: @[]) {
        if (![d[@"actionable"] boolValue]) continue;
        NSString *t=d[@"text"];
        for (NSString *w in words) {
            if ([t containsString:[w uppercaseString]]) { [matches addObject:d]; break; }
        }
    }
    return matches;
}

- (void)testDirection:(NSString *)direction {
    [self scanUI];
    NSArray *m=[self matchesForDirection:direction];
    if (m.count != 1) {
        [self appendLog:[NSString stringWithFormat:@"TEST %@ blocked: expected 1 actionable match, got %lu",
                         direction,(unsigned long)m.count]];
        self.statusLabel.text=@"Execution blocked — inspect candidates";
        return;
    }
    UIView *v=m.firstObject[@"view"];
    if ([v isKindOfClass:UIControl.class]) {
        [(UIControl *)v sendActionsForControlEvents:UIControlEventTouchUpInside];
        [self appendLog:[NSString stringWithFormat:@"TEST %@ dispatched via UIControl",direction]];
        self.statusLabel.text=[NSString stringWithFormat:@"TEST %@ dispatched",direction];
    } else {
        UITapGestureRecognizer *tap=nil;
        for (UIGestureRecognizer *g in v.gestureRecognizers) if ([g isKindOfClass:UITapGestureRecognizer.class]) { tap=(id)g; break; }
        if (!tap) {
            [self appendLog:[NSString stringWithFormat:@"TEST %@ blocked: matched view has no safe UIControl action",direction]];
            self.statusLabel.text=@"Execution blocked — unsupported target";
            return;
        }
        [self appendLog:[NSString stringWithFormat:@"TEST %@ identified gesture-backed view; no synthetic private invocation used",direction]];
        self.statusLabel.text=@"Target identified; needs supported action mapping";
    }
}

- (void)testUp { [self testDirection:@"UP"]; }
- (void)testDown { [self testDirection:@"DOWN"]; }

@end

__attribute__((constructor))
static void EOBOTERInitialize(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(1.0*NSEC_PER_SEC)),dispatch_get_main_queue(),^{
        [[EOBOTEROverlay shared] install];
    });
}
