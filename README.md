# Silver Horn

iPhone-only iOS 17+ app that converts shared text into formatted social card images.

## Build

### Simulator

```bash
xcodebuild \
  -project SilverHorn.xcodeproj \
  -scheme SilverHorn \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5' \
  build \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
```

### Physical device (iPhone 12)

```bash
xcodebuild \
  -project SilverHorn.xcodeproj \
  -scheme SilverHorn \
  -destination 'platform=iOS,id=00008101-00015CD22187001E' \
  build \
  DEVELOPMENT_TEAM=$APPLE_TEAM_ID
```

> `APPLE_TEAM_ID` is already set in your `~/.zshrc`.
