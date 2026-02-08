local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "Fish It Hub | Cuta Syroo", HidePremium = false, SaveConfig = true, ConfigFolder = "FishItConfig"})

-- Services
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local AutoFish = false
local AutoShake = false
local Noclip = false
local FullBrightEnabled = false

-- Functions
local function ActivateTool()
    local Character = LocalPlayer.Character
    if Character then
        local Tool = Character:FindFirstChildOfClass("Tool")
        if Tool then
            Tool:Activate()
        end
    end
end

local function ClickGuiButton(Button)
    if Button and Button:IsA("GuiButton") and Button.Visible then
        -- Simulate click
        for _, v in pairs(getconnections(Button.MouseButton1Click)) do
            v:Fire()
        end
        -- Fallback if getconnections not supported or fails
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new())
    end
end

-- Smart Fishing Logic (Attempt to find common fishing GUIs)
task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoShake then
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if PlayerGui then
                -- Common names for fishing minigames in Roblox
                local Targets = {"shake", "reel", "button", "click", "cast", "pull", "catch", "interact", "fish"}
                for _, child in pairs(PlayerGui:GetDescendants()) do
                    if (child:IsA("ImageButton") or child:IsA("TextButton")) and child.Visible then
                        -- Check name match
                        local found = false
                        local lowerName = string.lower(child.Name)
                        for _, name in pairs(Targets) do
                            if string.find(lowerName, name) then
                                found = true
                                break
                            end
                        end
                        
                        -- Also check text content if it's a TextButton
                        if not found and child:IsA("TextButton") then
                            local lowerText = string.lower(child.Text)
                            for _, name in pairs(Targets) do
                                if string.find(lowerText, name) then
                                    found = true
                                    break
                                end
                            end
                        end

                        if found then
                            ClickGuiButton(child)
                        end
                    end
                end
            end
        end
    end
end)

-- Noclip Loop
RunService.Stepped:Connect(function()
    if Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Tabs
local MainTab = Window:MakeTab({
	Name = "Main",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local PlayerTab = Window:MakeTab({
	Name = "Player",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local MiscTab = Window:MakeTab({
	Name = "Misc",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- Main Features

MainTab:AddToggle({
	Name = "Auto Activate (Spam Click)",
	Default = false,
	Callback = function(Value)
		AutoFish = Value
        if Value then
            task.spawn(function()
                while AutoFish do
                    ActivateTool()
                    task.wait(0.2) 
                end
            end)
        end
	end
})

MainTab:AddToggle({
	Name = "Auto Shake/Reel (Smart GUI)",
	Default = false,
	Callback = function(Value)
		AutoShake = Value
	end
})

MainTab:AddParagraph("Cara Pakai", "1. Equip Pancingan.\n2. Aktifkan 'Auto Activate' untuk melempar.\n3. Jika game ada minigame GUI, aktifkan 'Auto Shake/Reel'.")

-- Player Features

PlayerTab:AddSlider({
	Name = "WalkSpeed",
	Min = 16,
	Max = 200,
	Default = 16,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "Speed",
	Callback = function(Value)
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
	end
})

PlayerTab:AddSlider({
	Name = "JumpPower",
	Min = 50,
	Max = 300,
	Default = 50,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "Jump",
	Callback = function(Value)
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
	end
})

PlayerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value)
        Noclip = Value
    end
})

-- Misc Features

MiscTab:AddToggle({
    Name = "FullBright",
    Default = false,
    Callback = function(Value)
        FullBrightEnabled = Value
        if Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            -- Reset (Approximate defaults)
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        end
    end
})

-- Anti AFK
LocalPlayer.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

OrionLib:Init()
