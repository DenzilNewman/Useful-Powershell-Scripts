# Write-HostColourString
A simple function for writing multi-color strings to the console.
Only accepts strings as inputs

Written by Denzil Newman 13th February 2022


![write-hostcolorstring](https://user-images.githubusercontent.com/26501604/153769776-cf92e44e-610b-4c6e-8eae-b1a13ac573fb.png)


## Parameters
$Object - this is the input string, it is named object only for consistency with write-host, however only strings are accepted.
$NoNewLine - if switched on will not start a new line after finishing output
$Foreground - set the (default) foreground color (uses current console foreground if omited)
$Background - set the (default) background color (uses current console background if omited)

## Formatting
Formatting can be provided encapsulated within curly brackets in the format of
{[target:]format,...}

Multiple format statements seperated by a comma will be applied in order.  Target is optional, and defaults to * (auto).
    Targets available: * (auto), fg (foreground), bg (background)

Formatting available
    default - (auto target is foreground, and background).  Uses default color for target.
    inv - (auto target is foreground, and background).  Swaps foreground/background colors.  (Note: if fg or bg targetted, then colors will match making text unreadable)
    colours (red, green, blue etc)  - (auto target is foreground) sets the color to currently specified color

## Escape character
    / is the escape character, for outputting either a slash / or open curly bracket {
    For example "here is a // slash output, here is a /{ curly brace"

## Example usage:
  
````PowerShell
    Write-HostColourString "Here is some text, {inv}Inverted (black on white) {red}Red on white {inv}Inverted again (now white on red){default} and here is text in the default colors again!" -Foreground white -Background black
    
    Write-HostColourString "{green}MORE: " -NoNewLine
    
    Write-HostColourString "This is the default when not set {inv}inverted{inv}back {fg:blue,bg:white}and blue on white{default}." 
    
````
