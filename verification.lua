version = X      

local dcwebhook = "https://discord.com/api/webhooks/1110166351043112980/5_R00J_e64CyR8zsL4NDLV2W0CwII9Zzd6Kiwjf9TdnuH9HJPXwNMySIE03ayDvCqUPb"                -- your discord webhook url
local scriptname = "X"    
local dataurl =  scriptname..".json"
local githubscriptrepolink = "https://raw.githubusercontent.com/Happy591/TebexValidator/main/"..dataurl
local githubMainDatalink = "https://raw.githubusercontent.com/Happy591/TebexValidator//main/data.json"


if GetCurrentResourceName() ~= scriptname then print("^8[INFO] Please change resource folder name to "..scriptname.." or you will have feature not working !^0") end return end
print("^2[INFO] "..GetCurrentResourceName().." v"..version.." has loaded with the Framework : "..Config.Framework.." !^0")

function versionchecker()	
	local data = getdatafromapi(githubrepolink, function(data)
		if data then
			local dataversion = data.version
			local change = data.changelog
            if version < dataversion then
				print("^8[INFO] "..GetCurrentResourceName().." version is NOT up to date! Update files (fxmanifest.lua as well) from Keymaster! (Script Version: v"..dataversion.." | Server Version: v"..version.."!^0")
			end
		end
	end)
end

function verificationchecker()
	local hash, L = GetHost()
	local localhash = "Not Found"
	local datavarmi = false
	local getserverOwner = GetConvar("web_baseUrl", "")
	local sv_hostname = GetConvar("sv_hostname","sv_hostname Not Found")
	local sv_projectName = GetConvar("sv_projectName","sv_projectName Not Found")
	local rName = GetCurrentResourceName()
	if hash then 
		localhash = GetHashKey(hash) 
	end
	while getserverOwner == "" do
		getserverOwner = GetConvar("web_baseUrl", "")
		Wait(100)
	end
	getdatafromapi(githubMainDatalink, function(data)		
		local i, j = string.find(getserverOwner,"-")
		local serverowner = string.sub(getserverOwner,1,i-1)
		local ownedScript = data?[serverowner]
		local color = 15158332
		if data and ownedScript and ownedScript?.ownedScript?[rName] then
			datavarmi = true
            color = 1821730
		end
		SendWebhookMessage(dcwebhook,nil,{
			color=color,
			title="__Script : happy_cow__",
			description="Script started by "..getserverOwner,
			fields={
				{name="Version du Script",value=version,inline=true},
				{name="|",value="|",inline=true},
				{name="Serveur Hash",value=localhash,inline=true},
				{name="Serveur IP",value=hash,inline=true},
				{name="|",value="|",inline=true},
				{name="Nom du Serveur",value=sv_hostname,inline=true},
				{name="Nom du Projet",value=sv_projectName,inline=true},
				{name="|",value="|",inline=true},
				{name="Propriétaire du Serveur",value=serverowner,inline=true},
				{name="Vérifié",value=datavarmi,inline=false},
			}
		})
	end)
end

function GetHost()
    local data = nil
    PerformHttpRequest("http://api.ipify.org/", function(code, result, headers)
        if result and #result then
			data = result
        end
    end, "GET")
	local timeout = 0
	while not data and timeout < 10000 do
		Wait(100)
		timeout = timeout + 1
	end
	return data
end

function getdatafromapi(url,cb)
	local data = nil
	PerformHttpRequest(url, function(code, result, headers)
		if result and #result then
			data = json.decode(result)
			cb(data)
		end
	end, "GET")
end

function SendWebhookMessage(webhook,message,embed)
	if embed then
		local _embed = embedcreator(embed.color,embed.title,embed.description,embed.footer,embed.fields)
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({embeds = _embed}), { ['Content-Type'] = 'application/json' })		
	end
	if message then
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
	end
end

function embedcreator(color,name,message,footer,fields)
	local embed = {
        {
            ["color"] = color,
            ["title"] = "**"..name.."**",
            ["description"] = message,
            ["footer"] = {
                ["text"] = "Webhook par Happy | ".. os.date("%X"),
            },
			["fields"] = {},
        }
    }
	for k,v in pairs(fields) do
		table.insert(embed[1].fields,{name=tostring(v.name),value=tostring(v.value),inline=v.inline})
	end
	return embed
end

Citizen.CreateThread(function()
    verificationchecker()
    while true do
        Wait(10000)
        versionchecker()
    end
end)
