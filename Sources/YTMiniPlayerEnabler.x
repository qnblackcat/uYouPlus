#import "uYouPlus.h"

// YTMiniPlayerEnabler: https://github.com/level3tjg/YTMiniplayerEnabler/
%hook YTWatchMiniBarViewController
- (void)updateMiniBarPlayerStateFromRenderer {
    if (IS_ENABLED(kYTMiniPlayer)) {}
    else { return %orig; }
}
%end