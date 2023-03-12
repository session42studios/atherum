
--| Variables |--
local Config = require(game:GetService('ServerScriptService'):WaitForChild('Atherum Anti-Alt', 2):WaitForChild('Settings', 2))
local HttpService = game:GetService('HttpService')
local RunService = game:GetService('RunService')
local Players = game:GetService("Players")
local GroupService = game:GetService("GroupService")
local ServerID = game.JobId
local DataStoreService = game:GetService('DataStoreService')
if RunService:IsStudio() then
	ServerID = "0000-0000-0000-0000"
end
_G.AtherumUsersList = {}


--| Check permissions |--
local CheckHttpEnabled = pcall(function()
	game:GetService("HttpService"):RequestAsync({Url = "https://example.com", Method = "GET"})
end)
if CheckHttpEnabled == false then
	warn("[!] ATHERUM: Atherum cannot load because HTTP requests are disabled or unoperational. Please re-check your game settings. Error code: 403.")
	return
end


--| Functions |--
local function logUnexpectedError(Error, ErrorCode)
	if ErrorCode == nil then
		ErrorCode = "Unknown"
	end
	if Error == nil then
		Error = "We couldn't find the error for you :/"
	end
	if Config["Error logging"].Enabled == true then
		local URL = Config["Error logging"]["Discord webhook URL"]
		local Success, Error = pcall(function()
			local ReportData = {
				["username"] = "Atherum Error Monitor";
				["content"] = "<:hard_error:1000827183771689000>**| Unknown error occured in an Atherum context** \n ``` \n"..tostring(Error).." \n ``` \n *Error code: "..tostring(ErrorCode).."*";
			}
			ReportData = HttpService:JSONEncode(ReportData)
			HttpService:PostAsync(URL, ReportData)
		end)
		if not Success then
			print("[!] ATHERUM: Atherum couldn't post the information to Discord. Error: ".. Error)
		end
	end
end

local function logExpectedError(Error, ErrorCode)
	if ErrorCode == nil then
		ErrorCode = "Unknown"
	end
	if Error == nil then
		Error = "We couldn't find the error for you :/"
	end
	if Config["Error logging"].Enabled == true then
		local URL = Config["Error logging"]["Discord webhook URL"]
		local Success, Error = pcall(function()
			local ReportData = {
				["username"] = "Atherum Error Monitor";
				["content"] = "<:soft_error:1000826879919542446>**| Expected error occured in an Atherum context** \n ``` \n"..tostring(Error).." \n ``` \n *Error code: "..tostring(ErrorCode).."*";
			}
			ReportData = HttpService:JSONEncode(ReportData)
			HttpService:PostAsync(URL, ReportData)
		end)
		if not Success then
			print("[!] ATHERUM: Atherum couldn't post the information to Discord. Error: ".. Error)
		end
	end
end

local function logInfoStack(Error)
	if Error == nil then
		Error = "We couldn't find the stack for you :/"
	end
	if Config["Error logging"].Enabled == true then
		local URL = Config["Error logging"]["Discord webhook URL"]
		local Success, Error = pcall(function()
			local ReportData = {
				["username"] = "Atherum Error Monitor";
				["content"] = "<:purple_info:987995240214441995>**| Callstack occured in an Atherum context** \n``` \n"..tostring(Error).." \n ``` \n";
			}
			ReportData = HttpService:JSONEncode(ReportData)
			HttpService:PostAsync(URL, ReportData)
		end)
		if not Success then
			print("[!] ATHERUM: Atherum couldn't post the information to Discord. Error: ".. Error)
		end
	end
end

