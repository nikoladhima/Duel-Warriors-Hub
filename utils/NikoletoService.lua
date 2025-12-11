-- Data Logging Nikoleto Service --

--- KEY INFO ---
-- This data is not used maliciously its only used to take feedback and to know how popular the script is (probably going to make it send less data in the future)
-- It will not be used as proof to get you banned on roblox or anything like that
-- Dont like it still? you can opt out with the tutorial(s) below
-- Trying to abuse the data being sent will get you banned from the system fully (its automatic)
-- If you have used it while being opted in and want out then join my discord server and make a ticket (yes even if it doesn't say its used for that) and provide your information so it can be fully deleted
----------------

--[[ How to opt out from Nikoleto Service:
    1. Use this loadstring instead:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/nikoladhima/Duel-Warriors-Hub/main/DuelWarriorsHub.lua"))("RemoveLogging")
    Thats it you've done it lol, stay secret mr agent 🕵️‍♂️
]]


local cloneref = cloneref or clone_ref or clonereference or clone_reference or function(...)
	return (...)
end

local UserInputService = cloneref(game:GetService("UserInputService"))

local function SafeCall(fn)
	local success, result = pcall(fn)
	return success and result or "Unknown"
end

local function GetPlatform()
	return UserInputService:GetPlatform()
end

local function GetMobile()
	if UserInputService.TouchEnabled and (GetPlatform() == Enum.Platform.IOS or GetPlatform() == Enum.Platform.Android) then
		return "Mobile"
	end
	return "Computer"
end

local LocalPlayer = cloneref(game:GetService("Players")).LocalPlayer

local Success, Encoded = pcall(function()
    return game:GetService("HttpService"):JSONEncode({
        Username = LocalPlayer.Name,
        DisplayName = LocalPlayer.DisplayName,
        AccountAge = LocalPlayer.AccountAge,
        Platform = GetMobile() .. " | " .. tostring(GetPlatform()),
        Executor = SafeCall(identifyexecutor) .. " | " .. SafeCall(getexecutorname),
        HWID = game:GetService("RbxAnalyticsService"):GetClientId(),
        ServerLink = "roblox://experiences/start?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId
    })
end)

if not Success then
    warn("[Service Error] Failed to encode JSON.")
    return
end

local httprequest = httprequest or http_request or request or HttpPost or (http and http.request) or (syn and syn.request)
if httprequest then
    local Response = httprequest({
        Url = "https://service.nikoleto.workers.dev/duelwarriorshub",
        Body = Encoded,
        Method = "POST",
        Headers = {
            ["content-type"] = "application/json"
        },
    })
    if not Response then
        warn("[Service Error] No response / httprequest blocked.")
        return
    end
    warn("[Service Info] Sent data with response code: " .. tostring(Response.StatusCode))
    return
end
warn("[Service Error] httprequest blocked / not supported.")
