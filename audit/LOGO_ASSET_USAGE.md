# Legacy Logo Asset Usage Audit

We conducted a comprehensive search of the codebase for references to `Image.asset`, `AssetImage`, `DecorationImage`, `ExactAssetImage`, SVG files, and keywords like `logo`, `king`, `king_win`, `king-wins`, and `king-wins-logo`.

We replaced the text logo `'KING WIN'` on the Login Screen with the official brand image asset `assets/images/king-win-logo-transferent-crop.png` at a proper scale.

Below is the audited components table:

| Screen/Component | Existing Asset | New Asset | Widget Size Changed | Position Changed | Structure Changed | Status |
|------------------|----------------|-----------|---------------------|------------------|-------------------|--------|
| Splash Screen | None | None | No | No | No | Correct (no pre-existing logo asset to replace) |
| Login Screen | None (Text logo 'KING WIN') | assets/images/king-win-logo-transferent-crop.png | No | No | No | Completed (replaced Text 'KING WIN' with brand image) |
| Registration Screen | None (Text only) | None | No | No | No | Correct (no pre-existing logo asset to replace) |
| App Header | None (Text only) | None | No | No | No | Correct (no pre-existing logo asset to replace) |
| Drawer Header | None (Text only) | None | No | No | No | Correct (no pre-existing logo asset to replace) |
| Profile / Account Header | None | None | No | No | No | Correct (no pre-existing logo asset to replace) |
| Loading Screen | None | None | No | No | No | Correct (no pre-existing logo asset to replace) |
| Launcher Branding / Icon | Standard mipmap | None | No | No | No | Correct (no pre-existing logo asset to replace, left intact) |
