#import "NotchWindow.h"

#define NOTCH_WIDTH         300.0
#define NOTCH_HEIGHT_CLOSED 32.0
#define CORNER_RADIUS       18.0


// Interfaces
@interface NotchView : NSView
@end

@interface NotchWindow()
@property (strong) NSWindow* window;
@end


// Implementations
@implementation NotchView

- (void)drawRect:(NSRect)dirtyRect{
    NSBezierPath* path = [NSBezierPath
        bezierPathWithRoundedRect:self.bounds
            xRadius:CORNER_RADIUS
            yRadius:CORNER_RADIUS];
    [[NSColor colorWithRed:0.08 green:0.08 blue:0.08 alpha:0.97] setFill];
    [path fill]; 
}

@end

@implementation NotchWindow

- (instancetype)init {
    self = [super init];
    if (self) [self setup];
    return self;
}

- (void)setup {
    NSScreen* screen = [NSScreen mainScreen];
    NSRect sf = screen.frame;
    
    CGFloat x = (sf.size.width - NOTCH_WIDTH) / 2.0;
    CGFloat y = (sf.size.height - NOTCH_HEIGHT_CLOSED);
    NSRect frame = NSMakeRect(x, y, NOTCH_WIDTH, NOTCH_HEIGHT_CLOSED);

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
        NSMakeRect(0, 0, NOTCH_WIDTH, NOTCH_HEIGHT_CLOSED)];
    [self.window setContentView:view];
}

- (void)show{
    [self.window orderFrontRegardless];
}

@end
