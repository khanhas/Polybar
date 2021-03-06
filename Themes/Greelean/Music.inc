[Variables]
Music_X =996
;Left, Right or Center
Music_Anchor=right
Music_Width = 300
Music_Current_Player=Spotify
Music_NowPlaying_Player=Itunes

[Metadata]
Name=Greenlean\\Music
Author=reddit.com/u/khanhas
Description=Display song name and artist. Click at music note icon to next. Click at text to play/pause. Right click at text to activate Music Control to show track progress, player changer.

[MusicAnchor]
Measure=String
String = #Music_Anchor#
IfMatch = Center|center|Middle|middle
IfMatchAction = [!SetOption MusicIcon X "(#Bar_OffsetX#+#*Music_X*#-([*MusicIcon:W*]+[*MusicTrackTitle:W*]+5)/2)"][!SetOption MusicTrackTitle X 5R]
IfMatch2 = Right|right
IfMatchAction2 = [!SetOption MusicTrackTitle StringAlign RightCenter][!SetOption MusicIcon X "([*MusicTrackTitle:X*]-[*MusicIcon:W*]-5)"][!SetOption MusicTrackTitle X "(#Bar_OffsetX#+#*Music_X*#)"]

[MusicChooseMeasure]
Measure=String
String=#music_Current_Player#
DynamicVariables=1
IfMatch=(?i)webnowplaying
IfMatchAction=[!EnableMeasureGroup WebNowPlaying]
IfMatch2=(?i)spotify
IfMatchAction2=[!EnableMeasureGroup Spotify]
IfMatch3=(?i)(?<!(web))nowplaying
IfMatchAction3=[!EnableMeasureGroup NowPlaying]
IfMatch4=(?i)gpmdp
IfMatchAction4=[!EnableMeasureGroup GPMDP]

;-------WEBNOWPLAYING-------
[WebNowPlayingTrack]
Measure=Plugin
Plugin=WebNowPlaying
PlayerType=Title
Substitute="":"N/A"
OnChangeAction=[!UpdateMeter MusicTrackTitle][!UpdateMeter MusicIcon][!Redraw]
Disabled=1
Group=WebNowPlaying

[WebNowPlayingArtist]
Measure=Plugin
Plugin=WebNowPlaying
PlayerType=Artist
Substitute="":"N/A"
Disabled=1
Group=WebNowPlaying

[WebNowPlayingControl]
Measure=Plugin
Plugin=WebNowPlaying
PlayerType=State
Disabled=1
Group=WebNowPlaying

;-------SPOTIFY-------
[SpotifyTrack]
Measure=Plugin
Plugin=SpotifyPlugin.dll
Type=TrackName
Substitute="":"N/A"
OnChangeAction=[!UpdateMeter MusicTrackTitle][!UpdateMeter MusicIcon][!Redraw]
Disabled=1
Group=Spotify

[SpotifyArtist]
Measure=Plugin
Plugin=SpotifyPlugin.dll
Type=ArtistName
Substitute="":"N/A"
Disabled=1
Group=Spotify

[SpotifyControl]
Measure=Plugin
Plugin=NowPlaying
PlayerName=Spotify
PlayerType=Artist
Disabled=1
Group=Spotify

;-------GPMDP-------------
[GPMDPTrack]
Measure=Plugin
Plugin=GPMDPPlugin
PlayerInfo=Title
Substitute="":"N/A"
OnChangeAction=[!UpdateMeter MusicTrackTitle][!UpdateMeter MusicIcon][!Redraw]
Disabled=1
Group=GPMDP

[GPMDPArtist]
Measure=Plugin
Plugin=GPMDPPlugin
PlayerInfo=Artist
Substitute="":"N/A"
Disabled=1
Group=GPMDP

[GPMDPControl]
Measure=Plugin
Plugin=GPMDPPlugin
PlayerInfo=State
Disabled=1
Group=GPMDP
;-------NOWPLAYING-------
[NowPlayingTrack]
Measure=Plugin
Plugin=NowPlaying
PlayerName=#music_NowPlaying_Player#
PlayerType=Title
Substitute="":"N/A"
OnChangeAction=[!UpdateMeter MusicTrackTitle][!UpdateMeter MusicIcon][!Redraw]
Disabled=1
Group=NowPlaying

[NowPlayingArtist]
Measure=Plugin
Plugin=NowPlaying
PlayerName=#music_NowPlaying_Player#
PlayerType=Artist
Substitute="":"N/A"
Disabled=1
Group=NowPlaying

[NowPlayingControl]
Measure=Plugin
Plugin=NowPlaying
PlayerName=#music_NowPlaying_Player#
PlayerType=State
Disabled=1
Group=NowPlaying

[MusicIcon]
Meter=String
FontFace=Material Icons
FontSize=(#Font_Size#*16/13)
FontColor=#Color_Scheme2#c0
SolidColor=0,0,0,1
AntiAlias=1
StringAlign=LeftCenter
Text=
X=(#Bar_OffsetX#+#music_X#)
Y=(#Bar_OffsetY#+#Bar_Height#/2)
StringAlign=LeftCenter
MouseOverAction=[!SetOption #CURRENTSECTION# Text ""][!UpdateMeter #CURRENTSECTION#][!Redraw]
MouseLeaveAction=[!SetOption #CURRENTSECTION# Text ""][!UpdateMeter #CURRENTSECTION#][!Redraw]
LeftMouseUpAction=[!CommandMeasure #music_Current_Player#Control "Next"]
DynamicVariables=1

[MusicTrackTitle]
Meter=String
MeasureName=#music_Current_Player#Track
MeasureName2=#music_Current_Player#Artist
Text=%1 - %2
FontFace=#Font_Face#
FontSize=#Font_Size#
SolidColor=0,0,0,1
AntiAlias=1
StringAlign=LeftCenter
FontColor=#Color_Scheme2#
ClipString=2
ClipStringW=#music_Width#
ClipStringH=40
X=5R
Y=(#Bar_OffsetY#+#Bar_Height#/2)
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure #music_Current_Player#Control "PlayPause"]
RightMouseUpAction=[!WriteKeyValue Variables MusicControl_Current_Player #music_Current_Player# "#ROOTCONFIGPATH#Themes\#Theme#\Additional_Comps_And_Scripts\MusicControl.ini"][!WriteKeyValue Variables MusicControl_NowPlaying_Player #music_NowPlaying_Player# "#ROOTCONFIGPATH#Themes\#Theme#\Additional_Comps_And_Scripts\MusicControl.ini"][!WriteKeyValue Variables Curr_X ([MusicIcon:X]+([MusicIcon:W]+[MusicTrackTitle:W]+10)/2+#CURRENTCONFIGX#) "#ROOTCONFIGPATH#Themes\#Theme#\Additional_Comps_And_Scripts\MusicControl.ini"][!WriteKeyValue Variables Curr_Y [SubSkinYPositionCalc] "#ROOTCONFIGPATH#Themes\#Theme#\Additional_Comps_And_Scripts\MusicControl.ini"][!WriteKeyValue Variables Dir [SubSkinDirectionCalc] "#ROOTCONFIGPATH#\Themes\#Theme#\Additional_Comps_And_Scripts\MusicControl.ini"][!ActivateConfig "#ROOTCONFIG#\Themes\#Theme#\Additional_Comps_And_Scripts" "MusicControl.ini"]
