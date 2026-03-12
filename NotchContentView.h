#import <Cocoa/Cocoa.h>
#import "SpotifyController.h"

@interface NotchContentView : NSView

- (instancetype)initWithFrame:(NSRect)frame spotify:(SpotifyController *)spotify;
- (void)refresh;

@end
