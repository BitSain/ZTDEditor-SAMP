# Zamaroht's TextDraw Editor for SA-MP (ZTDEditor)

[![Release](https://img.shields.io/github/v/release/BitSain/ZTDEditor-SAMP?logo=github)](https://github.com/BitSain/ZTDEditor-SAMP/releases)
[![Downloads](https://img.shields.io/github/downloads/BitSain/ZTDEditor-SAMP/total?logo=github)](https://github.com/BitSain/ZTDEditor-SAMP/releases)
![Build Active](https://img.shields.io/badge/build-active-brightgreen?logo=github)
[![Last Commit](https://img.shields.io/github/last-commit/BitSain/ZTDEditor-SAMP?logo=github)](https://github.com/BitSain/ZTDEditor-SAMP/commits/master)

## Description
- **Zamaroht's TextDraw Editor Version v1.0.0**
- Designed for SA-MP 0.3.7

~~ ~~ ~~ ~~ ~~ ~~ ~~ ~~ ~~ ~~

**<!> Current version: v1.0.0**

~~ ~~ ~~ ~~ ~~ ~~ ~~ ~~ ~~ ~~

## About the TextDraw Editor

The TextDraw Editor was originally created by Zamaroht. I, BitSain, have continued its development.

**Original Author**: Zamaroht (Nicolás Laurito)  
**Continued by**: BitSain (bitsaindeveloper@gmail.com)

- **Initial Development**:
  - Start: December 25, 2009, 22:16 (GMT-3)
  - End: January 1, 2010, 23:31 (GMT-3)
  - [Link to the original author (recovered)](https://sampforum.blast.hk/member.php?action=profile&uid=5955)
  - [Link to the "Original" Project (recovered)](https://sampforum.blast.hk/showthread.php?tid=117851&highlight=Zamaroht%27s)

- **Continued Development**:
  - Start: February 24, 2024, 11:15 (GMT-3) [BRAZIL]

## Features
- Support for multiple textdraws at the same time.
- User-friendly interface with few commands.
- Preview of each textdraw in the selection menu for easy recognition.
- Interface primarily operated through dialogs.
- Movement and resizing using arrow keys.
- Duplicate textdraws, faster and more precise GUI editing.
- Project support: create, load, delete, import, and export projects with individual textdraws.
- Automatic project save after each edit.
- Creation of self-working filterscripts within the game.
- Support for custom colors, including custom color palettes.
- Improved stability and error handling.

## Current Version Changelog (pre v1.1.0)
- Optimized 100% of the codebase.
- Added directory folder for ZTDE.
- Import of Textdraws completed. (I test the editor's stuff myself, and I say that this is beyond 1000%).
- Implemented help command /zHelp.
- Corrected string concatenation in project loading.
- Improved handling of directories and files to avoid crashes.
- Ensured proper resource management and file/directory closing.
- Added file opening checks and clear error messages.
- Added `y_iterate` include for TDID manipulation with lists.
- Implemented Back Button functionality.
- Fixed "ISSUE 2" related to TextSize in UpdateTextdraw.
- Improved "Reorder TextDraws IDs" under "Others Options".
- Refined project description in "ZTDE.pwn".
- Enhanced editor functions for TextDraw adaptation using `y_iterate.inc`.
- Implemented character replacement in "Change TD String" to avoid line breaks.
- Increased maximum TextDraws from 90 to 256.
- Removed '/importtextdraw' command, integrated into '/text' dialog.
- Added DEBUG Enable/Disable and Debug Levels feature.
- Corrected ZTDE messages and implemented "ScriptMessage" macro.
- Fixed logical issues and verifications using TextDraw T_Handler.
- Restricted '/text' usage during TextDraw reordering.

## Images
Print of Textdraw Import.
![Textdraw Import](https://github.com/BitSain/ZTDEditor-SAMP/blob/main/images/Screenshot_20240611-102435.png)

## Important
Remember, to be able to use your creations, you must select the Export option from the menu. The .tde and .lst files are used internally by the Editor and should not be modified or used by humans.

## Credits
- 'Zamaroht' Nicolás Laurito (Author and Creator of version v1.0.0)
- BitSain (Repository creator and project continuer from v1.0.0)
- Y_Less (YSI includes & sscanf2)
- JaTochNietDan (filemanager plugin)
- oscar-broman (strlib)
- Dini and dutils functions were used by DracoBlue.

## Disclaimer
- You do not need to include me in your credits if you used this filterscript to create your textdraws.
- You hold all rights over the exported files and filterscripts created by this filterscript.
- You can redistribute the main filterscript as you wish, but ALWAYS keep the name of the author, the continuator, and a link back to the [original post](https://portalsamp.com/showthread.php?tid=4754) attached to the means of distribution. Even if you create a modification based on this filterscript, the same terms apply.
