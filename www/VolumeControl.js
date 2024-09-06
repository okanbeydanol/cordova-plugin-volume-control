function VolumeControl() {}

VolumeControl.prototype.toggleMute = function(success, error) {
    cordova.exec(success, error, 'VolumeControl', 'toggleMute', []);
};

VolumeControl.prototype.isMuted = function(success, error) {
    cordova.exec(success, error, 'VolumeControl', 'isMuted', []);
};

VolumeControl.prototype.getVolume = function(success, error) {
    cordova.exec(success, error, 'VolumeControl', 'getVolume', []);
};

VolumeControl.prototype.setVolume = function(volume, success, error) {
    if (volume > 1) {
        volume /= 100; // Normalize to 0-1 range
    }
    cordova.exec(success, error, 'VolumeControl', 'setVolume', [volume]);
};

// Export the VolumeControl class
module.exports = new VolumeControl();