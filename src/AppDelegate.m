#import "AppDelegate.h"
#import "NotchWindow.h"
#import "SpotifyController.h"

@implementation AppDelegate {
    NotchWindow* _notchWindow;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    SpotifyController* spotify = [[SpotifyController alloc] init];
   _notchWindow = [[NotchWindow alloc] init];
   [_notchWindow show];
}

@end
