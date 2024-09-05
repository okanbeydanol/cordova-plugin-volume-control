/*
 * Cordova/Phonegap VolumeControl Plugin for Android
 * Cordova >= 3.0.0
 * Author: Manuel Simpson
 * Email: manusimpson[at]gmail[dot]com
 * Date: 12/28/2012
 *
 * At 04/28/2017 working in app compiled with Cordova 6.5.0
 */

package com.lorentech.cordova.plugins.volumeControl;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;
import org.json.JSONArray;
import org.json.JSONException;

import android.content.Context;
import android.media.AudioManager;
import android.util.Log;

public class VolumeControl extends CordovaPlugin {

    public static final String SET = "setVolume";
    public static final String GET = "getVolume";
    public static final String MUT = "toggleMute";
    public static final String ISM = "isMuted";

    private static final String TAG = "VolumeControl";

    private Context context;
    private AudioManager manager;

    @Override
    protected void pluginInitialize() {
        context = cordova.getActivity().getApplicationContext();
        manager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        boolean actionState = true;

        switch (action) {
            case SET:
                setVolume(args, callbackContext);
                break;
            case GET:
                getVolume(callbackContext);
                break;
            case MUT:
                toggleMute(args, callbackContext);
                break;
            case ISM:
                isMuted(callbackContext);
                break;
            default:
                actionState = false;
                break;
        }
        return actionState;
    }

    private void setVolume(JSONArray args, CallbackContext callbackContext) {
        try {
            int volumeToSet = (int) Math.round(args.getDouble(0) * 100.0f);
            int volume = getVolumeToSet(volumeToSet);
            boolean playSound = args.length() > 1 && !args.isNull(1) && args.getBoolean(1);

            manager.setStreamVolume(AudioManager.STREAM_MUSIC, volume, playSound ? AudioManager.FLAG_PLAY_SOUND : 0);
            callbackContext.success();
        } catch (Exception e) {
            Log.e(TAG, "Error setting volume", e);
            callbackContext.error("Error setting volume: " + e.getMessage());
        }
    }

    private void getVolume(CallbackContext callbackContext) {
        try {
            int currentVolume = getCurrentVolume();
            float volume = currentVolume / 100.0f;
            callbackContext.success(String.valueOf(volume));
        } catch (Exception e) {
            Log.e(TAG, "Error getting volume", e);
            callbackContext.error("Error getting volume: " + e.getMessage());
        }
    }

    private void toggleMute(JSONArray args, CallbackContext callbackContext) {
        try {
            int currentVolume = getCurrentVolume();
            float volumeToSet = (float) args.getDouble(0);
            int volume = (currentVolume > 1) ? 0 : getVolumeToSet((int) Math.round(volumeToSet * 100.0f));

            manager.setStreamVolume(AudioManager.STREAM_MUSIC, volume, AudioManager.FLAG_PLAY_SOUND);
            callbackContext.success(volume);
        } catch (Exception e) {
            Log.e(TAG, "Error toggling mute/unmute", e);
            callbackContext.error("Error toggling mute/unmute: " + e.getMessage());
        }
    }

    private void isMuted(CallbackContext callbackContext) {
        try {
            int currentVolume = getCurrentVolume();
            callbackContext.success(currentVolume == 0 ? 0 : 1);
        } catch (Exception e) {
            Log.e(TAG, "Error checking mute status", e);
            callbackContext.error("Error checking mute status: " + e.getMessage());
        }
    }

    private int getVolumeToSet(int percent) {
        try {
            int maxVolume = manager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
            return Math.round((percent * maxVolume) / 100);
        } catch (Exception e) {
            Log.e(TAG, "Error getting volume to set", e);
            return 1;
        }
    }

    private int getCurrentVolume() {
        try {
            int maxVolume = manager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
            int currentSystemVolume = manager.getStreamVolume(AudioManager.STREAM_MUSIC);
            return Math.round((currentSystemVolume * 100) / maxVolume);
        } catch (Exception e) {
            Log.e(TAG, "Error getting current volume", e);
            return 1;
        }
    }
}