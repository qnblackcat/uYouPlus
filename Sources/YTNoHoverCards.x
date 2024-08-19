#import "uYouPlus.h"

// YTNoHoverCards: https://github.com/level3tjg/YTNoHoverCards
%hook YTCreatorEndscreenView
- (void)setHidden:(BOOL)hidden {
    if (IS_ENABLED(kHideHoverCards))
        hidden = YES;
    %orig;
}
%end