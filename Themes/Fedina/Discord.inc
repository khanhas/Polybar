[Variables]
Discord_X=708
;Left, Right or Center
Discord_Anchor = Left
Discord_Width=(#Font_Size#*4)

[Metadata]
Name=Paper\\Discord
Author=reddit.com/u/khanhas
Description=Click to show Discord status and control

[DiscordAnchor]
Measure=String
String = #Discord_Anchor#
IfMatch = Center|center|Middle|middle
IfMatchAction = [!SetOption DiscordShape X "(#Bar_OffsetX#+#*Discord_X*#-#Discord_Width#/2)"]
IfMatch2 = Right|right
IfMatchAction2 = [!SetOption DiscordShape X "(#Bar_OffsetX#+#*Discord_X*#-#Discord_Width#)"]

[DiscordShape]
Meter=Shape
X=(#Bar_OffsetX#+#Discord_X#)
Y=#Bar_OffsetY#
Shape=Rectangle 0,0,#Discord_Width#,#Bar_Height# | StrokeWidth 0 | Extend Color
Color = Fill Color [ColorMeasureScript:GetColor('#Color_Scheme3#', '#Color_Scheme4#', 'side to middle', #Discord_X#)]
DynamicVariables=1
MouseOverAction=[!CommandMeasure AdditionalSkinActionTimer "Stop 1"][!WriteKeyValue Variables "Curr_X" "[DiscordXPos]" "#ROOTCONFIGPATH#Themes\#Theme#\Additional_Comps_And_Scripts\DiscordStatus.ini"][!WriteKeyValue Variables "Curr_Y" "[SubSkinYPositionCalc]" "#ROOTCONFIGPATH#Themes\#Theme#\Additional_Comps_And_Scripts\DiscordStatus.ini"][!WriteKeyValue Variables "Dir" "[SubSkinDirectionCalc]" "#ROOTCONFIGPATH#Themes\#Theme#\Additional_Comps_And_Scripts\DiscordStatus.ini"][!ActivateConfig "#ROOTCONFIG#\Themes\#Theme#\Additional_Comps_And_Scripts" "DiscordStatus.ini"]
MouseLeaveAction=[!CommandMeasure AdditionalSkinActionTimer "Execute 1"]
LeftMouseUpAction=["%localappdata%\Discord\app-0.0.298\Discord.exe"]

[DiscordIcon]
Meter=Image
ImageName=#ROOTCONFIGPATH#Themes\#Theme#\Additional_Comps_And_Scripts\Discord.png
W=(#Font_Size#*18/14)
X=([DiscordShape:X] + [DiscordShape:W]/2-[DiscordIcon:W]/2)
Y=(#Bar_OffsetY#+#Bar_Height#/2-[DiscordIcon:H]/2)
SolidColor=0,0,0,1
DynamicVariables=1
AntiAlias=1

[DiscordNoticeShape]
Meter=Shape
Y=(#Bar_OffsetY#+#Bar_Height#/2)
Shape=Rectangle ([Discord_UnreadCountBadge:X]-3),(-[DiscordIcon:H]/4),([Discord_UnreadCountBadge:W]+6*sgn([Discord_UnreadCountBadge:W])),([Discord_UnreadCountBadge:H]),2 | StrokeWidth 0 | Fill Color #Color_Scheme5#
DynamicVariables=1

[Discord_UnreadCountBadge]
Meter=String
MeasureName=DiscordNotice
FontFace=#Font_Face#
FontSize=(#Font_Size#*12/14)
FontColor=#Color_Scheme2#
X=([DiscordShape:X] + [DiscordShape:W]/2+[DiscordIcon:W]/2)
StringAlign=Center
Y=(-[DiscordIcon:H]/4)r
AntiAlias=1
DynamicVariables=1

[DiscordScript]
Measure=Script
ScriptFile=#ROOTCONFIGPATH#Themes\#Theme#\Additional_Comps_And_Scripts\script_Discord.lua
JSONFile = %appdata%\BetterDiscord\plugins\DiscordForRainmeter.config.json

[DiscordNotice]
Measure=Calc
;GetNotification(guild,mention,dm)
Formula=[DiscordScript:GetNotification(true,true,true)]
IfCondition=DiscordNotice > 0 
IfTrueAction=[!SetOption DiscordIcon ImageTint "#Color_Scheme2#"][!ShowMeter Discord_UnreadCountBadge]
IfFalseAction=[!SetOption DiscordIcon ImageTint "#Color_Scheme4#"][!HideMeter Discord_UnreadCountBadge]
DynamicVariables=1

[DiscordXPos]
Measure=Calc
Formula=#CURRENTCONFIGX#+[DiscordIcon:X]+[DiscordIcon:W]/2
DynamicVariables=1