local function postModerationAction(Username, UserID, Action)
	if Config["Moderation logging"].Enabled == true then
		local URL = Config["Moderation logging"]["Discord webhook URL"]
		if Username == nil then
			warn("[!] ATHERUM: Couldn't log moderation action because the requested username was nil. Error code: 404")
			return	
		end
		if UserID == nil then
			warn("[!] ATHERUM: Couldn't log moderation action because the requested user ID was nil. Error code: 404")
			return	
		end
		if Action == nil then
			warn("[!] ATHERUM: Couldn't log moderation action because the requested action value was nil. Error code: 404")
			return	
		end
		local EmbedData = {
			["username"] = "Atherum Anti-Alt",
			["avatar_url"] = "https://cdn.discordapp.com/attachments/897089045316919347/984857544960933908/atherum_logo.png?width=442&height=442",
			["content"] = "",
			["embeds"] = {{
				["title"] = "Player moderated",
				["description"] = "An account was detected as an alt and was moderated according to the system settings. The details are listed below. Experience: **"..tostring(game.Name).." ("..tostring(game.GameId)..")**.",
				["color"] = 13648267,
				["fields"] = {
					{
						["name"] = "Suspect username",
						["value"] = Username,
						["inline"] = false
					},
					{
						["name"] = "Suspect user ID",
						["value"] = tostring(UserID),
						["inline"] = false
					},
					{
						["name"] = "Action taken",
						["value"] = tostring(Action),
						["inline"] = false
					}
				},
				["thumbnail"] = {
					["url"] = "https://cdn.discordapp.com/attachments/897089045316919347/984857544960933908/atherum_logo.png?width=442&height=442"
				}
			}}
		}
		EmbedData = HttpService:JSONEncode(EmbedData)
		local Success, Error = pcall(function()
			HttpService:PostAsync(URL, EmbedData)
		end)
		if not Success then
			warn("[!] ATHERUM: Couldn't post moderation log to Discord. Error: "..Error..". Error code: 503")
			return
		end
	end	
end

local function postDetection(Username, UserID, Score)
	if Config["Detection logging"].Enabled == true then
		local URL = Config["Detection logging"]["Discord webhook URL"]
		if Username == nil then
			warn("[!] ATHERUM: Couldn't log detection because the requested username was nil. Error code: 404")
			return	
		end
		if UserID == nil then
			warn("[!] ATHERUM: Couldn't log detection because the requested user ID was nil. Error code: 404")
			return	
		end
		if Score == nil then
			warn("[!] ATHERUM: Couldn't log detection because the requested score was nil. Error code: 404")
			return	
		end
		local EmbedData = {
			["username"] = "Atherum Anti-Alt";
			["avatar_url"] = "https://cdn.discordapp.com/attachments/897089045316919347/984857544960933908/atherum_logo.png";
			["content"] = "";
			["embeds"] = {{
				["title"] = "Alternate account detected";
				["description"] = "We have detected a player that is above the minimum fraud score. Details are below. Experience: **"..tostring(game.Name).." ("..tostring(game.GameId)..")**.";
				["type"] = "rich";
				["tts"] = false;
				["color"] = 13648267;
				["thumbnail"] = {
					["url"] = "https://cdn.discordapp.com/attachments/897089045316919347/984857544960933908/atherum_logo.png";
				};
				["footer"] = {
					["text"] = "· ATHERUM";
					["icon_url"] = "https://cdn.discordapp.com/attachments/897089045316919347/984857544960933908/atherum_logo.png"; -- The image icon you want your footer to have
				};
				["timestamp"] = DateTime.now():ToIsoDate();
				["fields"] = {
					{
						["name"] = "Suspect username";
						["value"] = Username;
						["inline"] = true;
					};
					{
						["name"] = "Suspect user ID";
						["value"] = tostring(UserID);
						["inline"] = true;
					};
					{
						["name"] = "Server ID";
						["value"] = ServerID;
						["inline"] = false;
					},
					{
						["name"] = "Score";
						["value"] = tostring(Score);
						["inline"] = false;
					}
				};
			};};
		}
		EmbedData = HttpService:JSONEncode(EmbedData)
		local Success, Error = pcall(function()
			HttpService:PostAsync(URL, EmbedData)
		end)
		if not Success then
			print(EmbedData)
			warn("[!] ATHERUM: Couldn't post detection log to Discord. Error: "..Error..". Error code: 503")
			return
		end
	end	
end

local function punishAlt(player)
	if Config["Audtomatic kicking"].Enabled == true then
		if Config["Audtomatic kicking"].Method["Blueberry System"].Enabled == true then
			local Success, Error = pcall(function()
				local BluberryAPI = require(Config["Audtomatic kicking"].Method["Blueberry System"]["Path to Blueberry API module"])
				BluberryAPI:kick(player.Name, Config["Audtomatic kicking"]["Custom kick message"], "Atherum Anti-Alt")
				postModerationAction(player.Name, player.UserId, "Blueberry")
			end)
			if not Success then
				warn("[!] ATHERUM: Error while trying to moderate "..player.Name..". Error: "..Error.." Error code: 503.")
				player:Kick(tostring(Config["Audtomatic kicking"]["Custom kick message"]).." ~ Atherum")
				postModerationAction(player.Name, player.UserId, "Kick (Blueberry error)")
			end
		end
		if Config["Audtomatic kicking"].Method.Kicking.Enabled == true then
			player:Kick(tostring(Config["Audtomatic kicking"]["Custom kick message"]).." ~ Atherum")
			postModerationAction(player.Name, player.UserId, "Kick")
		end
	end
