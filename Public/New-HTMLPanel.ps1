Function New-HTMLPanel {
    [alias('New-HTMLColumn', 'Panel')]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)][ValidateNotNull()][ScriptBlock] $Content = $(Throw "Open curly brace with Content"),
        [alias('BackgroundShade')][string]$BackgroundColor,
        [switch] $Invisible,
        [alias('flex-basis')][string] $Width,
        [string] $Margin,
        [System.Collections.IDictionary] $StyleSheetsConfiguration
    )
    # This is so we can support external CSS configuration
    if (-not $StyleSheetsConfiguration) {
        $StyleSheetsConfiguration = [ordered] @{
            Panel = "defaultPanel"
        }
    }
    if ($BackgroundColor) {
        $BackGroundColorFromRGB = ConvertFrom-Color -Color $BackgroundColor
        $DivColumnStyle = "background-color:$BackGroundColorFromRGB;"
    } else {
        $DivColumnStyle = ""
    }
    if ($Invisible) {
        $DivColumnStyle = "$DivColumnStyle box-shadow: unset !important;"
    }

    if ($Width -or $Margin) {
        [string] $ClassName = "flexPanel$(Get-RandomStringName -Size 8 -LettersOnly)"
        $Attributes = @{
            'flex-basis' = if ($Width) { $Width } else { '100%' }
            'margin'     = if ($Margin) { $Margin }
        }
        $Css = ConvertTo-LimitedCSS -ClassName $ClassName -Attributes $Attributes

        $Script:HTMLSchema.CustomHeaderCSS.Add($Css)
        [string] $Class = "$ClassName overflowHidden"
    } else {
        [string] $Class = 'flexPanel overflowHidden'
    }
    New-HTMLTag -Tag 'div' -Attributes @{ class = "$Class $($StyleSheetsConfiguration.Panel) overflowHidden"; style = $DivColumnStyle } {
        Invoke-Command -ScriptBlock $Content
    }
}

Register-ArgumentCompleter -CommandName New-HTMLPanel -ParameterName BackgroundColor -ScriptBlock $Script:ScriptBlockColors