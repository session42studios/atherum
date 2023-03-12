task.wait(0.01)
local Settings = require(script.Parent)
local Success, Error = pcall(function()
	require(Settings.Loader):Init()
end)
if not Success then
	warn("[!] ATHERUM: Failed to request initialization ("..Error.."). ")
	if Settings["Error logging"].Enabled == true then
		local ErrorData = {
			["username"] = "Atherum Error Monitor";
			["content"] = "<:hard_error:1000827183771689000>**| CRITICAL ERROR WHILE INITIALIZING ATHERUM \n```lua \n"..Error.." \n ``` \n *Error code: 101*";
		}
		ErrorData = game:GetService('HttpService'):JSONEncode(ErrorData)
		game:GetService('HttpService'):PostAsync(Settings["Error logging"]["Discord webhook URL"], ErrorData)
	end
else
	--// Required successfully.
end



