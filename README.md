# Silver Horn

iPhone-only iOS 17+ app that converts shared text into formatted social card images.

## Build

### Simulator

```bash
xcodebuild \
  -project SilverHorn.xcodeproj \
  -scheme SilverHornShareExtension \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5' \
  build \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
```

### Physical device (iPhone 12)

```bash
xcodebuild \
  -project SilverHorn.xcodeproj \
  -scheme SilverHornShareExtension \
  -destination 'platform=iOS,id=00008101-00015CD22187001E' \
  build \
  DEVELOPMENT_TEAM=$APPLE_TEAM_ID
```

> `APPLE_TEAM_ID` is already set in your `~/.zshrc`.

### Physical device with share extension (build + install + launch)

Use the same commands we used for the connected iPhone in this thread.

```bash
# Build
xcodebuild \
  -project SilverHorn.xcodeproj \
  -scheme SilverHornShareExtension \
  -destination 'platform=iOS,id=00008101-00015CD22187001E' \
  -derivedDataPath /tmp/silverhorn-device-build \
  -allowProvisioningUpdates \
  build \
  DEVELOPMENT_TEAM=$APPLE_TEAM_ID

# Install
xcrun devicectl device install app \
  --device 3BDB28E9-1496-576F-ACD7-F5F3F8E8BDEC \
  /tmp/silverhorn-device-build/Build/Products/Debug-iphoneos/SilverHorn.app

# Launch
xcrun devicectl device process launch \
  --device 3BDB28E9-1496-576F-ACD7-F5F3F8E8BDEC \
  club.skape.silverhorn
```
