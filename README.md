# RevComEngine Core

RevComEngine's RPG Maker core engine plugin (formally known as BGMRPGM Core)

RevComEngine Core is the free and open source main plugin for Bigman's Revolutionary Communications RPG Maker plugins, and will be required for all future related plugins. It has the base ability to allow developers to create visual interfaces, interactive elements like inputs and buttons, and event driven functionality.
It's features include:

- Interfaces can be created, customized, and managed from a central point
- Interfaces can contain graphical elements like text, images, or bars, interactive elements like buttons or input boxes, and lists of elements
- User input mapping including alphanumeric keys, space bar, back button, enter button, tab bar, and shift bar
- Timer and scene change events that can call functions
- Mouse position tracking and mouse button interaction checking capability
- Buttons can respond to mouse interactions including mouse over, mouse out, and mouse click which can be set to call functions
- Inputs can be given focus or blurred and set to send inputted text to a function
- Can set mouse representation image
- Interfaces can follow game players or characters
- Inputs can be restricted to allow alphanumeric characters, letters, or numbers, and set to allow spaces in text
- Bars can use numerical or time based values
- Can store user settings and save them locally
- Can log to local files
- Download files that have been registered with the server by latest version or sets of files by game version. This includes:
     - Audio files: BGM, BGS, ME, and SE
     - Graphics files: Animations, Battlebacks1, Battlebacks2, Battlers, Characters, Faces, Parallaxes, Pictures,
                       System, Tilesets, Titles1, and Titles2
     - Data scripts

**Release 1.1 Fixes**

Change Log:

- When any function is called while RPG Maker is initially loading classes, an system failure error occurred. This was caused by trying to get the default dialog window color from the RPG Maker before they were loaded. The correction was to use hard-coded values until they become available after loading.
- When creating multiple windows, a system error would occur. This was caused by updating hash values while they were being accessed by other processes. This was corrected by implementing the existing safe hash updating process as part of window management.
- Ticket "Timer Calling Function That Creates Timer Fails" fixed where using timer within function called by a timer failed.
- Corrected where input box cursor was initially hidden from view.
- Corrected where, after changing the button's fonts, the change would not occur until a mouse event occurred to the button
- Fixed issue where interactive element lists did not align properly.
- When setting input boxes' setting for returning entered text, a system occurred. This was fixed by correcting a syntax error.

Note: There are a number of new features that were part of 2.0 in the release. These are possibility partially implemented or developed. There will not covered in this documentation.

**2.0 Major Release**

Change Log:

- User Sessions: A login process that allows users to be connected clients in RevCommServer for operations in database tracking.
- Timers: The functionality has been overhauled to remove types and all timers can be set to run continuously or for a number of intervals, and pass parameters to called functions.
- Bars: Updated functionality to automatically update the bar's visible state when its values change.
- Downloads: Fixed issue where multiple downloads running at the same time have a high change of failure. This issue has been corrected by queuing download files individually.
- Bars: Fixed issue were setting bars through interface caused an error, This has been corrected.
- Server Connection: Changed default RevCommServer connection port from 40000 to 59234
- Downloader Install: The install scripts for the Downloader functionality has been included with the install script for Release 2.0.
- Map Events: There was an issue where the event would not fire on the last map with the highest number ID. This was corrected.
- Image Load: An error would occur if an image resource had been released when it was attempted to be retrieved.
- Memory Resource Release: Improvements were made to release resources. This includes options for releasing image and interface resources.
- Interface Text: There was an issues where text was not space appropriately within the area of the interface. This has be corrected.
- Interface Component Movement: There was an issue where components within an interface would not reposition appropriately with the interface's movement. This has been corrected.
- Interface Blinking: When the interface was in blink mode, there was an issue where the blinking was inconsistent. This has been corrected.
- Scene Events: The ability to setup events on scene change removed. This functionality had multiple issues that can not be resolved, so it was removed.
