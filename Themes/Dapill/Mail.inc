[Variables]
Mail_X=413
Mail_Storage=
Mail_LoggedIn=false

[Metadata]
Name=Papirus\\Mail
Author=reddit.com/u/khanhas
Description=Gmail only. Show number of unread mails. Click to show most recent mails.

[MailShape]
Meter=Shape
X=#Mail_X#
Y=(#Bar_OffsetY#+#Bar_Height#/2-#Section_Height#/2)
Shape=Rectangle 0,0,(#Section_Height#),(#Section_Height#),5 | StrokeWidth 0 | Extend Color
Color = Fill Color #Color_Scheme1#
DynamicVariables=1
MouseOverAction=[!WriteKeyValue Variables "Curr_X" "[MailXPos]" "#ROOTCONFIGPATH#Themes\#Theme#\Additional_Comps_And_Scripts\MailList.ini"][!WriteKeyValue Variables "Curr_Y" "[SubSkinYPositionCalc]" "#ROOTCONFIGPATH#Themes\#Theme#\Additional_Comps_And_Scripts\MailList.ini"][!WriteKeyValue Variables "Dir" "[SubSkinDirectionCalc]" "#ROOTCONFIGPATH#Themes\#Theme#\Additional_Comps_And_Scripts\MailList.ini"][!WriteKeyValue Variables "Mail_LoggedIn" "#Mail_LoggedIn#" "#ROOTCONFIGPATH#Themes\#Theme#\Additional_Comps_And_Scripts\MailList.ini"][!ActivateConfig "#ROOTCONFIG#\Themes\#Theme#\Additional_Comps_And_Scripts" "MailList.ini"][!CommandMeasure AdditionalSkinActionTimer "Stop 1"]
MouseLeaveAction=[!CommandMeasure AdditionalSkinActionTimer "Execute 1"]
LeftMouseUpAction=["https://mail.google.com/mail/u/#Mail_Form1#/#inbox/"]

[Mail_Script]
Measure=Script
ScriptFile=#ROOTCONFIGPATH#Themes\#Theme#\Additional_Comps_And_Scripts\script_Mail.lua

[Mail_Webparser]
Measure=Plugin
Plugin=WebParser
DynamicVariables=1
DecodeCharacterReference=1
Download=1
DownloadFile=gmailFeed.txt
UpdateRate=2
FinishAction=[!SetVariable Mail_LoggedIn true][!CommandMeasure Mail_Script GetMailFeed('module')]
OnDownloadErrorAction=
Disabled=1

[Mail_Avatar]
Measure=Plugin
PLugin=WebParser
URL=https://picasaweb.google.com/data/feed/api/user/#Mail_Form1#
RegExp=(?siU)<gphoto:thumbnail>(.*)</gphoto:thumbnail>
StringIndex=1
Download=1
DownloadFile=gmailAvatar.png

[MailIcon]
Meter=Image
ImageName=#ROOTCONFIGPATH#Themes\#Theme#\Additional_Comps_And_Scripts\Mail.png
W=(#Font_Size#*20/14)
X=(#Mail_X#+#Section_Height#/2-[MailIcon:W]/2)
Y=(#Bar_OffsetY#+#Bar_Height#/2-[MailIcon:H]/2)
SolidColor=0,0,0,1
DynamicVariables=1
AntiAlias=1

[Mail_UnreadBadgeShape]
Meter=Shape
Shape=Rectangle ([Mail_UnreadCountBadge:X]-3),[Mail_UnreadCountBadge:Y],([Mail_UnreadCountBadge:W]+6*sgn([Mail_UnreadCountBadge:W])),([Mail_UnreadCountBadge:H]+2*sgn([Mail_UnreadCountBadge:W])),2 | StrokeWidth 0 | Fill Color #Color_Scheme4#
DynamicVariables=1

[Mail_UnreadCountBadge]
Meter=String
MeasureName=MailNotice
FontFace=#Font_Face2#
FontSize=10
FontColor=#Color_Scheme2#
X=(#Mail_X#+#Section_Height#)
StringAlign=Center
Y=(#Bar_OffsetY#+#Bar_Height#/2-#Section_Height#/2-2)
AntiAlias=1
DynamicVariables=1

[MailNotice]
Measure=Calc
Formula=0
IfCondition=MailNotice > 0 
IfTrueAction=[!SetOption MailShape Color "Fill Color #Color_Scheme3#"][!ShowMeter Mail_UnreadCountBadge]
IfFalseAction=[!SetOption MailShape Color "Fill Color #Color_Scheme1#"][!HideMeter Mail_UnreadCountBadge]

[MailXPos]
Measure=Calc
Formula=#CURRENTCONFIGX#+[MailIcon:X]+[MailIcon:W]/2
DynamicVariables=1
