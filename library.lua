local Library = {}
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
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

    -- Bucle de rastreo global optimizado para Blade Ball
    RunService.RenderStepped:Connect(function()
        if not autoParryActive then return end
        
        local character = localPlayer.Character
        if not character then return end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        -- Buscamos en todo el workspace cualquier parte que tenga el nombre de la pelota o propiedades físicas activas
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name == "Ball" or obj.Name == "bola" or obj.Name:lower():find("ball")) then
                local distance = (rootPart.Position - obj.Position).Magnitude
                
                -- Distancia de emergencia directa para tus 81ms
                if distance <= 4.0 then
                    print("[Rocket]: ¡Bloqueo forzado por distancia! Dist:", distance)
                    task.spawn(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                        task.wait(0.04)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                    end)
                    task.wait(0.2) -- Breve pausa interna para evitar bucle de pulsación en el mismo frame
                end
            end
        end
    end)

    return Window
end

return Library
