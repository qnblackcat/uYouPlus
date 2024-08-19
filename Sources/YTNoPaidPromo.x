#import <YouTubeHeader/YTPlayerOverlayProvider.h>
#import <YouTubeHeader/YTPlayerOverlay.h>
#import "uYouPlus.h"

// YTNoPaidPromo: https://github.com/PoomSmart/YTNoPaidPromo
%hook YTMainAppVideoPlayerOverlayViewController
- (void)setPaidContentWithPlayerData:(id)data {
    if (IS_ENABLED(kHidePaidPromotionCard)) {}
    else { return %orig; }
}
- (void)playerOverlayProvider:(YTPlayerOverlayProvider *)provider didInsertPlayerOverlay:(YTPlayerOverlay *)overlay {
    if ([[overlay overlayIdentifier] isEqualToString:@"player_overlay_paid_content"] && IS_ENABLED(kHidePaidPromotionCard)) return;
    %orig;
}
%end

%hook YTInlineMutedPlaybackPlayerOverlayViewController
- (void)setPaidContentWithPlayerData:(id)data {
    if (IS_ENABLED(kHidePaidPromotionCard)) {}
    else { return %orig; }
}
%end