end

local function updateData()
	if Config["Enable DataStore"] == true then
		local Key = Config["DataStore key"]
		local DataStore = DataStoreService:GetDataStore(ServerID)
		local SavedData
		local GetSuccess, GetError = pcall(function()
			SavedData = DataStore:GetAsync(Key)
		end)
		if not GetSuccess then
			warn("[!] ATHERUM: Error while getting datastore. Error: "..GetError..". Error code: 500")
		end
		local UploadSuccess, UploadError = pcall(function()
			DataStore:SetAsync(Key, _G.AtherumUsersList)
		end)
		if not UploadSuccess then
			warn("[!] ATHERUM: Error while getting datastore. Error: "..UploadError..". Error code: 500")
			return
		end
		print("[>] ATHERUM: Player data added to datastore.")
	end
end


--| Detection |--
game:GetService('Players').PlayerAdded:Connect(function(player)
	local ChecksPassed = 0
	local PlayerIsAlt = false
	local Checks = {
		[1] = {
			['Name'] = 'Age',
			['Passed'] = false,
			['Importance'] = Config["Main checks"].Age.Importance,	
		},
		[2] = {
			['Name'] = 'Friends',
			['Passed'] = false,
			['Importance'] = Config["Main checks"].Friends.Importance,	
		},
		[3] = {
			['Name'] = 'Groups',
			['Passed'] = false,
			['Importance'] = Config["Main checks"].Groups.Importance,	
		},
		[4] = {
			['Name'] = 'Badges',
			['Passed'] = false,
			['Importance'] = Config["Main checks"].Badges.Importance,
		},
		[5] = {
			['Name'] = 'Email',
			['Passed'] = false,
			['Importance'] = Config["Main checks"]["Email verified"].Importance
		},
		[6] = {
			['Name'] = 'ID',
			['Passed'] = false,
			['Importance'] = Config['Main checks']["ID verified"].Importance
		},
		[7] = {
			['Name'] = 'Premium',
			['Passed'] = false,
			['Importance'] = Config["Main checks"]["Premium membership"].Importance
		}
	}
	local ScoreCount = 0
	--\ Check age /--
	if Config["Main checks"]["Age"].Enabled == true then
		local AgeSuccess, AgeError = pcall(function()
			if player.AccountAge < 5 then
				Checks[1].Passed = false
				ScoreCount = ScoreCount + Checks[1].Importance
			else
				Checks[1].Passed = true
				ChecksPassed = ChecksPassed + 1
			end
		end)
		if not AgeSuccess then
			warn("[!] ATHERUM: Error while attempting to run `account age` check on "..player.Name..". Error: "..AgeError..". Error code: 503.")
			logExpectedError("Error while attempting to run `age` check on "..player.Name..". Error: "..AgeError..".", 503)
			Checks[1].Passed = false
			ScoreCount = ScoreCount + Checks[1].Importance
		end	
	end	
		
	--\ Check friends /--
	if Config["Main checks"]["Friends"].Enabled == true then
		local FriendsSuccess, FriendsError = pcall(function()
			local FriendsCount = 0
			local function iterPageItems(pages)
				return coroutine.wrap(function()
					local pagenum = 1
					while wait(0.01) do
						for _, item in ipairs(pages:GetCurrentPage()) do
							coroutine.yield(item, pagenum)
						end
						if pages.IsFinished then
							break
						end
						pages:AdvanceToNextPageAsync()
						pagenum = pagenum + 1
					end
				end)
			end
			local connectionPages = Players:GetFriendsAsync(player.UserId)
			local friendsList = {}
			for item, pageNo in iterPageItems(connectionPages) do
				table.insert(friendsList, item.Username)
			end
			for index, value in pairs(friendsList) do
				FriendsCount = FriendsCount + 1
			end
			if FriendsCount < 5 then
				Checks[2].Passed = false
				ScoreCount = ScoreCount + Checks[2].Importance
			else
				Checks[2].Passed = true
				ChecksPassed = ChecksPassed + 1
			end
		end)
		if not FriendsSuccess then
			warn("[!] ATHERUM: Error while attempting to run `friends count` check on "..player.Name..". Error: "..FriendsError..". Error code: 503.")
			logExpectedError("Error while attempting to run `friends count` check on "..player.Name..". Error: "..FriendsError..".", 503)
			Checks[2].Passed = false
			ScoreCount = ScoreCount + Checks[2].Importance
		end
	end
	
	--\ Groups /--
	if Config["Main checks"]["Groups"].Enabled == true then
		local GroupsSuccess, GroupsError = pcall(function()
			local GroupsCount = 0
			local groupsList = GroupService:GetGroupsAsync(player.UserId)
			for index, value in pairs(groupsList) do
				GroupsCount = GroupsCount + 1
			end
			if GroupsCount < 5 then
				Checks[3].Passed = false
				ScoreCount = ScoreCount + Checks[3].Importance
			else
				Checks[3].Passed = true
				ChecksPassed = ChecksPassed + 1
			end
			-- clear the table
			for e in pairs(groupsList) do
				groupsList[e] = nil
			end
		end)
		if not GroupsSuccess then
			warn("[!] ATHERUM: Error while attempting to run `groups` check on "..player.Name..". Error: "..GroupsError..". Error code: 503.")
			logExpectedError("Error while attempting to run `groups` check on "..player.Name..". Error: "..GroupsError..".", 503)
			Checks[3].Passed = false
			ScoreCount = ScoreCount + Checks[3].Importance
		end
	end
	
	--\ Badges /--
	if Config["Main checks"]["Badges"].Enabled == true then
		local BadgesSuccess, BadgesError = pcall(function()
			local badgeList = HttpService:JSONDecode(HttpService:GetAsync("https://badges.roproxy.com/v1/users/"..player.UserId.."/badges?limit=100&sortOrder=Asc"))
			local badgeCount = #badgeList.data
			if badgeCount < 7 then
				Checks[4].Passed = false
				ScoreCount = ScoreCount + Checks[4].Importance
			else
				Checks[4].Passed = true
				ChecksPassed = ChecksPassed + 1
			end
			-- clear the table
			for e in pairs(badgeList) do
				badgeList[e] = nil
			end
		end)
		if not BadgesSuccess then
			warn("[!] ATHERUM: Error while attempting to run `badges` check on "..player.Name..". Error: "..BadgesError..". Error code: 503.")
			logExpectedError("Error while attempting to run `badges` check on "..player.Name..". Error: "..BadgesError..".", 503)
			Checks[4].Passed = false
			ScoreCount = ScoreCount + Checks[4].Importance
		end
	end
	
	--\ Email verified (positive) /--
	local EmailSuccess, EmailError = pcall(function()
		if game:GetService('MarketplaceService'):PlayerOwnsAsset(player, 102611803) then
			Checks[5].Passed = true
			ChecksPassed = ChecksPassed +1
			if Config["Main checks"]["Email verified"].Enabled == true then
				ScoreCount = ScoreCount + Checks[5].Importance
			end	
		else
			Checks[5].Passed = false
		end
	end)
	if not EmailSuccess then
		warn("[!] ATHERUM: Error while attempting to run `email-verified` check on "..player.Name..". Error: "..EmailError..". Error code: 503.")
		logExpectedError("Error while attempting to run `email-verified` check on "..player.Name..". Error: "..EmailError..".", 503)
		Checks[5].Passed = false
		-- won't add to the score as it is a positive check
	end
	
	--\ ID verified (positive) /--
	local IDSucess, IDError = pcall(function()
		if game:GetService('VoiceChatService'):IsVoiceEnabledForUserIdAsync(player.UserId) then
			Checks[6].Passed = true
			ChecksPassed = ChecksPassed +1
			if Config["Main checks"]["ID verified"].Enabled == true then
				ScoreCount = ScoreCount + Checks[6].Importance
			end
		else
			Checks[6].Passed = false
		end
	end)
	if not IDSucess then
		warn("[!] ATHERUM: Error while attempting to run `ID-verified` check on "..player.Name..". Error: "..IDError..". Error code: 503.")
		logExpectedError("Error while attempting to run `ID-verified` check on "..player.Name..". Error: "..IDError..".", 503)
		Checks[6].Passed = false
		-- won't add to the score as it is a positive check
	end
	
	--\ Premium membership (positive) /--
	local PremiumSuccess, PremiumError = pcall(function()
		if player.MembershipType == Enum.MembershipType.Premium then
			Checks[7].Passed = true
			ChecksPassed = ChecksPassed +1
			if Config["Main checks"]["Premium membership"].Enabled == true then
				ScoreCount = ScoreCount + Checks[7].Importance
			end	
		else
			Checks[7].Passed = false
		end
	end)
	if not PremiumSuccess then
		warn("[!] ATHERUM: Error while attempting to run `premium membership` check on "..player.Name..". Error: "..PremiumError..". Error code: 503.")
		logExpectedError("Error while attempting to run `premium membership` check on "..player.Name..". Error: "..PremiumError..".", 503)
		Checks[7].Passed = false
		-- won't add to the score as it is a positive check
	end
	
	--\ Count /--
	if ScoreCount >= Config["Min. detection score"] then
		PlayerIsAlt = true
	end
	
	--\ Auto-pass /--
	if (Config["Auto-pass"]["Email verified"] == true and Checks[5].Passed) or (Config["Auto-pass"]["ID verified"] == true and Checks[6].Passed) or (Config["Auto-pass"]["Premium membership"] == true and Checks[7].Passed) then
		PlayerIsAlt = false
	end
	
	--\ Blacklist /--
	if Config["Username strings"].Enabled == true then
		for index, word in pairs(Config["Username strings"].Words) do
			if string.find(player.Name, word) then
				PlayerIsAlt = true
			end
		end
	end
	if Config["Groups blacklist"].Enabled == true then
		for index, ID in pairs(Config["Groups blacklist"]["Group IDs"]) do
			if player:IsInGroup(ID) then
				PlayerIsAlt = true
			end
		end
	end
	
	--\ Report /--
	if PlayerIsAlt then
		postDetection(player.Name, player.UserId, ScoreCount)
		punishAlt(player)
		game:GetService('ServerScriptService'):WaitForChild('Atherum Anti-Alt'):WaitForChild('API', 2):WaitForChild('UserDetected', 2):Fire(player)
	end
	local Data = {
		['User'] = player.Name,
		['UserId'] = player.UserId,
		['Score'] = ScoreCount,
		['IsAlt'] = PlayerIsAlt,
		['Checks'] = {
			['Age'] = {
				['Name'] = "Age",
				['Passed'] = Checks[1].Passed
			},
			['Friends'] = {
				['Name'] = "Friends",
				['Passed'] = Checks[2].Passed
			},
			['Groups'] = {
				['Name'] = "Groups",
				['Passed'] = Checks[3].Passed
			},
			['Badges'] = {
				['Name'] = "Badges",
				['Passed'] = Checks[4].Passed
			},
			['Email'] = {
				['Name'] = "Email",
				['Passed'] = Checks[5].Passed
			},
			['ID'] = {
				['Name'] = "ID",
				['Passed'] = Checks[6].Passed
			},
		},
		['Checks passed'] = ChecksPassed
	}
	local DataExists = false
	if #_G.AtherumUsersList == 0 then
		print("[>] ATHERUM: Local server player data is empty.")
		table.insert(_G.AtherumUsersList, Data)
		print("[>] ATHERUM: Player data added to local server. Score: "..tostring(ScoreCount))
	end
	for index, dataset in pairs(_G.AtherumUsersList) do
		if dataset['UserId'] == player.UserId then
			DataExists = true
		end
	end
	if DataExists then
		return
	else
		table.insert(_G.AtherumUsersList, Data)	
		print("[>] ATHERUM: Player data added to local server. Score: "..tostring(ScoreCount))
	end
	updateData()
end)


--| Error logging |--
game:GetService('LogService').MessageOut:Connect(function(message, messagetype)
	if messagetype == Enum.MessageType.MessageOutput then return end
	if messagetype == Enum.MessageType.MessageError then
		if string.find(string.lower(message), string.lower("ATHERUM")) then
			logUnexpectedError(message)
		end
	end
	if messagetype == Enum.MessageType.MessageInfo then
		if string.find(string.lower(message), string.lower("ATHERUM")) then
			logInfoStack(message)
		end
	end
end)


--| Print version |--
local ModelBuildVersion = game:GetService('InsertService'):GetLatestAssetVersionAsync(10438226348)
print("Your Atherum engine is running on version "..tostring(script.Version.Value).."; build ID "..tostring(ModelBuildVersion)..".")
