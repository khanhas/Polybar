//META{"name":"DiscordForRainmeter"}*//

var DiscordForRainmeter = function () {};
//You can set this higher if you want
var MaximumDmUserReturn = 2

unmutedIcon = "background-image: url(\"/assets/4bc527c257233fc69b94342d77bcb9ee.svg\");"
undeafedIcon = "background-image: url(\"/assets/c7c47afdf35d5a3e06233319d3aa7674.svg\");"

DiscordForRainmeter.prototype.start = function () {
	updater = setInterval(this.countAgain, 200);
};

DiscordForRainmeter.prototype.countAgain = function() {
	function saveValue(k,v) {
		bdPluginStorage.set("DiscordForRainmeter", k, v)
	}

	//Get user name by finding user id in available channel member list or private chat list
	function getUserNameByID(id){
		var userList = document.getElementsByClassName("channel-members")
		if (userList.length > 0) {
			userList = userList[0].getElementsByClassName("member")
			for (var i = 0; i < userList.length; i++) {
				var user = $(userList[i].getElementsByClassName("avatar-small"))
				var url = user.css("background-image")

				if (id[0] == url.match(/\d+/)[0])
					return userList[i].getElementsByClassName("member-username-inner")[0].innerText
			}
		}
		else {
			userList = document.getElementsByClassName("private-channels")[0].getElementsByClassName("channel private")
			for (var i = 0; i < userList.length; i++) {
				var user = userList[i].getElementsByClassName("avatar-small")
				var url = user[0].style['backgroundImage']
				if (id[0] == url.match(/\d+/)[0]) {
					var nameFull = userList[i].getElementsByClassName("channel-name")[0].innerText
					var namePlaying = userList[i].getElementsByClassName("channel-activity")[0]
					if (namePlaying) {
						return nameFull.replace(namePlaying.innerText,"")
					}
					else {
						return nameFull
					}
				}
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
	saveValue("Guild_Unread", count)
//MENTION COUNT
	//Current channel
	mention = 0
	curr_channel = document.getElementsByClassName('iconSpacing-5GIHkT')
	if (curr_channel.length > 0) {
		for (i = 0; i < curr_channel.length; i++) {
			if (curr_channel[i].innerText != "") {
				mention = mention + parseInt(curr_channel[i].innerText)
			}
		}
	}

	guild = document.getElementsByClassName('guild')
	for (i = 0; i < guild.length; i++) {
		if (guild[i].parentElement.className != 'dms') {
			badge = guild[i].getElementsByClassName('badge')
			if (badge.length > 0) {
				mention = mention + parseInt(badge[0].innerText)
			}
		}
	}
	saveValue("Guild_Mention", mention)
//DIREC MESSAGES COUNT, AVATAR AND NAME
	dms = document.getElementsByClassName("dms")[0].getElementsByClassName("guild")

	TotalDM = 0
	for (i = 0; i < MaximumDmUserReturn; i++){
		TotalDM = TotalDM + getUserDmAva(i)
	}
	saveValue("Direct_Message", TotalDM)

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
	toggleButton = document.getElementsByClassName("iconButtonDefault-2cKx7- iconButton-3V4WS5 button-2b6hmh small--aHOfS")

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

//SPEAKING STATUS
	userAvaLink = document.getElementsByClassName("container-2Thooq")[0].firstChild.getAttribute("style")
	talkingList = document.getElementsByClassName("draggable-1KoBzC")
	for (i = 0; i < talkingList.length; i++)
	{
		checkingAva = talkingList[i].firstChild.firstChild.firstChild
		if (checkingAva.getAttribute("style") == userAvaLink)
		{
			if (checkingAva.className == "avatarSpeaking-1wJCNq")
				saveValue("Speaking", 1)
			else
				saveValue("Speaking", 0)

			break
		}
	}

//KEYBIND COMBINATION
//(Only return current combinations when user open "Keybind" in Setting menu. If Keybind setting is not visible, it will just skip but old values are still saved)
	keybindList = document.getElementsByClassName("keybindGroup-JQs9x_")
	if (keybindList.length > 0) {
		for (i = 0; i < keybindList.length; i++){
			selectedValue = keybindList[i].getElementsByClassName("Select-value-label")[0].innerHTML

			if (selectedValue == "Toggle Mute") {

				hotkey = keybindList[i].getElementsByClassName("input-1G2o7i")[0].getAttribute("value")
				saveValue("Toggle_Mute_Keybind", hotkey)
			}
			else if (selectedValue == "Toggle Deafen") {
				hotkey = keybindList[i].getElementsByClassName("input-1G2o7i")[0].getAttribute("value")
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
	return "1.2";
};

DiscordForRainmeter.prototype.getAuthor = function () {
	return "\/r\/khanhas";
};
