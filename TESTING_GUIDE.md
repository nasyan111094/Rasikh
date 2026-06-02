# Testing Guide - Rasikh Bug Fixes

## Quick Reference for Testing the Applied Fixes

---

## ✅ Test Case 1: Video Call Audio Routing
**What was fixed:** AgoraRtcException(-3) error on speaker phone setup

**Steps to test:**
1. Navigate to an upcoming video call
2. Join the video call
3. Verify the call connects without `AgoraRtcException(-3)` error
4. Check that audio routing works (speaker/earpiece switching)

**Expected Result:** Video call initializes and audio routing works properly

---

## ✅ Test Case 2: Audio Playback from HTTP
**What was fixed:** Cleartext HTTP traffic not permitted error for media streaming

**Steps to test:**
1. Navigate to a consultation with a voice note
2. Play the voice note
3. Observe the audio player UI
4. Test seeking through the audio

**Expected Result:** 
- Audio loads and plays without "Cleartext HTTP traffic not permitted" error
- Seeking works smoothly
- No timeout errors appear

---

## ✅ Test Case 3: Audio Seek Timeout
**What was fixed:** Timeout exception on audio seek (30s → 60s timeout)

**Steps to test:**
1. Open a consultation with voice notes
2. Play the audio
3. Try seeking to different parts of the audio by dragging the slider
4. Test on slow network (throttle network if possible)

**Expected Result:**
- Seeking operations complete successfully
- No "TimeoutException after 0:00:30" errors
- Graceful handling if network is very slow

---

## ✅ Test Case 4: Time Display Formatting
**What was fixed:** Incorrect countdown timer display (e.g., "3:27" showing as wrong value)

**Steps to test:**
1. View a list of consultations with upcoming sessions
2. Look at the countdown timer display
3. Observe the format as it counts down
4. Watch for times like "00:27:45" and "03:15:30"

**Expected Result:**
- Times display correctly with proper formatting
- Single digit values are padded (e.g., "00:27" not "0:27")
- Hours are properly formatted (e.g., "03:15:30" not "3:15:30")
- Countdown properly decrements every second

---

## ✅ Test Case 5: Audio Initialization
**What was fixed:** Long network delay handling on audio source loading

**Steps to test:**
1. On a slow network connection, open a consultation with voice notes
2. Observe the loading indicator
3. Wait for audio to initialize (up to 60 seconds if very slow)

**Expected Result:**
- Loading spinner displays
- Audio successfully loads even on slow networks
- Error shown only if audio truly cannot be accessed
- No premature timeouts

---

## Error Messages to Monitor For

### ❌ Should NO LONGER appear:
```
E/ExoPlayerImplInternal: Cleartext HTTP traffic to 89.117.60.202 not permitted
```

```
E/flutter: [ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: 
TimeoutException after 0:00:30.000000: Future not completed
```

```
E/flutter: [ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: 
AgoraRtcException(-3, null)
```

### ✅ May appear (but should be handled gracefully):
```
I/flutter: Seek error: Seek timeout
```
(This is logged but won't crash the app)

---

## Network Security Config Details

The Android network security config has been updated to:

1. **Allow HTTP for IP: 89.117.60.202**
   - This permits both API calls and media streaming (voice notes)
   - Critical for app functionality with the backend server

2. **Allow HTTP for localhost/127.0.0.1**
   - Useful for development and testing
   - Can be removed in production if desired

3. **All other domains require HTTPS**
   - Follows Android security best practices
   - Protects user data on other networks

---

## Video Call Initialization Flow

The video call initialization now handles audio routing gracefully:

```
1. Create Agora engine ✓
2. Initialize engine ✓
3. Register event handlers ✓
4. Enable video ✓
5. Enable audio ✓
6. Start preview ✓
7. [NEW] Try to set speaker phone (wrapped in try-catch) ✓
8. Join channel ✓
```

If step 7 fails, the app continues because system audio routing will handle it.

---

## Performance Notes

- **Audio timeouts increased from 30s to 60s**: Better handles slow networks
- **Error handling improved**: App won't crash on network timeouts
- **Graceful degradation**: Features continue even if non-critical operations timeout

---

## Debugging Tips

If issues still occur, check logs for:

1. **Audio playback errors:**
   - Look for "Audio init error:" in logs
   - Check file URL being used (should be like `/uploads/consultation-voice-notes/...`)

2. **Video call initialization:**
   - Look for "Agora" in logs
   - Check Agora engine initialization results

3. **Network issues:**
   - Verify device can reach `89.117.60.202:3050`
   - Check network security config is referenced in AndroidManifest.xml

---

## Timeline for Testing

**Priority:** High
- Audio playback from HTTP (Test Case 2)
- Video call initialization (Test Case 1)

**Priority:** Medium
- Time display formatting (Test Case 4)
- Audio seeking (Test Case 3)

**Priority:** Low
- Audio initialization on slow networks (Test Case 5)


