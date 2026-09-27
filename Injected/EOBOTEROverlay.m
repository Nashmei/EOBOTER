#import <UIKit/UIKit.h>

@interface EOPassThroughWindow : UIWindow
@property(nonatomic,weak) UIView *interactiveRoot;
@end
@implementation EOPassThroughWindow
- (UIView *)hitTest:(CGPoint)p withEvent:(UIEvent *)e {
    UIView *h=[super hitTest:p withEvent:e];
    if(!h||h==self||h==self.rootViewController.view)return nil;
    return (self.interactiveRoot&&[h isDescendantOfView:self.interactiveRoot])?h:nil;
}
@end

@interface EOBOTEROverlay : NSObject
@property(nonatomic,strong) EOPassThroughWindow *overlayWindow;
@property(nonatomic,strong) UIButton *bubble;
@property(nonatomic,strong) UIView *panel;
@property(nonatomic,strong) UITextView *logView;
@property(nonatomic,strong) UILabel *marketLabel;
@property(nonatomic,strong) UILabel *statusLabel;
@property(nonatomic,strong) NSArray<NSDictionary*> *lastCandidates;
@end

@implementation EOBOTEROverlay
+ (instancetype)shared{static id x;static dispatch_once_t o;dispatch_once(&o,^{x=[self new];});return x;}
- (void)log:(NSString*)s{
    if(!s.length)return;NSLog(@"[EOBOTER] %@",s);if(!self.logView)return;
    NSString*n=self.logView.text.length?[self.logView.text stringByAppendingFormat:@"\n%@",s]:s;
    NSArray*r=[n componentsSeparatedByString:@"\n"];if(r.count>100)n=[[r subarrayWithRange:NSMakeRange(r.count-100,100)]componentsJoinedByString:@"\n"];
    self.logView.text=n;[self.logView scrollRangeToVisible:NSMakeRange(n.length,0)];
}
- (void)install{
    dispatch_async(dispatch_get_main_queue(),^{if(self.overlayWindow)return;CGRect s=UIScreen.mainScreen.bounds;
        self.overlayWindow=[[EOPassThroughWindow alloc]initWithFrame:s];self.overlayWindow.windowLevel=UIWindowLevelAlert+100;self.overlayWindow.backgroundColor=UIColor.clearColor;
        UIViewController*vc=[UIViewController new];vc.view.backgroundColor=UIColor.clearColor;self.overlayWindow.rootViewController=vc;self.overlayWindow.hidden=NO;
        UIButton*b=[UIButton buttonWithType:UIButtonTypeSystem];b.frame=CGRectMake(s.size.width-72,150,56,56);b.layer.cornerRadius=28;b.backgroundColor=[UIColor colorWithWhite:.08 alpha:.94];
        [b setTitle:@"EO" forState:UIControlStateNormal];[b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];b.titleLabel.font=[UIFont boldSystemFontOfSize:16];
        [b addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];[b addGestureRecognizer:[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(drag:)]];
        [vc.view addSubview:b];self.bubble=b;self.overlayWindow.interactiveRoot=b;
    });
}
- (void)drag:(UIPanGestureRecognizer*)g{CGPoint d=[g translationInView:g.view.superview],c=g.view.center;c.x+=d.x;c.y+=d.y;CGRect s=UIScreen.mainScreen.bounds;c.x=MAX(28,MIN(s.size.width-28,c.x));c.y=MAX(50,MIN(s.size.height-50,c.y));g.view.center=c;[g setTranslation:CGPointZero inView:g.view.superview];}
- (UIButton*)btn:(NSString*)t x:(CGFloat)x y:(CGFloat)y w:(CGFloat)w action:(SEL)a{UIButton*b=[UIButton buttonWithType:UIButtonTypeSystem];b.frame=CGRectMake(x,y,w,44);b.layer.cornerRadius=10;b.backgroundColor=[UIColor colorWithWhite:.16 alpha:1];[b setTitle:t forState:UIControlStateNormal];[b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];b.titleLabel.font=[UIFont boldSystemFontOfSize:12];[b addTarget:self action:a forControlEvents:UIControlEventTouchUpInside];return b;}
- (void)togglePanel{
    if(self.panel){[self.panel removeFromSuperview];self.panel=nil;self.logView=nil;self.overlayWindow.interactiveRoot=self.bubble;return;}
    CGRect s=UIScreen.mainScreen.bounds;CGFloat w=s.size.width-20,h=MIN(650,s.size.height-80);UIView*p=[[UIView alloc]initWithFrame:CGRectMake(10,55,w,h)];p.backgroundColor=[UIColor colorWithWhite:.045 alpha:.98];p.layer.cornerRadius=20;
    UILabel*t=[[UILabel alloc]initWithFrame:CGRectMake(16,12,w-80,32)];t.text=@"EOBOTER • SAFE RN LAB";t.textColor=UIColor.whiteColor;t.font=[UIFont boldSystemFontOfSize:20];[p addSubview:t];[p addSubview:[self btn:@"×" x:w-56 y:7 w:44 action:@selector(togglePanel)]];
    self.statusLabel=[[UILabel alloc]initWithFrame:CGRectMake(16,48,w-32,34)];self.statusLabel.text=@"Safe UIView scan • no React KVC";self.statusLabel.textColor=UIColor.lightGrayColor;self.statusLabel.font=[UIFont systemFontOfSize:11];[p addSubview:self.statusLabel];
    self.marketLabel=[[UILabel alloc]initWithFrame:CGRectMake(16,82,w-32,76)];self.marketLabel.numberOfLines=4;self.marketLabel.text=@"Asset: —\nRN/Fabric: not scanned\nBUY/SELL: unknown";self.marketLabel.textColor=UIColor.whiteColor;self.marketLabel.font=[UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];[p addSubview:self.marketLabel];
    CGFloat bw=(w-44)/3;[p addSubview:[self btn:@"SAFE SCAN" x:12 y:166 w:bw action:@selector(scanSafe)]];[p addSubview:[self btn:@"TEST BUY" x:22+bw y:166 w:bw action:@selector(testBuy)]];[p addSubview:[self btn:@"TEST SELL" x:32+2*bw y:166 w:bw action:@selector(testSell)]];
    self.logView=[[UITextView alloc]initWithFrame:CGRectMake(12,220,w-24,h-232)];self.logView.editable=NO;self.logView.selectable=YES;self.logView.backgroundColor=[UIColor colorWithWhite:.09 alpha:1];self.logView.textColor=UIColor.whiteColor;self.logView.font=[UIFont monospacedSystemFontOfSize:10 weight:UIFontWeightRegular];self.logView.layer.cornerRadius=11;[p addSubview:self.logView];
    [self.overlayWindow.rootViewController.view addSubview:p];self.panel=p;self.overlayWindow.interactiveRoot=p;[self log:@"SAFE RN LAB ready — KVC disabled"];
}
- (UIWindow*)hostWindow{for(UIScene*sc in UIApplication.sharedApplication.connectedScenes)if(sc.activationState==UISceneActivationStateForegroundActive&&[sc isKindOfClass:UIWindowScene.class])for(UIWindow*w in ((UIWindowScene*)sc).windows)if(w!=self.overlayWindow&&!w.hidden&&w.alpha>.01&&w.windowLevel==UIWindowLevelNormal)return w;return nil;}
- (NSString*)viewText:(UIView*)v{
    NSMutableArray*a=[NSMutableArray array];
    if([v isKindOfClass:UILabel.class]){NSString*x=((UILabel*)v).text;if(x.length)[a addObject:x];}
    if([v isKindOfClass:UIButton.class]){NSString*x=[((UIButton*)v)titleForState:UIControlStateNormal];if(x.length)[a addObject:x];}
    NSString*l=v.accessibilityLabel,*val=v.accessibilityValue,*ident=v.accessibilityIdentifier;if(l.length)[a addObject:l];if(val.length)[a addObject:val];if(ident.length)[a addObject:ident];
    return [[[a componentsJoinedByString:@" | "]uppercaseString]stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}
- (BOOL)isRNClass:(NSString*)c{return [c containsString:@"RCT"]||[c containsString:@"RN"]||[c containsString:@"Fabric"]||[c containsString:@"ExpertOption"]||[c containsString:@"Plot"];}
- (void)walk:(UIView*)v out:(NSMutableArray*)out depth:(NSInteger)d{
    if(!v||d>24||v.hidden||v.alpha<.02||out.count>=1500)return;
    CGRect r=[v convertRect:v.bounds toView:nil],screen=UIScreen.mainScreen.bounds;if(CGRectIsEmpty(r)||r.size.width<4||r.size.height<4||!CGRectIntersectsRect(r,screen))return;
    NSString*c=NSStringFromClass(v.class)?:@"",*tx=[self viewText:v];BOOL rn=[self isRNClass:c];BOOL act=[v isKindOfClass:UIControl.class]||v.gestureRecognizers.count>0||v.isAccessibilityElement;
    if(tx.length||rn||act)[out addObject:@{@"view":v,@"class":c,@"text":tx?:@"",@"rn":@(rn),@"act":@(act),@"x":@(r.origin.x),@"y":@(r.origin.y),@"w":@(r.size.width),@"h":@(r.size.height)}];
    NSArray*subs=[v.subviews copy];for(UIView*s in subs)[self walk:s out:out depth:d+1];
}
- (BOOL)has:(NSString*)s words:(NSArray*)ws{for(NSString*w in ws)if([s containsString:[w uppercaseString]])return YES;return NO;}
- (void)scanSafe{
    UIWindow*w=[self hostWindow];if(!w){[self log:@"SCAN blocked: host window not found"];return;}
    NSMutableArray*a=[NSMutableArray array];[self walk:w out:a depth:0];self.lastCandidates=a;
    NSArray*bw=@[@"شراء",@"BUY",@"CALL",@"ATBUYBUTTON"],*sw=@[@"بيع",@"SELL",@"PUT"],*aw=@[@"OTC",@"EUR /",@"EUR/",@"USD /",@"USD/",@"GBP /",@"GBP/"];
    NSUInteger rn=0,bu=0,se=0;NSString*asset=@"—";
    for(NSDictionary*d in a){NSString*t=d[@"text"],*c=d[@"class"];if([d[@"rn"]boolValue])rn++;if([self has:t words:bw])bu++;if([self has:t words:sw])se++;if(asset.length==1&&[self has:t words:aw])asset=t;if([c containsString:@"ExpertOption"]||[c containsString:@"MobilePlot"])[self log:[NSString stringWithFormat:@"EO class: %@ %.0f,%.0f %.0fx%.0f",c,[d[@"x"]doubleValue],[d[@"y"]doubleValue],[d[@"w"]doubleValue],[d[@"h"]doubleValue]]];}
    self.marketLabel.text=[NSString stringWithFormat:@"Asset: %@\nRN/Fabric views: %lu\nBUY candidates: %lu • SELL: %lu",asset,(unsigned long)rn,(unsigned long)bu,(unsigned long)se];
    [self log:[NSString stringWithFormat:@"SAFE SCAN total=%lu rn=%lu buy=%lu sell=%lu",(unsigned long)a.count,(unsigned long)rn,(unsigned long)bu,(unsigned long)se]];
    NSInteger n=0;for(NSDictionary*d in a){if(n>=24)break;if([d[@"rn"]boolValue]||[self has:d[@"text"] words:@[@"شراء",@"بيع",@"BUY",@"SELL",@"OTC"]]){[self log:[NSString stringWithFormat:@"[%@] act=%@ %.0f,%.0f %.0fx%.0f | %@",d[@"class"],[d[@"act"]boolValue]?@"Y":@"N",[d[@"x"]doubleValue],[d[@"y"]doubleValue],[d[@"w"]doubleValue],[d[@"h"]doubleValue],d[@"text"]]];n++;}}
}
- (NSArray*)matches:(BOOL)buy{NSArray*ws=buy?@[@"شراء",@"BUY",@"CALL",@"ATBUYBUTTON"]:@[@"بيع",@"SELL",@"PUT"];NSMutableArray*m=[NSMutableArray array];for(NSDictionary*d in self.lastCandidates?:@[])if([d[@"act"]boolValue]&&[self has:d[@"text"] words:ws])[m addObject:d];return m;}
- (void)test:(BOOL)buy{[self scanSafe];NSArray*m=[self matches:buy];NSString*n=buy?@"BUY":@"SELL";if(m.count!=1){self.statusLabel.text=[NSString stringWithFormat:@"%@ blocked: %lu safe targets",n,(unsigned long)m.count];[self log:self.statusLabel.text];return;}UIView*v=m.firstObject[@"view"];if([v isKindOfClass:UIControl.class]){[(UIControl*)v sendActionsForControlEvents:UIControlEventTouchUpInside];self.statusLabel.text=[NSString stringWithFormat:@"%@ UIControl dispatched",n];[self log:self.statusLabel.text];}else{self.statusLabel.text=[NSString stringWithFormat:@"%@ target found (%@), dispatcher not mapped",n,NSStringFromClass(v.class)];[self log:self.statusLabel.text];}}
- (void)testBuy{[self test:YES];}- (void)testSell{[self test:NO];}
@end
__attribute__((constructor))static void EOBOTERInitialize(void){dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(1*NSEC_PER_SEC)),dispatch_get_main_queue(),^{[[EOBOTEROverlay shared]install];});}
