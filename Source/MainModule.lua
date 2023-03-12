local loader = {}

function loader:Init()
	local EngineScript = script.Atherum_Engine
	script.Atherum_Engine.Parent = game:GetService('ServerScriptService'):WaitForChild('Atherum Anti-Alt', 2)
	if EngineScript.Parent.Name ~= "Atherum Anti-Alt" then
		warn("[!] ATHERUM: Engine script has an invalid parent. Error code: 501")
	else
		print("[-] ATHERUM: Engine has been parented and loaded to the Atherum main folder.")
	end
end

return loader
