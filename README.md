# RobCo Unified Operating System Emulator

* [Project page](https://zetoris.info/terminal/)
* [Promo video](https://www.youtube.com/watch?v=7jgpIeEnbYI)
* [Video tutorial](https://www.youtube.com/watch?v=s8ivxI4GXI4)

**Compiled using Turbo Pascal 7.1 (TPC.EXE)**
*note: freepascal won't work*
 
###### Installation:
Create `TERMINAL` folder wherever you want but preferably in root of any hard drive.
Place everything in it.
Cyrillic/arabic/etc. characters in path to folder are not accepted.

###### Run:
Double-click `START.BAT` or `START_FULLSCREEN.BAT` file in `TERMINAL` folder.

###### DOSBox Configuration:
Included DosBox version is already configured to run terminal, but for best results in fullscreen mode
you can open config file `DOSBox-0.74/dosbox_fullscreen.conf` and change `fullresolution` to your monitor resolution.
CPU and cycles settings are configured so that "beep" sound duration on terminal loading is ~1 second. If you experiencing
problems with terminal running too slow or too fast you can change `cycles` (default fixed 10000) in both DosBox 
configs (one for windowed and other for fullscreen mode). 
Note: if "beep" sound duration on startup is ~1 second and you just want to change the rate of letters appearance you must
change `[DELAY_TIME]` parameter in `SETTINGS.UOS` file instead of changing DOSBox configuration.

###### Terminal settings:
Open `SETTINGS.UOS` file and follow the instructions.

###### Menu customization:
Edit `MENU.UOS` file.
There is 4 sections: 3 submenus and main menu. Every section contains 8 lines, first line is screen title, the others are menu items.
Every menu item described by 2 parameters divided by `^` symbol. First parameter is title that will displayed in menu. 
Second parameter is function that will be executed when user press enter on this menu item. Example: `Documents^function_documents`.
If line contains only `^` symbol it will be ignored.

* Functions:
```
menu_mainmenu
menu_submenu1
menu_submenu2
menu_submenu3
changepassword_function
changeusername_function
shutdown_function
logout_function
documents_function
```

###### Terminal commands and functions:
* Navigation
Use TAB to switch between menu items. ENTER to select and ESC to exit (where available)
* Termlink screen commands:
`SET TERMINAL/INQUIRE` - begin hacking process<br/>
`LOGON [USERNAME]` - login to system<br/>
`SET HALT` - close terminal<br/>
`SET HALT RESTART` - restart terminal<br/>
`VERSION` - terminal version<br/>
* Documents
All documents located in `DOCS` folder, those are just TXT files. You can open and edit documents in notepad or in terminal itself.
To create, edit or delete document select `Edit documents` menu item and select following items.
To save new or edited document press "Esc" key on keyboard, it will save file and close text editor.
* Kiosk mode
Some in-game terminals only have notebook/diary functions, to emulate this you can switch terminal to kiosk mode.
Set `[MODE]` parameter in `SETTINGS.UOS` file to `1` and save it. 
All documents in kiosk mode stored in `KIOSK/TEXTS` folder.
You can change kiosk mode title in `KIOSK/TITLE.TXT`.

###### Terminal blocked
If you failed at hacking process and terminal became inaccessible, delete `BLOCKED.UOS` file from `TERMINAL` folder.


> README FILE v2.6