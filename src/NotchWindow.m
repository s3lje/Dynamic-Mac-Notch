#import "NotchWindow.h"

#define NOTCH_WIDTH_CLOSED  200
#define NOTCH_WIDTH_OPEN    350
#define NOTCH_HEIGHT_CLOSED 32.0
#define NOTCH_HEIGHT_OPEN   120
#define CORNER_RADIUS       18.0
#define ANIMATION_DURATION  0.25

// NotchView interface and implementation
@interface NotchView : NSView
@end

@implementation NotchView


- (void)drawRect:(NSRect)dirtyRect{
    NSRect bounds = self.bounds;
    NSBezierPath* path = [NSBezierPath bezierPath];

    [path moveToPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds))];
    [path lineToPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds))];
    [path lineToPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds) + CORNER_RADIUS)]; 

    [path appendBezierPathWithArcFromPoint:
        NSMakePoint(NSMaxX(bounds), NSMinY(bounds))
        toPoint:NSMakePoint(NSMaxX(bounds) - CORNER_RADIUS, NSMinY(bounds))
        radius:CORNER_RADIUS];

    [path lineToPoint:NSMakePoint(NSMinX(bounds) + CORNER_RADIUS, NSMinY(bounds))];

    [path appendBezierPathWithArcFromPoint:
        NSMakePoint(NSMinX(bounds), NSMinY(bounds))
        toPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds) + CORNER_RADIUS)
        radius:CORNER_RADIUS]; 

    [path lineToPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds))];

    [path closePath];
    [[NSColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.97] setFill];
    [path fill]; 
}

@end


@interface NotchWindow()

@property (strong) NSWindow* window;
@property (strong) NSTimer*  collapseTimer;
@property BOOL isExpanded;
@property BOOL isAnimating; 

@end


@implementation NotchWindow

- (void)expand {
    if (self.isExpanded || self.isAnimating) return;
    self.isAnimating = YES;

    NSRect sf = [NSScreen mainScreen].frame;
    CGFloat x = (sf.size.width - NOTCH_WIDTH_OPEN) / 2.0;
    CGFloat y = sf.size.height - NOTCH_HEIGHT_OPEN;
    NSRect target = NSMakeRect(x, y, NOTCH_WIDTH_OPEN, NOTCH_HEIGHT_OPEN);

    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *ctx) {
        ctx.duration = ANIMATION_DURATION;
        ctx.timingFunction = [CAMediaTimingFunction
            functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [[self.window animator] setFrame:target display:YES];
    } completionHandler:^{
        self.isExpanded = YES;
        self.isAnimating = NO;
    }];
}

- (void)collapse {
    if (self.isAnimating || !self.isExpanded) return;
    self.isAnimating = YES;
    
    self.collapseTimer = nil;
    NSRect sf = [NSScreen mainScreen].frame;
    CGFloat x = (sf.size.width - NOTCH_WIDTH_CLOSED) / 2.0;
    CGFloat y = sf.size.height - NOTCH_HEIGHT_CLOSED;
    NSRect target = NSMakeRect(x, y, NOTCH_WIDTH_CLOSED, NOTCH_HEIGHT_CLOSED);

    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *ctx) {
        ctx.duration = ANIMATION_DURATION;
        ctx.timingFunction = [CAMediaTimingFunction
            functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [[self.window animator] setFrame:target display:YES];
    } completionHandler:^{
        self.isExpanded = NO;
        self.isAnimating = NO;
    }];
}

- (void)startMouseMonitoring {
    // Global monitor when mouse moves outside window    
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskMouseMoved
            handler:^(NSEvent *event) {
        [self handleMouseAt:[self screenPositionFromEvent:event]];
    }];
    // Local monitor when mouse moves inside window
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskMouseMoved
            handler:^NSEvent *(NSEvent* event) {
        [self handleMouseAt:[self screenPositionFromEvent:event]];
        return event; 
    }];
}

- (NSPoint)screenPositionFromEvent:(NSEvent *)event {
    if (event.window){
        return [event.window convertPointToScreen:event.locationInWindow];
    }
    return event.locationInWindow;
}

- (void)handleMouseAt:(NSPoint)pos {
    NSRect sf = [NSScreen mainScreen].frame;

    CGFloat left    = (sf.size.width - NOTCH_WIDTH_CLOSED) / 2.0 - 20.0;
    CGFloat right   = (sf.size.width + NOTCH_WIDTH_CLOSED) / 2.0 + 20.0;
    CGFloat top     = (sf.size.height);
    CGFloat bottom  = (sf.size.height - NOTCH_HEIGHT_OPEN - 10);

    CGFloat hitBottom = self.isExpanded ? bottom : sf.size.height - NOTCH_HEIGHT_CLOSED - 10;

    BOOL inside = pos.x >= left && pos.x <= right &&
                  pos.y >= hitBottom && pos.y <= top;

    if (inside && !self.isExpanded && !self.isAnimating){
        [self cancelCollapseTimer];
        [self expand];
    } else if (!inside && self.isExpanded && !self.isAnimating){
        [self scheduleCollapse];
    } else if (inside){
        [self cancelCollapseTimer]; 
    }
}

- (void)scheduleCollapse{
    if (self.collapseTimer) return;
    self.collapseTimer = [NSTimer scheduledTimerWithTimeInterval:0.4
            target:self
            selector:@selector(collapse)
            userInfo:nil
            repeats:NO];
}

- (void)cancelCollapseTimer {
    [self.collapseTimer invalidate];
    self.collapseTimer = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) [self setup];
    return self;
}

- (void)setup {
    NSScreen* screen = [NSScreen mainScreen];
    NSRect sf = screen.frame;
    
    CGFloat x = (sf.size.width - NOTCH_WIDTH_CLOSED) / 2.0;
    CGFloat y = (sf.size.height - NOTCH_HEIGHT_CLOSED);
    NSRect frame = NSMakeRect(x, y, NOTCH_WIDTH_CLOSED, NOTCH_HEIGHT_CLOSED);

    self.window = [[NSWindow alloc]
        initWithContentRect:frame
                  styleMask:NSWindowStyleMaskBorderless
                    backing:NSBackingStoreBuffered
                      defer:NO];

    [self.window setLevel:NSScreenSaverWindowLevel];
    [self.window setOpaque:NO];
    [self.window setBackgroundColor:[NSColor clearColor]];
    [self.window setMovable:NO];
    [self.window setCollectionBehavior:
        NSWindowCollectionBehaviorCanJoinAllSpaces |
        NSWindowCollectionBehaviorStationary |
        NSWindowCollectionBehaviorIgnoresCycle];

    NotchView* view = [[NotchView alloc] initWithFrame:
        NSMakeRect(0, 0, NOTCH_WIDTH_CLOSED, NOTCH_HEIGHT_CLOSED)];
    [self.window setContentView:view];
    [self startMouseMonitoring];
}

- (void)show{
    [self.window orderFrontRegardless];

    
}

@end


