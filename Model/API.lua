--| Variables |--
local API = {}
local DataStoreService = game:GetService('DataStoreService')
local Config = require(script.Parent.Settings)

--| Functions |--
local function blockAPI()
	if Config["Enable server API"] == false then
		warn("[!] ATHERUM: API serviced are disabled in the configuration.")
		return false
	end
end	

--| API functions |--
function API:IsPlayerAlt(player)
	if blockAPI() == false then
		return "API services disabled in settings"
	end
	for index, dataset in pairs(_G.AtherumUsersList) do
		if dataset['UserId'] == player.UserId then
			return dataset['IsAlt']
		end
	end
end
function API:GetPlayerScore(player)
	if blockAPI() == false then
		return "API services disabled in settings"
	end
	for index, dataset in pairs(_G.AtherumUsersList) do
		if dataset['UserId'] == player.UserId then
			return dataset['Score']
		end
	end
end
function API:GetNumberOfPassedChecks(player)
	if blockAPI() == false then
		return "API services disabled in settings"
	end
	for index, dataset in pairs(_G.AtherumUsersList) do
		if dataset['UserId'] == player.UserId then
			return dataset['Checks passed']
		end
	end
end
function API:GetPlayerCheckStatus(player)
	if blockAPI() == false then
		return "API services disabled in settings"
	end
	for index, dataset in pairs(_G.AtherumUsersList) do
		if dataset['UserId'] == player.UserId then
			return dataset['Checks']
		end
	end
end
function API:GetPlayerFailedChecks(player)
	if blockAPI() == false then
		return "API services disabled in settings"
	end
	for index, dataset in pairs(_G.AtherumUsersList) do
		if dataset['UserId'] == player.UserId then
			local FailedChecks = {}
			for index, check in pairs(dataset['Checks']) do
				if check['Passed'] == false then
					table.insert(FailedChecks, check['Name'])
				end
			end
			return FailedChecks
		end
	end
end
function API:GetPlayerPassedChecks(player)
	if blockAPI() == false then
		return "API services disabled in settings"
	end
	for index, dataset in pairs(_G.AtherumUsersList) do
		if dataset['UserId'] == player.UserId then
			local PassedChecks = {}
			for index, check in pairs(dataset['Checks']) do
				if check['Passed'] == true then
					table.insert(PassedChecks, check['Name'])
				end
			end
			return PassedChecks
		end
	end
end
function API:GetServerSavedData(serverID)
	if blockAPI() == false then
		return "API services disabled in settings"
	end
	local DataStore
	local GetDSSuccess, GetDSError = pcall(function()
		DataStore = DataStoreService:GetDataStore(serverID)
	end)
	if not GetDSSuccess then
		warn("[!] ATHERUM: Error while getting datastore in API call. Error: "..GetDSError..". Error code: 500")
		return "API error: 500"
	end
	local SavedData
	local GetDataSuccess, GetDataError = pcall(function()
		SavedData = DataStore:GetAsync(Config["DataStore key"])
	end)
	if not GetDataSuccess then
		warn("[!] ATHERUM: Error while getting data in API call. Error: "..GetDataError..". Error code: 500")
		return "API error: 500"
	end
	if typeof(SavedData) == "string" then
		SavedData = nil
		print("[-] ATHERUM: Data found in "..serverID.." is `nil`. Make sure the server ID and key are correct.")
	elseif not SavedData then
		SavedData = nil
		print("[-] ATHERUM: Data found in "..serverID.." is `nil`. Make sure the server ID and key are correct.")
	elseif #SavedData == 0 then
		SavedData = nil
		print("[-] ATHERUM: Data found in "..serverID.." is `nil`. Make sure the server ID and key are correct.")
	end
	return SavedData
end

return API
