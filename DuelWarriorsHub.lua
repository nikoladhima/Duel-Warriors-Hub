--[[
    █████████                       ████     █████   ███   █████                                ███                                █████   █████            █████
    ▒▒███▒▒▒▒███                     ▒▒███    ▒▒███   ▒███  ▒▒███                                ▒▒▒                                ▒▒███   ▒▒███            ▒▒███
    ▒███   ▒▒███ █████ ████  ██████  ▒███     ▒███   ▒███   ▒███   ██████   ████████  ████████  ████   ██████  ████████   █████     ▒███    ▒███  █████ ████ ▒███████
    ▒███    ▒███▒▒███ ▒███  ███▒▒███ ▒███     ▒███   ▒███   ▒███  ▒▒▒▒▒███ ▒▒███▒▒███▒▒███▒▒███▒▒███  ███▒▒███▒▒███▒▒███ ███▒▒      ▒███████████ ▒▒███ ▒███  ▒███▒▒███
    ▒███    ▒███ ▒███ ▒███ ▒███████  ▒███     ▒▒███  █████  ███    ███████  ▒███ ▒▒▒  ▒███ ▒▒▒  ▒███ ▒███ ▒███ ▒███ ▒▒▒ ▒▒█████     ▒███▒▒▒▒▒███  ▒███ ▒███  ▒███ ▒███
    ▒███    ███  ▒███ ▒███ ▒███▒▒▒   ▒███      ▒▒▒█████▒█████▒    ███▒▒███  ▒███      ▒███      ▒███ ▒███ ▒███ ▒███      ▒▒▒▒███    ▒███    ▒███  ▒███ ▒███  ▒███ ▒███
    ██████████   ▒▒████████▒▒██████  █████       ▒▒███ ▒▒███     ▒▒████████ █████     █████     █████▒▒██████  █████     ██████     █████   █████ ▒▒████████ ████████
    ▒▒▒▒▒▒▒▒▒▒     ▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒  ▒▒▒▒▒         ▒▒▒   ▒▒▒       ▒▒▒▒▒▒▒▒ ▒▒▒▒▒     ▒▒▒▒▒     ▒▒▒▒▒  ▒▒▒▒▒▒  ▒▒▒▒▒     ▒▒▒▒▒▒     ▒▒▒▒▒   ▒▒▒▒▒   ▒▒▒▒▒▒▒▒ ▒▒▒▒▒▒▒▒

    -- Made by Nikoleto Scripts, if you encounter issues, open a ticket in the Discord server.
    GitHub: https://github.com/nikoladhima
    Discord: https://discord.gg/DsGCKtxxEN / @nikoleto._
]]

repeat task.wait() until game:IsLoaded()
if workspace.DistributedGameTime < 3 then
    task.wait(3 - workspace.DistributedGameTime)
end

local Running = true
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local clonerefFunction = cloneref or clone_ref or clonereference or clone_reference
local ns__cloneref = function(Object)
	if clonerefFunction then
		local Success, Result = pcall(clonerefFunction, Object)
		return Success and Result or Object
	end
	return Object
end

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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

local ESPDrawings = {}

local function GetESP(Player)
	local DrawingObject = ESPDrawings[Player]
	if not DrawingObject then
		DrawingObject = Drawing.new("Text")
		DrawingObject.Size = 16
		DrawingObject.Center = true
		DrawingObject.Outline = true
		DrawingObject.Visible = false
		ESPDrawings[Player] = DrawingObject
	end
	return DrawingObject
end

local function ClearESP(Player)
	local DrawingObject = ESPDrawings[Player]
	if DrawingObject then
		RemoveDrawing(DrawingObject)
		ESPDrawings[Player] = nil
	end
end

table.insert(Connections, Players.PlayerRemoving:Connect(ClearESP))

local LocalCharacter = nil
local LocalHumanoid = nil
local LocalHead = nil
local LocalRoot = nil
local SkillList = LocalPlayer:WaitForChild("PlayerGui", 9e9):WaitForChild("Lobby", 9e9):WaitForChild("UI_Skill", 9e9):WaitForChild("List", 9e9)
local FunctionFolder = workspace:WaitForChild("Scene", 9e9):WaitForChild("Function", 9e9)
local EventFolder = workspace:WaitForChild("Event", 9e9)
local ShopModuleRE = EventFolder:WaitForChild("ShopModule_RemoteEvent", 9e9)
local EquipmentRF = EventFolder:WaitForChild("Equipment_RemoteFunction", 9e9)
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

