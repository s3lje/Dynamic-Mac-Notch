#import "NotchContentView.h"

#define PAD             14.0
#define TEXT_PRIMARY    [NSColor colorWithWhite:0.93 alpha:1.0]
#define TEXT_SECONDARY  [NSColor colorWithWhite:0.50 alpha:1.0]
#define ACCENT          [NSColor colorWithRed:0.20 green:0.78 blue:0.35 alpha:1.0]

@interface NotchContentView ()
@property (strong) SpotifyController* spotify;
@property (strong) NSImageView* albumArt; 
@property (strong) NSTextField* trackLabel;
@property (strong) NSTextField* artistLabel;
@property (strong) NSProgressIndicator* progressBar;
@property (strong) NSButton* prevBtn;
@property (strong) NSButton* playPauseBtn;
@property (strong) NSButton* nextBtn;
@end


@implementation NotchContentView

- (instancetype)initWithFrame:(NSRect)frame spotify:(SpotifyController *)spotify{
    self = [super initWithFrame:frame];
    if (self){
        self.spotify = spotify;
        [self.buildUI];
    }
    return self; 
}


