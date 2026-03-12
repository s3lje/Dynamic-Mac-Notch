#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "SpotifyController.h"

@interface NotchWindow : NSObject

- (instancetype)initWithSpotify:(SpotifyController *)spotify;
- (void)show;

@end
