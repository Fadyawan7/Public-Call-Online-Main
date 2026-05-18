# Direction Tracking Module - Integration Guide

## 📋 Quick Start

### Step 1: Verify Dependencies
All required dependencies are already in your `pubspec.yaml`:
- ✅ `google_maps_flutter: ^2.6.1`
- ✅ `geolocator: ^14.0.0`
- ✅ `provider: ^6.1.5`
- ✅ `dio: ^5.4.3+1`

### Step 2: Add to Your Freelancer Detail Widget

Option A: Using the Helper Button
```dart
import 'package:flutter_restaurant/features/direction/widgets/direction_tracking_button_widget.dart';

// In your freelancer detail widget:
DirectionTrackingButton(
  freelancer: freelancerModel,
  userLatitude: currentPosition.latitude,
  userLongitude: currentPosition.longitude,
)
```

Option B: Manual Navigation
```dart
import 'package:flutter_restaurant/helper/router_helper.dart';

ElevatedButton.icon(
  onPressed: () {
    Navigator.of(context).pushNamed(
      RouterHelper.getDirectionRoute(
        freelancer,
        currentPosition.latitude,
        currentPosition.longitude,
      ),
    );
  },
  icon: Icon(Iconsax.location),
  label: Text('Track Direction'),
)
```

### Step 3: Permissions Configuration

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show direction tracking</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location for real-time tracking</string>
```

### Step 4: Test the Implementation

1. **Build and run your app**:
   ```bash
   flutter pub get
   flutter run
   ```

2. **Test on physical device** (Emulator GPS may have issues)

3. **Test scenarios**:
   - ✅ Navigate to a freelancer detail page
   - ✅ Tap "Start Direction" button
   - ✅ Verify permission dialog appears
   - ✅ Grant location permission
   - ✅ Map loads with markers and polyline
   - ✅ Move around and see marker update
   - ✅ Check distance and ETA update
   - ✅ Press Pause, Resume, Stop buttons
   - ✅ Go to app background and return

## 🎯 Feature Usage

### Real-Time Tracking
- **Automatic Start**: Begins when direction screen opens
- **Update Frequency**: Every 10 meters or every 5 seconds
- **Accuracy**: High (GPS level)
- **Progress Bar**: Visual indicator of journey progress

### Control Buttons
- **Pause**: Temporarily stop tracking without losing route
- **Resume**: Continue tracking from paused state
- **Stop**: End tracking and return to previous screen

### Error Handling
- Shows user-friendly messages for:
  - GPS disabled
  - Location permission denied
  - No internet connection
  - API failures (uses direct path fallback)

## 📊 State Management

The `DirectionProvider` manages:
- Current location
- Route data
- Polyline progress
- Tracking status
- Error messages

Access via Provider:
```dart
Consumer<DirectionProvider>(
  builder: (context, directionProvider, child) {
    return Text('Distance: ${directionProvider.distanceRemaining}m');
  },
)
```

## 🔧 Customization

### Change Location Update Threshold
File: `lib/features/direction/providers/direction_provider.dart`
```dart
static const int _locationUpdateThresholdMeters = 10; // Change to 20, 50, etc.
```

### Change Destination Detection Range
File: `lib/features/direction/providers/direction_provider.dart`
```dart
if (distanceToDestination < 50) // Change from 50 to other value
```

### Customize UI Colors
File: `lib/features/direction/widgets/direction_info_widget.dart`
- Modify primaryColor references
- Adjust icon colors
- Change button colors

### Customize Marker Icons
File: `lib/features/direction/screens/direction_screen.dart`
```dart
// Modify marker builder function
icon: BitmapDescriptor.defaultMarkerWithHue(
  BitmapDescriptor.hueBlue, // Change color
)
```

## 🐛 Troubleshooting

### Map not showing
- [ ] Check Google Maps API key in `app_constants.dart`
- [ ] Verify Maps plugin is initialized
- [ ] Check Android/iOS manifest files

### Location not updating
- [ ] Verify location permissions granted
- [ ] Check GPS is enabled on device
- [ ] Ensure device is outdoors for GPS signal
- [ ] Check location accuracy is not too high

### Polyline not appearing
- [ ] Verify route points are being fetched
- [ ] Check API response from Google Directions API
- [ ] Ensure start and end points are valid

### App crashes on direction screen
- [ ] Check Dart exceptions in logcat/Xcode
- [ ] Verify freelancer has valid coordinates
- [ ] Check null safety: coordinates should not be 0,0

### Expensive API calls
- [ ] Google Directions API has usage limits
- [ ] Consider caching routes in shared preferences
- [ ] Implement route caching to reduce API calls

## 📱 Device Testing

### Emulator GPS
⚠️ Note: GPS on emulators is unreliable. Use:
```bash
# Terminal 1: Run your app
flutter run

# Terminal 2: Send GPS coordinates
telnet localhost 5554
geo fix 37.7749 -122.4194 # Example: San Francisco
```

### Real Device Testing ✅ Recommended
- Use actual device with GPS
- Go outdoors for better signal
- Test with real movement

## 🔐 Security Notes

1. **API Key Security**:
   - Never commit API keys to version control
   - Use environment variables or secure storage
   - Restrict API key in Google Cloud Console

2. **Location Privacy**:
   - Only request location when needed
   - Show clear permission requests
   - Respect user privacy settings

3. **Background Location**:
   - iOS requires special permissions
   - Android requires foreground service on Android 8+
   - Inform users about background tracking

## 📈 Performance Tips

1. **Reduce Update Frequency**:
   - Increase `_locationUpdateThresholdMeters` for slower updates
   - Save battery on longer routes

2. **Optimize Polyline**:
   - Simplify route points for fewer polyline segments
   - Use polyline decimation for long routes

3. **Memory Management**:
   - Provider automatically disposes on widget removal
   - Check for memory leaks in long tracking sessions

## 🎨 UI Customization Example

```dart
// In direction_info_widget.dart
LinearProgressIndicator(
  value: polylineData!.progressPercentage / 100,
  minHeight: 8, // Increase from 6
  backgroundColor: Colors.grey[300],
  valueColor: AlwaysStoppedAnimation<Color>(
    Colors.teal, // Change from primary color
  ),
)
```

## 📞 Support & Debugging

### Enable Debug Logs
The provider uses `debugPrint()` for logging. Check:
- Android Studio Logcat
- Xcode Console
- `flutter run -v` for verbose output

### Common Debug Output
```
🟢 Tracking started
🟢 Location updated: 37.7749, -122.4194
🟢 Distance: 2.5 km, ETA: 8 minutes
🟡 Location stream paused
🔴 Location error: GPS service disabled
```

## Next Steps

1. ✅ Copy all direction module files
2. ✅ Update DI container
3. ✅ Add DirectionProvider to main.dart
4. ✅ Configure routes in router_helper.dart
5. ✅ Add button to freelancer detail screen
6. ✅ Configure Android/iOS permissions
7. ✅ Test on physical device
8. ✅ Deploy to production

---

**Module Status**: ✅ Production Ready
**Last Updated**: May 2026
**Compatibility**: Flutter 3.3.4+, Dart 3.3+
