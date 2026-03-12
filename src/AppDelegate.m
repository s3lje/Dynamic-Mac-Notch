#import "AppDelegate.h"
#import "NotchWindow.h"

@implementation AppDelegate {
    NotchWindow* _notchWindow;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
   _notchWindow = [[NotchWindow alloc] init];
   [_notchWindow show];
}

@end