table.insert(Connections, RunService.Heartbeat:Connect(function(DeltaTime)
    if Configuration.FOVChanger then
        Camera.FieldOfView = Configuration.FOVValue
    end

    if Configuration.Speed and LocalHumanoid and LocalRoot then
        local MoveDirection = LocalHumanoid.MoveDirection
        if MoveDirection.Magnitude > 0 then
            LocalRoot.CFrame += MoveDirection * Configuration.SpeedAmount
        end
    end

    if LocalHumanoid and Configuration.AntiRagdoll and ((LocalHumanoid:GetState() == Enum.HumanoidStateType.Ragdoll) or (LocalHumanoid:GetState() == Enum.HumanoidStateType.FallingDown)) then
        LocalHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    if Configuration.Attaching then
        if not LocalRoot or not LocalPlayer:GetAttribute("InDuel") then
            return
        end

        local ClosestRoot = nil
        local BiggestDistance = 185
        for _,Player in ipairs(Players:GetPlayers()) do
            if Player == LocalPlayer then
                continue
            end

            if not Player:GetAttribute("InDuel") then
                continue
            end

            local Character = Player.Character
            if not Character then
                continue
            end

            local Root = GetRoot(Character)
            if not Root then
                continue
            end

            local Magnitude = (LocalRoot.Position - Root.Position).Magnitude
            if Magnitude < BiggestDistance then
                ClosestRoot = Root
                BiggestDistance = Magnitude
            end
        end

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

    for _,Player in ipairs(Players:GetPlayers()) do
        if Player == LocalPlayer then
            continue
        end

        local ESP = GetESP(Player)
        local IsVisible = nil

        local Character = Player.Character
        local Head = Character and Character:FindFirstChild("Head")
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

        if Configuration.ESPEnabled and Head and Humanoid and Humanoid.Health > 0 then
            local Screen, OnScreen = Camera:WorldToViewportPoint(Head.Position)
            if OnScreen then
                IsVisible = true

                local TextParts = {}
                if Configuration.ESPShowNames then
                    table.insert(TextParts, Player.DisplayName)
                end

                if Configuration.ESPShowHealth then
                    table.insert(TextParts, string.format("[%d HP]", math.floor(Humanoid.Health)))
                end

                if LocalRoot and Configuration.ESPShowDistance then
                    table.insert(TextParts, string.format("[%d M]", math.floor((LocalRoot.Position - Head.Position).Magnitude)))
                end

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
            ESP.Visible = false
        end
    end

    for Player in next, ESPDrawings do
        if Player.Parent ~= Players then
            ClearESP(Player)
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
    Title = "Speed Changer",
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

Tabs.Miscellaneous:AddParagraph({
    Title = "God Mode",
    Content = "If 'Deploying..' doesn't appear on ur character then make sure you haven't used or been in combat for around 15 seconds or more, God Mode will be automatically applied when possible."
})

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
    Content = "Welcome to Duel Warriors Hub!",
    Duration = 2.5
})

while true do
    if Library.Unloaded then
        Running = false

        for Index, Connection in next, Connections do
            Connection:Disconnect()
            Connections[Index] = nil
        end
        task.wait()

        if Configuration.GodMode then
            RunGodMode(false)
        end

        for Player in next, ESPDrawings do
            ClearESP(Player)
        end

        Camera.FieldOfView = 70
        break
    end
    task.wait(0.25)
end

if isfolder and makefolder and isfile and writefile then
    for _,Path in {"NikoletoScripts", "NikoletoScripts/DuelWarriorsHub", "NikoletoScripts/DuelWarriorsHub/Cache"} do
        pcall(function()
            if not isfolder(Path) then
                makefolder(Path)
            end
        end)
    end

    local Request = not isfile("NikoletoScripts/DuelWarriorsHub/Cache/Discord.nscache") and (httprequest or http_request or request)
    if Request then
        local HttpService = game:GetService("HttpService")
        if pcall(Request, {Url = "http://127.0.0.1:6463/rpc?v=1",  Method = "POST", Headers = {
            ["Content-Type"] = "application/json", Origin = "https://discord.com"
        }, Body = HttpService:JSONEncode({cmd = "INVITE_BROWSER", nonce = HttpService:GenerateGUID(false), args = {code = "DsGCKtxxEN"}})
        }) then
            writefile("NikoletoScripts/DuelWarriorsHub/Cache/Discord.nscache", "DsGCKtxxEN")
        end
    end
end
