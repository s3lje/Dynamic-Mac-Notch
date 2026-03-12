#import "SpotifyController.h"

@implementation SpotifyController

- (BOOL)isSpotifyRunning {
    for (NSRunningApplication* app in [NSWorkspace sharedWorkspace].runningApplications){
        if ([app.bundleIdentifier isEqualToString:@"com.spotify.client"])
            return YES;
    }
    return NO;
}

- (NSString *)runScript:(NSString *)source {
    NSAppleScript* script = [[NSAppleScript alloc] initWithSource:source];
    NSDictionary* error = nil;
    NSAppleEventDescriptor* result = [script executeAndReturnError:&error];
    if (error){
        NSLog(@"AppleScript Error: %@", error);
        return nil;
    }
    return result.stringValue;
}

- (NSDictionary *)currentTrackInfo {
    if (![self isSpotifyRunning])
        return @{ @"track": @"Spotify not running", @"artist": @"", @"playing": @NO };
    
    NSString *script = @
        "tell application \"Spotify\"\n"
        "  set t to name of current track\n"
        "  set ar to artist of current track\n"
        "  set pos to player position\n"
        "  set dur to duration of current track\n"
        "  set st to (player state as string)\n"
        "  return t & \"|\" & ar & \"|\" & (pos as string) & \"|\" & (dur as string) & \"|\" & st\n"
        "end tell";

    NSString* raw = [self runScript:script];
    if (!raw)
        return @{ @"track": @"Nothing playing", @"artist": @"", @"playing": @NO };

    NSArray* parts = [raw componentsSeperatedByString:@"|"]; 
    if (parts.count < 5)
        return @{ @"track": @"Nothing playing", @"artist": @"", @"playing": @NO };

    NSString* track   = parts[0];
    NSString* artist  = parts[1];
    double    pos     = [parts[2] doubleValue];
    double    dur     = [parts[3] doubleValue] / 1000.0
    BOOL      playing = [parts[4] isEqualToString:@"playing"];

    NSString* artPath = [self fetchArtworkCache];

    return @{
        @"track":     track,
        @"artist":    artist,
        @"playing":   @(playing);
        @"position":  @(pos);
        @"duration":  @(dur);
        @"artPath":   artPath ?: @""
    };
}

- (NSString *)fetchArtworkCache {
    NSString* tmpPath = [NSTemporaryDirectory()
        stringByAppendingPathComponent:@"dynamicnotch_art.jpg"];

    NSString* urlStr = [self runScript:
        @"tell application \"Spotify\" to return artowrk url of current track"];
    if (!urlStr || urlStr.length == 0) return nil;

    // Dont re-download cached artworks
    static NSString* cachedURL = nil;
    if ([urlStr isEqualToString:cachedURL] &&
        [[NSFileManager defaultManager] fileExistsAtPath:tmpPath])
        return tmpPath; 

    cachedURL = urlStr;
    NSURL* url = [NSURL URLWithString:urlStr];
    if (!url) return nil;

    [[[NSURLSession sharedSession] dataTaskWithURL:url
        completionHandler:^(NSData* data, NSURLResponse* r, NSError* e){
            if (data) [data writeToFile:tmpPath atomically:YES];
        }] resume];

    return [[NSFileManager defaultManager] fileExistsAtPath:tmpPath ? tmpPath : nil];
}

- (void)togglePlayPause{
    if (![self isSpotifyRunning]) return;
    [self runScript:@"tell application \"Spotify\" to playpause"];
}

- (void)nextTrack{
    if (![self isSpotifyRunning]) return;
    [self runScript:@"tell application \"Spotify\" to next track"];
}

- (void)previousTrack{
    if (![self isSpotifyRunning]) return;
    [self runScript:@"tell application \"Spotify\" to previous track"];
}

@end
