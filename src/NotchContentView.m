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
        [self buildUI];
    }
    return self; 
}

- (void)buildUI {
    self.albumArt = [[NSImageView alloc] init];
    self.albumArt.wantsLayer = YES;
    self.albumArt.layer.cornerRadius = 8;
    self.albumArt.layer.masksToBounds = YES;
    self.albumArt.imageScaling = NSImageScaleAxesIndependently;
    self.albumArt.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.albumArt]; 

        // Track name
    self.trackLabel = [self labelWithFont:
        [NSFont systemFontOfSize:13 weight:NSFontWeightSemibold]
                                    color:TEXT_PRIMARY];
    [self addSubview:self.trackLabel];

    // Artist name
    self.artistLabel = [self labelWithFont:
        [NSFont systemFontOfSize:11 weight:NSFontWeightRegular]
                                     color:TEXT_SECONDARY];
    [self addSubview:self.artistLabel];

        // Progress bar
    self.progressBar = [[NSProgressIndicator alloc] init];
    self.progressBar.style = NSProgressIndicatorStyleBar;
    self.progressBar.minValue = 0;
    self.progressBar.maxValue = 100;
    self.progressBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.progressBar];
    [self.progressBar setIndeterminate:NO];

    // Transport buttons
    self.prevBtn      = [self transportButton:@"backward.fill" action:@selector(onPrev)];
    self.playPauseBtn = [self transportButton:@"play.fill"     action:@selector(onPlayPause)];
    self.nextBtn      = [self transportButton:@"forward.fill"  action:@selector(onNext)];
    [self addSubview:self.prevBtn];
    [self addSubview:self.playPauseBtn];
    [self addSubview:self.nextBtn];

    [self setupConstraints];
}

- (void)setupConstraints {
    CGFloat p = PAD;

    [NSLayoutConstraint activateConstraints:@[
        // Album art — top left corner
        [self.albumArt.topAnchor     constraintEqualToAnchor:self.topAnchor    constant:p],
        [self.albumArt.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:p],
        [self.albumArt.widthAnchor   constraintEqualToConstant:52],
        [self.albumArt.heightAnchor  constraintEqualToConstant:52],

        // Track label — right of album art
        [self.trackLabel.topAnchor      constraintEqualToAnchor:self.albumArt.topAnchor constant:4],
        [self.trackLabel.leadingAnchor  constraintEqualToAnchor:self.albumArt.trailingAnchor constant:10],
        [self.trackLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-p],

        // Artist label — below track
        [self.artistLabel.topAnchor     constraintEqualToAnchor:self.trackLabel.bottomAnchor constant:3],
        [self.artistLabel.leadingAnchor constraintEqualToAnchor:self.trackLabel.leadingAnchor],
        [self.artistLabel.trailingAnchor constraintEqualToAnchor:self.trackLabel.trailingAnchor],

        // Progress bar — below album art
        [self.progressBar.topAnchor      constraintEqualToAnchor:self.albumArt.bottomAnchor constant:12],
        [self.progressBar.leadingAnchor  constraintEqualToAnchor:self.leadingAnchor constant:p],
        [self.progressBar.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-p],
        [self.progressBar.heightAnchor   constraintEqualToConstant:3],

        // Prev button
        [self.prevBtn.topAnchor     constraintEqualToAnchor:self.progressBar.bottomAnchor constant:12],
        [self.prevBtn.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:-44],
        [self.prevBtn.widthAnchor   constraintEqualToConstant:32],
        [self.prevBtn.heightAnchor  constraintEqualToConstant:32],

        // Play/pause button — center
        [self.playPauseBtn.topAnchor     constraintEqualToAnchor:self.prevBtn.topAnchor],
        [self.playPauseBtn.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.playPauseBtn.widthAnchor   constraintEqualToConstant:36],
        [self.playPauseBtn.heightAnchor  constraintEqualToConstant:36],

        // Next button
        [self.nextBtn.topAnchor     constraintEqualToAnchor:self.prevBtn.topAnchor],
        [self.nextBtn.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:44],
        [self.nextBtn.widthAnchor   constraintEqualToConstant:32],
        [self.nextBtn.heightAnchor  constraintEqualToConstant:32],
    ]];
}

- (void)refresh {
    NSDictionary *info = [self.spotify currentTrackInfo];

    self.trackLabel.stringValue  = info[@"track"]  ?: @"Nothing playing";
    self.artistLabel.stringValue = info[@"artist"] ?: @"";

    BOOL playing = [info[@"playing"] boolValue];
    NSString *iconName = playing ? @"pause.fill" : @"play.fill";
    [self.playPauseBtn setImage:[self symbolImage:iconName size:16]];

    double pos = [info[@"position"] doubleValue];
    double dur = [info[@"duration"] doubleValue];
    self.progressBar.doubleValue = dur > 0 ? (pos / dur) * 100.0 : 0;

    NSString *artPath = info[@"artPath"];
    if (artPath.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:artPath]) {
        self.albumArt.image = [[NSImage alloc] initWithContentsOfFile:artPath];
    } else {
        self.albumArt.image = [NSImage imageWithSystemSymbolName:@"music.note"
                                        accessibilityDescription:nil];
    }
}

// ── Actions ───────────────────────────────────────────────────────────────────

- (void)onPrev      { [self.spotify previousTrack];  [self refresh]; }
- (void)onNext      { [self.spotify nextTrack];      [self refresh]; }
- (void)onPlayPause { [self.spotify togglePlayPause]; [self refresh]; }

// ── Drawing ───────────────────────────────────────────────────────────────────

- (void)drawRect:(NSRect)dirtyRect {
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:self.bounds
                                                         xRadius:18
                                                         yRadius:18];
    [[NSColor colorWithRed:0.08 green:0.08 blue:0.08 alpha:0.97] setFill];
    [path fill];
}

// ── Helpers ───────────────────────────────────────────────────────────────────

- (NSTextField *)labelWithFont:(NSFont *)font color:(NSColor *)color {
    NSTextField *f = [[NSTextField alloc] init];
    f.font = font;
    f.textColor = color;
    f.editable = NO;
    f.selectable = NO;
    f.bezeled = NO;
    f.drawsBackground = NO;
    f.lineBreakMode = NSLineBreakByTruncatingTail;
    f.translatesAutoresizingMaskIntoConstraints = NO;
    return f;
}

- (NSButton *)transportButton:(NSString *)symbol action:(SEL)action {
    NSButton *btn = [[NSButton alloc] init];
    [btn setImage:[self symbolImage:symbol size:15]];
    btn.bezelStyle = NSBezelStyleCircular;
    btn.bordered = NO;
    btn.contentTintColor = TEXT_PRIMARY;
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    btn.target = self;
    btn.action = action;
    return btn;
}

- (NSImage *)symbolImage:(NSString *)name size:(CGFloat)size {
    return [[NSImage imageWithSystemSymbolName:name accessibilityDescription:nil]
        imageWithSymbolConfiguration:
            [NSImageSymbolConfiguration configurationWithPointSize:size
                                                            weight:NSFontWeightMedium]];
}

@end
