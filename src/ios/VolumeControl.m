/********* VolumeControl.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#ifdef DEBUG
    #define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
    #define DLog(...)
#endif

@interface VolumeControl : CDVPlugin {
  // Member variables go here.
}

- (void)toggleMute:(CDVInvokedUrlCommand*)command;
- (void)isMuted:(CDVInvokedUrlCommand*)command;
- (void)setVolume:(CDVInvokedUrlCommand*)command;
- (void)getVolume:(CDVInvokedUrlCommand*)command;

@end

@implementation VolumeControl {
    MPVolumeView *volumeView;
    float previousVolume;
}

- (void)pluginInitialize {
    volumeView = [[MPVolumeView alloc] init];
    volumeView.hidden = YES;
    [self.webView addSubview:volumeView];
    previousVolume = -1.0;

    // Add an observer for volume changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChanged:)
                                                 name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                               object:nil];
}

// Method to handle volume change
- (void)volumeChanged:(NSNotification *)notification {
    DLog(@"Volume changed: %@", notification.userInfo);
}

// Make sure to remove the observer when the plugin is deallocated
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)toggleMute:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    DLog(@"toggleMute");

    UISlider* volumeSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeSlider = (UISlider*)view;
            break;
        }
    }

    if (volumeSlider != nil) {
        if (previousVolume < 0) {
            previousVolume = volumeSlider.value;
            [volumeSlider setValue:0.0 animated:NO];
        } else {
            [volumeSlider setValue:previousVolume animated:NO];
            previousVolume = -1.0;
        }
        [volumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Volume slider not found"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)isMuted:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    DLog(@"isMuted");

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL isMuted = audioSession.outputVolume == 0.0;

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isMuted];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setVolume:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    float volume = [[command argumentAtIndex:0] floatValue];

    DLog(@"setVolume: [%f]", volume);

    UISlider* volumeSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeSlider = (UISlider*)view;
            break;
        }
    }

    if (volumeSlider != nil) {
        [volumeSlider setValue:volume animated:NO];
        [volumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Volume slider not found"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getVolume:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    DLog(@"getVolume");

    UISlider* volumeSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeSlider = (UISlider*)view;
            break;
        }
    }

    if (volumeSlider != nil) {
        float currentVolume = volumeSlider.value;
        
        // Fallback to AVAudioSession output volume if MPVolumeSlider returns 0.0 on the first call
        if (currentVolume == 0.0 && previousVolume < 0) {
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            currentVolume = audioSession.outputVolume;
        }

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:currentVolume];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Volume slider not found"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
