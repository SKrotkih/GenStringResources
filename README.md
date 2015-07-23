GenStringResources
====================

##Introduction

GenStringResources is a Mac OS application. It requirements MacOS at least 10.6.4 and above, Xcode 4.3 and above. The application uses ibtool and genstrings utilities from Xcode. 
GenStringResources may be used for localization of the Xcode projects in Objective-C.
Application is divided on following parts:
⁃    scanner of the string resources from the Localizable.strings files;
⁃    scanner of the string resources from the XIB files;
⁃    of the string resources creator;
⁃    presenting total information about all string resources for all languages for all projects;
⁃    setting up all options of the application.
Scanner of the resources is passed all Localizable.strings by genstrings utility. It passed by recursive  all folder with modules with the source code of a project. It generates Localizable.strings file with total string resources for the project.
It orders in ascending of key (it is a left part of the line before '=' in the file with resources). Then, it takes the current files with string resources for every language scheme (lproj-folder with according Localizable.strings file) and uses for comparing them with new 
string resources on existing by key. In result, we have total string resources with new string without translating and old string with them. The string without translating are kept in separate Localizable.strings which can be used for translate.
After translate, all new strings can be merged with current resources by the application. 
The same as the scanner of the string resources, the scanner of the XIB, used ibtool utility, builds the similar total file as the previous scanner, just for XIB strings resources.
All operation are carried out in automatic mode for every active project. You can set up active mode for every project in settings. 
So, all string resources are unit in following total resources:
- current dictionary. It contains all phrases with translate for all projects. 
- actual dictionary. In result of scanning that collected all resources for all projects. They are actual on now. Some phrases are translated (they present the current dictionary) and another part is waiting to translate.
After translate, all new strings can be merged with actual resources and become as current. 


##User interface

Main window is presented as many documents interface and consists from tools pane and tab bar.
Every document window presented as table with context menu. Tools pane is repeat of the main menu.
Menu item 'Open strings' and 'Start scanning' are calculating and presenting of the string resources.
Menu item 'Open XIBs' and 'Start scanning XIBs' are calculating and presenting of the string resources from the XIBs. 
Menu item 'Total' presents total information about all string resources for all projects in one table.
Menu item 'Settings' are used for setting up all optional parameters. There are path to Xcode project, path to work folder and so on. 
Then menu item for showing readme file and menu item for setup of the tools pane.

##Data store

All data is kept in work directory. By default it is '~/Documents/LocalizableStrings'. 
It can be changed in settings. The work directory is divided on three. They are: '/strings', '/XIBs', '/XcodeProjects'. 
Every folder consists from project subdirectories by they name.
In result of scanning all string resources accumulate in the working directory. In main window, the user can see information view. By menu item, user can open information for researching.

##User guide

##Settings



## Implements

In Objective-C with MRR.

## Requirements

- Xcode 4 and later
- MacOS

## Author

Sergey Krotkih 
- http://sergey-krotkih.blogspot.com

## License

GenStringResources is available under the MIT license. See the LICENSE file for more info.

## Update

