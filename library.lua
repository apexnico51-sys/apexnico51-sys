local Library = {}
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

function Library:CreateWindow(titleText)
    if CoreGui:FindFirstChild("RocketCustomHub") then
        CoreGui.RocketCustomHub:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RocketCustomHub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 210, 0, 140)
    MainFrame.Position = UDim2.new(1, -220, 1, -150)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = titleText or "ROCKET (81ms)"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 13
    Title.Parent = MainFrame

    local Window = {}
    local autoParryActive = true

    function Window:AddButton(buttonText, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0, 190, 0, 35)
        Button.Position = UDim2.new(0, 10, 0, 35)
        Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Button.TextColor3 = Color3.fromRGB(0, 255, 128)
        Button.Text = buttonText
        Button.Font = Enum.Font.SourceSansBold
        Button.TextSize = 12
        Button.Parent = MainFrame

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = Button

        Button.MouseButton1Click:Connect(function()
            autoParryActive = not autoParryActive
            if autoParryActive then
                Button.Text = "Auto Parry: [ ACTIVADO ]"
            else
                Button.Text = "Auto Parry: [ DESACTIVADO ]"
            end
            pcall(callback, autoParryActive)
        end)
    end

    -- Núcleo de Auto Parry por 81ms (Distancia de emergencia 3.5)
    RunService.RenderStepped:Connect(function()
        if not autoParryActive then return end
        
        local character = localPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local ballsFolder = workspace:FindFirstChild("Balls")
        if not ballsFolder then return end
        
        for _, ball in ipairs(ballsFolder:GetChildren()) do
            if ball:IsA("BasePart") then
                local distance = (character.HumanoidRootPart.Position - ball.Position).Magnitude
                if distance <= 3.5 then
                    task.spawn(function()
                        local vim = game:GetService("VirtualInputManager")
                        vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                        task.wait(0.05)
                        vim:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                    end)
                end
            end
        end
    end)

    return Window
end

return Library
