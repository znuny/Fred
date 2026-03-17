# Functionality

## ConfigLog
Lists all ConfigGet requests, indicating their frequency.

## ConfigSwitch
Change simple SysConfig settings directly in the Fred.

## HTMLCheck
Performs different bad/best practice checks on the generated pages via JavaScript.

## JSLint

Examines the code quality of all JavaScript code that is used on the page on the fly (also via JavaScript), using the great tool JSLint.

## STDERRLog
Every entry contained in STDERR is displayed.

## SQLLog
Lists all SQL statements of the current request.

## TranslationLog
Displays all translation attempts of the current request which failed.

## SessionLog
Shows the current content of the serverside session.

## EnvLog
Shows info about the environment of the layout object.

# Installation
The following instructions explain how to install the package.

## Admin Interface

Please use the following URL to install the package utilizing the admin
interface (please note that you need to be in the admin group).

<ulink url="http://localhost/otrs/index.pl?Action=AdminPackageManager">http://localhost/otrs/index.pl?Action=AdminPackageManager</ulink>

## Command Line

If you don't want to use the Admin Interface, you can use the following
OPM command to install the package with "bin/opm.pl".

```
shell> bin/opm.pl -a install -p /path/to/$Name-$Version.opm
```

# Configuration
The following config options can or need to be changed via SysConfig.

## Fred###Module###ConfigLog###OrderBy
Which order should the config log data have?