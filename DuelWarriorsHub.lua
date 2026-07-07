--[[
    Duel Warriors Hub | Main Script
    This project is open-source and intended for learning and personal use.

    Support:
    If you encounter issues, open a ticket in the Discord server.
    You may also contact me (@nikoleto._) via Discord for questions about the code.

    -- Made by Nikoleto Scripts
    GitHub: https://github.com/nikoladhima
    Discord: https://discord.gg/DwRT2nH93D
]]

repeat task.wait() until game:IsLoaded()
if workspace.DistributedGameTime < 3 then
    task.wait(3 - workspace.DistributedGameTime)
end

local Running = true
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local clonerefFunction = cloneref or clone_ref or clonereference or clone_reference
local function ns__cloneref(Object)
	if not clonerefFunction then
		return Object
	end

	local Success, Result = pcall(clonerefFunction, Object)
	return Success and Result or Object
end

local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local CoreGui = ns__cloneref(game:GetService("CoreGui"))
local Camera = workspace.CurrentCamera

local Connections = {}

local function GetRoot(Character)
	return Character and (Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart"))
end

local function RemoveDrawing(Object)
    if Object then
        pcall(function()
            Object:Remove()
        end)
    end
end

local CachedPlayers = {}

local function ClearCache(Player)
	local Cache = CachedPlayers[Player]
	if Cache then
        RemoveDrawing(Cache.ESP)
        CachedPlayers[Player] = nil
    end
end

local function CachePlayer(Player)
	if Player == LocalPlayer then
        return
    end

	local Cache = CachedPlayers[Player] or {}

	local Character = Player.Character
	if not Character then
		ClearCache(Player)
		return
	end

	Cache.Character = Character

	local Root = GetRoot(Character)
	if not Root then
		ClearCache(Player)
		return
	end

	Cache.Root = Root
    Cache.Humanoid = Character:FindFirstChildOfClass("Humanoid")
    Cache.Head = Character:FindFirstChild("Head")

    local ESP = Cache.ESP
    if not ESP then
        ESP = Drawing.new("Text")
        ESP.Size = 16
        ESP.Center = true
        ESP.Outline = true
        ESP.Visible = false
        Cache.ESP = ESP
    end

	CachedPlayers[Player] = Cache
end

local function AddCache(Player)
	CachePlayer(Player)

	table.insert(Connections, Player.CharacterAdded:Connect(function()
		CachePlayer(Player)
	end))

	table.insert(Connections, Player.CharacterRemoving:Connect(function()
		ClearCache(Player)
	end))
end

task.spawn(function()
	while true do
		for _,Player in ipairs(Players:GetPlayers()) do
			local Cache = CachedPlayers[Player]

			if not Cache then
				AddCache(Player)
			else
				if not Cache.Character or not Cache.Root then
					AddCache(Player)
				end
			end
		end

		if not Running then
            break
        end

        task.wait(2.5)
	end
end)

table.insert(Connections, Players.PlayerAdded:Connect(CachePlayer))
table.insert(Connections, Players.PlayerRemoving:Connect(ClearCache))

local LocalCharacter = nil
local LocalHumanoid = nil
local LocalHead = nil
local LocalRoot = nil
local SkillList = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Lobby"):WaitForChild("UI_Skill"):WaitForChild("List")
local FunctionFolder = workspace:WaitForChild("Scene"):WaitForChild("Function")
local EventFolder = workspace:WaitForChild("Event")
local ShopModuleRE = EventFolder:WaitForChild("ShopModule_RemoteEvent")
local EquipmentRF = EventFolder:WaitForChild("Equipment_RemoteFunction")
local FireProximityPrompt = fireproximityprompt or fire_proximity_prompt

local Configuration = {
    AutoWeapon = false,
    AutoFirstSkill = false,
    AutoSecondSkill = false,

    Speed = false,
    SpeedAmount = 0.5,
    InfiniteJump = false,

    Attaching = false,
    BackOffset = 1.5,
    UpOffset = 1.25,
    BodyVelocity = true,

    ESPEnabled = false,
    ESPShowNames = true,
    ESPShowHealth = true,
    ESPShowDistance = true,
    ESPColor = Color3.fromRGB(255, 255, 255),

    AutoForge = false,
    AutoAbility = false,

    AntiAFK = true,
    AntiRagdoll = false,
    GodMode = false,

    FOVChanger = false,
    FOVValue = 90
}

local VirtualUser = ns__cloneref(game:GetService("VirtualUser"))
table.insert(Connections, LocalPlayer.Idled:Connect(function()
    if Configuration.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end))

table.insert(Connections, RunService.Heartbeat:Connect(function()
    local CurrentCharacter = LocalPlayer.Character
    if not CurrentCharacter or not CurrentCharacter.Parent then
        LocalCharacter, LocalHumanoid, LocalHead, LocalRoot = nil, nil, nil, nil
        return
    end

    LocalCharacter = CurrentCharacter

    if not LocalHumanoid or LocalHumanoid.Parent ~= LocalCharacter then
        LocalHumanoid = LocalCharacter:FindFirstChildOfClass("Humanoid")
    end

    if not LocalHead or LocalHead.Parent ~= LocalCharacter then
        LocalHead = LocalCharacter:FindFirstChild("Head")
    end

    if not LocalRoot or LocalRoot.Parent ~= LocalCharacter then
        LocalRoot = LocalCharacter.PrimaryPart or LocalCharacter:FindFirstChild("HumanoidRootPart") or LocalCharacter:FindFirstChild("Torso")
    end
end))

table.insert(Connections, UserInputService.JumpRequest:Connect(function()
    if Configuration.InfiniteJump and LocalHumanoid then
        LocalHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

local function RunGodMode(Action)
    if Action then
        EquipmentRF:InvokeServer({["TYPE"] = "CanPreview"})
    else
        EquipmentRF:InvokeServer({["TYPE"] = "ClosePreview"})
    end
end

task.spawn(function()
    while true do
        if not Running then
            break
        end

        if Configuration.GodMode then
            RunGodMode(true)
            task.wait(2.45)
        end

        task.wait()
    end
end)

local function UseSkill(SkillName, KeyCode)
    local Skill = LocalCharacter and SkillList:FindFirstChild(SkillName)
    if not Skill then
        return
    end

    local FrameStatus = Skill:FindFirstChild("Frame_Status")
    if not FrameStatus then
        return
    end

    local FrameCD = FrameStatus:FindFirstChild("Frame_CD")
    if not FrameCD or FrameCD.Size.Y.Scale ~= 0 then
        return
    end

    local Communicate = LocalCharacter:FindFirstChild("Communicate")
    if Communicate and Communicate:IsA("RemoteEvent") then
        Communicate:FireServer({
            ["Key"] = KeyCode, ["State"] = Enum.UserInputState.Begin
        })
    end
end

task.spawn(function()
    while true do
        if not Running then
            break
        end

        if Configuration.AutoWeapon then
            UseSkill("Skill1", Enum.KeyCode.Four)
        end

        if Configuration.AutoFirstSkill then
            UseSkill("Skill2", Enum.KeyCode.Two)
        end

        if Configuration.AutoSecondSkill then
            UseSkill("Skill3", Enum.KeyCode.Three)
        end

        task.wait(0.075)
    end
end)

table.insert(Connections, RunService.Heartbeat:Connect(function()
    if Configuration.FOVChanger then
        Camera.FieldOfView = Configuration.FOVValue
    end

    if LocalHumanoid and Configuration.AntiRagdoll and ((LocalHumanoid:GetState() == Enum.HumanoidStateType.Ragdoll) or (LocalHumanoid:GetState() == Enum.HumanoidStateType.FallingDown)) then
        LocalHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    if Configuration.Attaching then
        if not LocalRoot or not LocalPlayer:GetAttribute("InDuel") then
            return
        end

        local ClosestPlayer = nil
        local BiggestDistance = 185
        for Player, Cache in next, CachedPlayers do
            if not Player:GetAttribute("InDuel") then
                continue
            end

            local Root = Cache.Root
            if not Root then
                continue
            end

            local Magnitude = (LocalRoot.Position - Root.Position).Magnitude
            if Magnitude < BiggestDistance then
                ClosestPlayer = Player
                BiggestDistance = Magnitude
            end
        end

        local ClosestRoot = ClosestPlayer and GetRoot(ClosestPlayer.Character)
        if ClosestRoot then
            local ClosestRootCFrame = ClosestRoot.CFrame
            LocalRoot.CFrame = CFrame.lookAt((ClosestRootCFrame * CFrame.new(0, Configuration.UpOffset, Configuration.BackOffset)).Position, ClosestRootCFrame.Position)
            if Configuration.BodyVelocity then
                local BodyVelocity = LocalRoot:FindFirstChildOfClass("BodyVelocity")
                if BodyVelocity then
                    BodyVelocity.MaxForce = Vector3.new(5000, 5000, 5000)
                end
            end
        end
    elseif Configuration.BodyVelocity then
        local BodyVelocity = LocalRoot and LocalRoot:FindFirstChildOfClass("BodyVelocity")
        if BodyVelocity then
            BodyVelocity.MaxForce = Vector3.zero
        end
    end

    if Configuration.Speed and LocalHumanoid and LocalRoot then
        local MoveDirection = LocalHumanoid.MoveDirection
        if MoveDirection.Magnitude > 0 then
            LocalRoot.CFrame += MoveDirection * Configuration.SpeedAmount
        end
    end

    for Player, Cache in next, CachedPlayers do
        if not Cache.Character then
            continue
        end

        local IsVisible
        if Configuration.ESPEnabled and Cache.Head and Cache.Humanoid and Cache.Humanoid.Health > 0 then
            local Screen, OnScreen = Camera:WorldToViewportPoint(Cache.Head.Position)
            if OnScreen then
                IsVisible = true

                local TextParts = {}
                if Configuration.ESPShowNames then
                    table.insert(TextParts, Player.DisplayName)
                end

                if Configuration.ESPShowHealth then
                    table.insert(TextParts, string.format("[%d HP]", math.floor(Cache.Humanoid.Health)))
                end

                if LocalRoot and Configuration.ESPShowDistance then
                    table.insert(TextParts, string.format("[%d M]", math.floor((LocalRoot.Position - Cache.Head.Position).Magnitude)))
                end

                local ESP = Cache.ESP
                if #TextParts > 0 then
                    ESP.Text = table.concat(TextParts, "\n")
                    ESP.Position = Vector2.new(Screen.X - 40, Screen.Y - 40)
                    ESP.Color = Configuration.ESPColor
                    ESP.Visible = true
                else
                    ESP.Visible = false
                end
            end
        end

        if not IsVisible then
            Cache.ESP.Visible = false
        end
    end
end))

if FireProximityPrompt then
    task.spawn(function()
        while true do
            if not Running then
                break
            end

            if Configuration.AutoForge then
                if FunctionFolder:FindFirstChild("WeaponGacha") then
                    FireProximityPrompt(FunctionFolder.WeaponGacha.TouchBox.ProximityPrompt)
                    ShopModuleRE:FireServer({
                        ["Data"] = { ["ID"] = "420001", ["TYPE"] = "Gold" },
                        ["TYPE"] = "Gashapon"
                    })
                end
            end

            if Configuration.AutoAbility then
                pcall(function()
                    if FunctionFolder:FindFirstChild("AbilityGacha") then
                        FireProximityPrompt(FunctionFolder.AbilityGacha.TouchPart.ProximityPrompt)
                        ShopModuleRE:FireServer({
                            ["Data"] = { ["ID"] = "420004", ["TYPE"] = "Gold" },
                            ["TYPE"] = "Gashapon"
                        })
                    end
                end)
            end

            task.wait(0.5)
        end
    end)
end

local Library
if not pcall(function()
    Library = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end) then
    return LocalPlayer:Kick("Duel Warriors Hub | Failed to load UI library, rejoin and try executing the script again.")
end

local Window = Library:CreateWindow({
    Title = "Duel Warriors Hub",
    SubTitle = "Made by Nikoleto Scripts",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Combat = Window:AddTab({
        Title = "Combat",
        Icon = "swords"
    }), Farming = Window:AddTab({
        Title = "Farming",
        Icon = "skull"
    }), Visuals = Window:AddTab({
        Title = "Visuals",
        Icon = "eye"
    }), GachaShop = Window:AddTab({
        Title = "Shop",
        Icon = "shopping-cart"
    }), Miscellaneous = Window:AddTab({
        Title = "Miscellaneous",
        Icon = "component"
    })
}

Tabs.Combat:AddToggle("AutoWeaponToggle", {
    Title = "Auto Weapon",
    Default = Configuration.AutoWeapon
}):OnChanged(function(Value)
    Configuration.AutoWeapon = Value
end)

Tabs.Combat:AddToggle("AutoFirstSkillToggle", {
    Title = "Auto First Skill",
    Default = Configuration.AutoFirstSkill
}):OnChanged(function(Value)
    Configuration.AutoFirstSkill = Value
end)

Tabs.Combat:AddToggle("AutoSecondSkillToggle", {
    Title = "Auto Second Skill",
    Default = Configuration.AutoSecondSkill
}):OnChanged(function(Value)
    Configuration.AutoSecondSkill = Value
end)

Tabs.Combat:AddButton({
    Title = "Auto All Skills",
    Description = "Enable all skill toggles quickly",
    Callback = function()
       Library.Options.AutoWeaponToggle:SetValue(true)
       Library.Options.AutoFirstSkillToggle:SetValue(true)
       Library.Options.AutoSecondSkillToggle:SetValue(true)
    end
})

Tabs.Combat:AddToggle("SpeedToggle", {
    Title = "Speed",
    Default = Configuration.Speed
}):OnChanged(function(Value)
    Configuration.Speed = Value
end)

Tabs.Combat:AddSlider("SpeedAmountSlider", {
    Title = "Speed Amount",
    Default = Configuration.SpeedAmount * 100,
    Min = 0,
    Max = 500,
    Rounding = 0.1,
    Callback = function(Value)
        Configuration.SpeedAmount = Value * 0.01
    end
})

Tabs.Combat:AddToggle("InfiniteJumpToggle", {
    Title = "Infinite Jump",
    Default = Configuration.InfiniteJump
}):OnChanged(function(Value)
    Configuration.InfiniteJump = Value
end)

Tabs.Farming:AddToggle("PlayerAttachToggle", {
    Title = "Player Attach",
    Default = Configuration.Attaching
}):OnChanged(function(Value)
    Configuration.Attaching = Value
end)

Tabs.Farming:AddToggle("BodyVelocityToggle", {
    Title = "Body Velocity",
    Default = Configuration.BodyVelocity
}):OnChanged(function(Value)
    Configuration.BodyVelocity = Value

    local BodyVelocity = LocalRoot and LocalRoot:FindFirstChildOfClass("BodyVelocity")
    if not Value then
        if BodyVelocity then
            BodyVelocity:Destroy()
        end
        return
    end

    if not BodyVelocity and LocalRoot then
        BodyVelocity = ns__cloneref(Instance.new("BodyVelocity"))
        BodyVelocity.MaxForce = Vector3.zero
        BodyVelocity.Velocity = Vector3.zero
        BodyVelocity.Parent = LocalRoot
    end
end)

Tabs.Farming:AddSlider("BackOffsetSlider", {
    Title = "Offset back",
    Description = "This changes your offset from the distance in the back",
    Default = Configuration.BackOffset,
    Min = 0.05,
    Max = 3,
    Rounding = 0.5,
    Callback = function(Value)
        Configuration.BackOffset = Value
    end
})

Tabs.Farming:AddSlider("UpOffsetSlider", {
    Title = "Offset up",
    Description = "This changes your offset from the distance by up",
    Default = Configuration.UpOffset,
    Min = 0.05,
    Max = 3,
    Rounding = 0.5,
    Callback = function(Value)
        Configuration.UpOffset = Value
    end
})

Tabs.Visuals:AddToggle("ESPEnabledToggle", {
    Title = "Enable ESP",
    Default = Configuration.ESPEnabled
}):OnChanged(function(Value)
    Configuration.ESPEnabled = Value
end)

Tabs.Visuals:AddToggle("ESPShowNamesToggle", {
    Title = "Show Names",
    Default = Configuration.ESPShowNames
}):OnChanged(function(Value)
    Configuration.ESPShowNames = Value
end)

Tabs.Visuals:AddToggle("ESPShowHealthToggle", {
    Title = "Show Health",
    Default = Configuration.ESPShowHealth
}):OnChanged(function(Value)
    Configuration.ESPShowHealth = Value
end)

Tabs.Visuals:AddToggle("ESPShowDistanceToggle", {
    Title = "Show Distance",
    Default = Configuration.ESPShowDistance
}):OnChanged(function(Value)
    Configuration.ESPShowDistance = Value
end)

Tabs.Visuals:AddColorpicker("ESPColorPicker", {
    Title = "ESP Color",
    Default = Configuration.ESPColor
}):OnChanged(function(Value)
    Configuration.ESPColor = Value
end)

if FireProximityPrompt then
    Tabs.GachaShop:AddToggle("AutoForgeToggle", {
        Title = "Auto Forge Weapon",
        Default = Configuration.AutoForge
    }):OnChanged(function(Value)
        Configuration.AutoForge = Value
    end)

    Tabs.GachaShop:AddToggle("AutoAbilityToggle", {
        Title = "Auto Buy Ability",
        Default = Configuration.AutoAbility
    }):OnChanged(function(Value)
        Configuration.AutoAbility = Value
    end)

    Tabs.GachaShop:AddButton({
        Title = "Forge Weapon (Once)",
        Callback = function()
            if FunctionFolder:FindFirstChild("WeaponGacha") then
                FireProximityPrompt(FunctionFolder.WeaponGacha.TouchBox.ProximityPrompt)
                task.delay(1, function()
                    ShopModuleRE:FireServer({
                        ["Data"] = {["ID"] = "420001", ["TYPE"] = "Gold"},
                        ["TYPE"] = "Gashapon"
                    })
                end)
            end
        end
    })

     Tabs.GachaShop:AddButton({
        Title = "Buy Ability (Once)",
        Callback = function()
            if FunctionFolder:FindFirstChild("AbilityGacha") then
                FireProximityPrompt(FunctionFolder.AbilityGacha.TouchPart.ProximityPrompt)
                task.delay(1, function()
                    ShopModuleRE:FireServer({
                        ["Data"] = {["ID"] = "420004", ["TYPE"] = "Gold"},
                        ["TYPE"] = "Gashapon"
                    })
                end)
            end
        end
    })
else
    Tabs.GachaShop:AddParagraph({
        Title = "Error",
        Content = "Function 'fireproximityprompt' is not supported on your executor. Shop features disabled."
    })
end

Tabs.Miscellaneous:AddToggle("AntiAFKToggle", {
    Title = "Anti-AFK",
    Default = Configuration.AntiAFK
}):OnChanged(function(Value)
    Configuration.AntiAFK = Value
end)

Tabs.Miscellaneous:AddToggle("GodModeToggle", {
    Title = "God Mode",
    Default = Configuration.GodMode
}):OnChanged(function(Value)
    Configuration.GodMode = Value
    if not Value then
        task.delay(0.1, RunGodMode)
    end
end)

Tabs.Miscellaneous:AddToggle("AntiRagdollToggle", {
    Title = "Anti Ragdoll",
    Default = Configuration.AntiRagdoll
}):OnChanged(function(Value)
    Configuration.AntiRagdoll = Value
end)

Tabs.Miscellaneous:AddToggle("FOVChangerToggle", {
    Title = "FOV Changer",
    Default = Configuration.FOVChanger
}):OnChanged(function(Value)
    Configuration.FOVChanger = Value
    if not Value then
        Camera.FieldOfView = 70
    end
end)

Tabs.Miscellaneous:AddSlider("FOVValueSlider", {
    Title = "FOV Value",
    Default = Configuration.FOVValue,
    Min = 70,
    Max = 120,
    Rounding = 1,
    Callback = function(Value)
        Configuration.FOVValue = Value
    end
})

Window:SelectTab(1)
Library:Notify({
    Title = "Loaded",
    Content = "Welcome to Duel Warriors Hub (Rewritten)!",
    Duration = 2.5
})

task.spawn(function()
    while true do
        if Library.Unloaded then
            Running = false

            if Configuration.GodMode then
                RunGodMode(false)
            end

            for _,Cache in next, CachedPlayers do
                RemoveDrawing(Cache.ESP)
            end

            for Index, Connection in next, Connections do
                Connection:Disconnect()
                Connections[Index] = nil
            end

            Camera.FieldOfView = 70
            break
        end
        task.wait(0.5)
    end
end)

if not writefile or not makefolder or not isfile or not isfolder then
    return
end

local Base = "NikoletoScripts/DuelWarriorsHub/"
for _,Path in {"NikoletoScripts", "NikoletoScripts/DuelWarriorsHub", Base .. "Sounds", Base .. "Configs", Base .. "Cache", Base .. "Logs"} do
	pcall(function()
        if not isfolder(Path) then
            makefolder(Path)
        end
    end)
end

local Request = not isfile("NikoletoScripts/DuelWarriorsHub/Cache/Invite.nscache") and (httprequest or http_request or request)
if Request then
    local HttpService = game:GetService("HttpService")
    if pcall(Request, {Url = "http://127.0.0.1:6463/rpc?v=1",  Method = "POST", Headers = {
        ["Content-Type"] = "application/json", Origin = "https://discord.com"
    }, Body = HttpService:JSONEncode({cmd = "INVITE_BROWSER", nonce = HttpService:GenerateGUID(false), args = {code = "DwRT2nH93D"}})
    }) then
        writefile("NikoletoScripts/PhantomWare/Cache/Invite.nscache", "DwRT2nH93D")
    end
end
