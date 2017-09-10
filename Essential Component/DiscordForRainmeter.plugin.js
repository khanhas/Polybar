//META{"name":"DiscordForRainmeter"}*//

var DiscordForRainmeter = function () {};
//You can set this higher if you want
var MaximumDmUserReturn = 2

unmutedIcon = "background-image: url(\"data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0Ij4KICA8ZyBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPgogICAgPHJlY3Qgd2lkdGg9IjI0IiBoZWlnaHQ9IjI0Ii8+CiAgICA8cGF0aCBmaWxsPSIjRkZGRkZGIiBkPSJNNyw0LjQ0MDg5MjFlLTE2IEM4LjY1Njg1NDI1LDAgMTAsMS4zNDMxNDU3NSAxMCwzIEwxMCw5IEMxMCwxMC42NTY4NTQyIDguNjU2ODU0MjUsMTIgNywxMiBDNS4zNDMxNDU3NSwxMiA0LDEwLjY1Njg1NDIgNCw5IEw0LDMgQzQsMS4zNDMxNDU3NSA1LjM0MzE0NTc1LDQuNDQwODkyMWUtMTYgNywwIEw3LDQuNDQwODkyMWUtMTYgWiBNMTQsOSBDMTQsMTIuNTMgMTEuMzksMTUuNDQgOCwxNS45MyBMOCwxOSBMNiwxOSBMNiwxNS45MyBDMi42MSwxNS40NCAwLDEyLjUzIDAsOSBMMiw5IEMyLDExLjc2MTQyMzcgNC4yMzg1NzYyNSwxNCA3LDE0IEM5Ljc2MTQyMzc1LDE0IDEyLDExLjc2MTQyMzcgMTIsOSBMMTQsOSBMMTQsOSBaIiB0cmFuc2Zvcm09InRyYW5zbGF0ZSg1IDMpIi8+CiAgPC9nPgo8L3N2Zz4K\");"
undeafedIcon = "background-image: url(\"data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0Ij4KICA8ZyBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPgogICAgPHJlY3Qgd2lkdGg9IjI0IiBoZWlnaHQ9IjI0Ii8+CiAgICA8cGF0aCBmaWxsPSIjRkZGRkZGIiBkPSJNMywxMSBDMyw2IDcsMiAxMiwyIEwxMiw0IEM4LjEzNDAwNjc1LDQgNSw3LjEzNDAwNjc1IDUsMTEgTDUsMTMgTDksMTMgTDksMjEgTDYsMjEgQzQuMzQzMTQ1NzUsMjEgMywxOS42NTY4NTQyIDMsMTggTDMsMTEgWiBNMjEsMTEgTDIxLDE4IEMyMSwxOS42NTY4NTQyIDE5LjY1Njg1NDIsMjEgMTgsMjEgTDE1LDIxIEwxNSwxMyBMMTksMTMgTDE5LDExIEMxOSw3LjEzNDAwNjc1IDE1Ljg2NTk5MzIsNCAxMiw0IEwxMiwyIEMxNywyIDIxLDYgMjEsMTEgWiIvPgogIDwvZz4KPC9zdmc+Cg==\");"

DiscordForRainmeter.prototype.start = function () {
	updater = setInterval(this.countAgain, 200);
};

