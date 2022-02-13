<#
    Write-HostColourString

    Written by Denzil Newman 13th February 2022

    A simple function for writing multi-color strings to the console.
    Only accepts strings as inputs

    Parameters 
        $Object - this is the input string, it is named object only for consistency with write-host, however only strings are accepted.
        $NoNewLine - if switched on will not start a new line after finishing output
        $Foreground - set the (default) foreground color (uses current console foreground if omited)
        $Background - set the (default) background color (uses current console background if omited)

    Formatting
    Formatting can be provided encapsulated within curly brackets in the format of
    {[target:]format,...}

    Multiple format statements seperated by a comma will be applied in order.  Target is optional, and defaults to * (auto).
        Targets available: * (auto), fg (foreground), bg (background)

    Formatting available
        default - (auto target is foreground, and background).  Uses default color for target.
        inv - (auto target is foreground, and background).  Swaps foreground/background colors.  (Note: if fg or bg targetted, then colors will match making text unreadable)
        colours (red, green, blue etc)  - (auto target is foreground) sets the color to currently specified color

    Escape character
        / is the escape character, for outputting either a slash / or open curly bracket {
        For example "here is a // slash output, here is a /{ curly brace"

    Example usage:
    Write-HostColorString "Here is some text, {inv}Inverted (black on white) {red}Red on white {inv}Inverted again (now white on red){default} and here is text in the default colors again!" -Foreground white -Background black
    Write-HostColorString "{green}MORE: " -NoNewLine
    Write-HostColorString "This is the default when not set {inv}inverted{inv}back {fg:blue,bg:white}and blue on white{default}."        

#>
function Write-HostColorString
{
    Param
    (
         [String] $Object, #Only support strings currently
         [Switch] $NoNewLine = $false,
         [System.ConsoleColor] $Foreground,
         [System.ConsoleColor] $Background
    )   

    $i = 0
    $inFormatShift = 0
    $curChar = ""
    
    [System.ConsoleColor] $colDefaultFG = (get-host).ui.rawui.ForegroundColor
    [System.ConsoleColor] $colDefaultBG = (get-host).ui.rawui.BackgroundColor
    if ($null -ne $Foreground) {$colDefaultFG = $Foreground}
    if ($null -ne $Background) {$colDefaultBG = $Background}
    $curFG = $colDefaultFG
    $curBG = $colDefaultBG
    $bCount = 0
    $sEnd = 0


    while ($i -lt $Object.Length)
    {
        $prevChar = $curChar
        $curChar = $Object.Substring($i, 1)
        if (($curChar -eq "/") -and ($prevChar -eq "/")) { #so // means /, also we ignore as an escape char now
            #strip char
            $curChar = ""
            $Object = ($Object.Substring(0, $i))+(($Object.Substring($i+1)))
            $i = $i - 1;

        } elseif (($curChar -eq "{")) {
            if (("/" -eq $prevChar)) {
                $i = $i-1
                $Object = ($Object.Substring(0, $i)+$Object.Substring($i+1))
            } else {
                $bCount = $bCount + 1
                if ($bCount -eq 1) {
                    $sEnd = $i
                }
            }            
        } elseif (($curChar -eq "}") -and ($bCount -gt 0)) {
            $bCount = $bCount - 1
            if ($bCount -eq 0) {
                Write-Host $Object.Substring(0, $sEnd) -ForegroundColor $curFG -BackgroundColor $curBG -NoNewline
                $formatDef = $Object.Substring($sEnd+1,$i-($sEnd+1));
                #Write-Host $formatDef -ForegroundColor Green -NoNewline    
                $Object = $Object.Substring($i+1);
                $i=0            
            

                #Now parse formatting
                #$formatLines = $formatDef.Split(",")
                Foreach ($formatLine IN $formatDef.Split(","))
                {                   
                    $formatLine = $formatLine.ToLower()  
                    $tLoc = $formatLine.IndexOf(":")
                    if ($tLoc -gt -1) {
                        $target = $formatLine.Substring(0, $tLoc).Trim()
                        $formatLine = $formatLine.Substring(1+$tLoc).Trim()  
                        
                        if ($target -eq "auto") {$target = "*"}
                        elseif ($target -eq "foreground") {$target = "fg"}
                        elseif ($target -eq "background") {$target = "bg"}

                        
                    } else {
                        $target = "*"
                        $formatLine = $formatLine.Trim()
                    }

                    if (($formatLine -eq "negative") -or ($formatLine -eq "inverse") -or ($formatLine -eq "inv")) {
                        $x = $curFG
                        if (($target -eq "fg") -or ($target -eq "*")) {
                            $curFG = $curBG
                        }
                        if (($target -eq "bg") -or ($target -eq "*")) {
                            $curBG = $x
                        }
                    } elseif (($formatLine -eq "default") -or ($formatLine -eq "def")) {
                            if (($target -eq "fg") -or ($target -eq "*")) {
                                $curFG = $colDefaultFG
                            }
                            if (($target -eq "bg") -or ($target -eq "*")) {
                                $curBG = $colDefaultBG
                            }
    
                    } else {
                        if ($formatLine -eq "grey") {$formatLine = "gray"}
                        try {
                            if (($target -eq "fg") -or ($target -eq "*")) {
                                $curFG = $formatLine
                            }
                            if (($target -eq "bg")) {
                                $curBG = $formatLine
                            }
                        } catch {

                        }
                    }
                }
            }            
        }
        $i++
    }

    Write-Host $Object -ForegroundColor $curFG -BackgroundColor $curBG -NoNewline:($NoNewLine)
}

Set-Alias -Name Write-HostColourString -Value Write-HostColorString #For us brits

#####################

Clear-Host


Write-HostColourString "Here is an example:"
Write-HostColourString "    {darkblue}Write-HostColorString {blue}""here is some /{red}red text"" "
Write-HostColourString "Output:"
Write-HostColourString "    here is some {red}red text"
Write-Host ""
Write-HostColourString "To output a slash (/), to be safe you should double them ////, because a double slash will only output one slash and a to output a open curly bracket it must be escaped ///{ "
Write-HostColourString "This message for example would error {red}""** /{more text} **""{def}, but this would not {green}""** ///{more text} **""{def}"