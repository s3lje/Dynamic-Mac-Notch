#import <Foundation/Foundation.h>

@interface SpotifyController : NSObject

- (NSDictionary *)currentTrackInfo;
- (void)togglePlayPause;
- (void)nextTrack;
- (void)previousTrack;

@end