DiscordForRainmeter.prototype.countAgain = function() {
	function saveValue(k,v) {
		bdPluginStorage.set("DiscordForRainmeter", k, v)
	}

	//Get user name by finding user id in available channel member list or private chat list
	function getUserNameByID(id){
		var users = document.getElementsByClassName("channel-members")[0]
		if (users){
			users = users.getElementsByClassName("member")
			for (var i = 0; i < users.length; i++) {
				var user = $(users[i].getElementsByClassName("avatar-small"))
				var url = user.css("background-image")

				if (id[0] == url.match(/\d+/)[0])
					return users[i].getElementsByClassName("member-username-inner")[0].innerText
			}
		}
		else{
			users = document.getElementsByClassName("private-channels")[0].getElementsByClassName("channel private")
			console.log(users)
			for (var i = 0; i < users.length; i++) {
				var user = $(users[i].getElementsByClassName("avatar-small"))
				var url = user.css("background-image")
				if (id == url.match(/\d+/))
					return users[i].getElementsByClassName("channel-name")[0].innerText.replace(users[i].getElementsByClassName("channel-activity")[0].innerText,"")	
			}
		}
			
		return ""
	}

	function getUserDmAva(userIndex){
		user = dms[userIndex]
		if (user) {
			//Direct messages count from `badge`
			badge = user.getElementsByClassName("badge")[0]
			if (badge)
				dmCount = parseInt(badge.innerHTML)
			else
				dmCount = 0
	
			avaClass = $(user.getElementsByClassName("avatar-small"))

			avaLink = avaClass.css("background-image").match(/\"(.*)\"/)[1]

			//Attempt to get user name
			userID = avaLink.match(/\d+/)
			if (userID)
				userName = getUserNameByID(userID)
			else
				userName = ""
		}
		else{
			dmCount = 0
			avaLink = userName = ""
		}

		saveValue("User_" + userIndex + "_DMCount", dmCount)
		saveValue("User_" + userIndex + "_AvatarLink", avaLink)
		saveValue("User_" + userIndex + "_Name", userName)

		return dmCount
	}

//UNREAD GUILDS
	count = document.getElementsByClassName("guild unread").length
	saveValue("Total_GuildUnread", count)

//DIREC MESSAGES COUNT, AVATAR AND NAME
	dms = document.getElementsByClassName("dms")[0].getElementsByClassName("guild")

	TotalDM = 0
	for (i = 0; i < MaximumDmUserReturn; i++){
		TotalDM = TotalDM + getUserDmAva(i)
	}
	saveValue("Total_DMCount", TotalDM)

//FRIENDS ONLINE
	friendOnl = parseInt(document.getElementsByClassName("friends-online")[0].innerHTML.replace("Online",""))
	saveValue("Friend_Online", friendOnl)

//VOICE CHAT STATUS
	voiceConnected = document.getElementsByClassName("inner-ptMwR-")[0]
	if (voiceConnected){
		voiceState = $(voiceConnected.getElementsByTagName("div")[0]).attr('class')

		voiceStatus = voiceState.match(/status\-(\w+)/)[1]
		voiceQuality = voiceState.match(/quality\-(\w+)/)[1]

		voiceChannel = voiceConnected.getElementsByClassName("channel-3YGMy1")[0].innerHTML
	}
	else{
		voiceStatus = ""
		voiceQuality = ""
		voiceChannel = ""
	}

	saveValue("Voice_Status", voiceStatus)
	saveValue("Voice_Quality", voiceQuality)
	saveValue("Voice_Channel", voiceChannel)

//MICROPHONE AND HEADPHONE STATUS
	toggleButton = document.getElementsByClassName("iconButtonDefault-3QZh-A iconButton-3mKjyp button-1aU9q1 small-1ChI_f")

	microphoneButton = toggleButton[0].getAttribute("style")
	if (microphoneButton == unmutedIcon)
		microphoneButton = "Unmuted"
	else
		microphoneButton = "Muted"
	saveValue("Microphone", microphoneButton)

	headphoneButton = toggleButton[1].getAttribute("style")
	if (headphoneButton == undeafedIcon)
		headphoneButton = "Undeafed"
	else
		headphoneButton = "Deafed"
	saveValue("Headphone", headphoneButton)

//KEYBIND COMBINATION 
//(Only return current combinations when user open "Keybind" in Setting menu. If Keybind setting is not visible, it will just skip but old values are still saved)
	keybindList = document.getElementsByClassName("keybind-group")
	if (keybindList) {
		for (i = 0; i < keybindList.length; i++){
			selectedValue = keybindList[i].getElementsByClassName("Select-value-label")[0].innerHTML
			if (selectedValue == "Toggle Mute") {
				hotkey = keybindList[i].getElementsByClassName("input")[0].getAttribute("value")
				saveValue("Toggle_Mute_Keybind", hotkey)
			}
			else if (selectedValue == "Toggle Deafen") {
				hotkey = keybindList[i].getElementsByClassName("input")[0].getAttribute("value")
				saveValue("Toggle_Deaf_Keybind", hotkey)
			}
		}
	}
};

DiscordForRainmeter.prototype.load = function () {};

DiscordForRainmeter.prototype.unload = function () {
	clearInterval(updater);
};

DiscordForRainmeter.prototype.stop = function () {};

DiscordForRainmeter.prototype.onMessage = function () {
};

DiscordForRainmeter.prototype.onSwitch = function () {
};

DiscordForRainmeter.prototype.observer = function (e) {};

DiscordForRainmeter.prototype.getSettingsPanel = function () { return ""; };

DiscordForRainmeter.prototype.getName = function () {
	return "DiscordForRainmeter";
};

DiscordForRainmeter.prototype.getDescription = function () {
	return "Get information and write them in JSON file.";
};

DiscordForRainmeter.prototype.getVersion = function () {
	return "1.0";
};

DiscordForRainmeter.prototype.getAuthor = function () {
	return "\/r\/khanhas";
};