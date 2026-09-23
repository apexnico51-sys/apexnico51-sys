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

    -- Control de tiempo y estado estricto
    local lastParryTime = 0
    local cooldown = 0.35
    local parriedThisBall = false
    local prevDist = nil
    local prevTime = tick()

    RunService.RenderStepped:Connect(function()
        if not autoParryActive then return end
        
        local character = localPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        local rootPart = character.HumanoidRootPart
        
        local currentTime = tick()
        local dt = currentTime - prevTime
        if dt <= 0 then dt = 0.0001 end

        local targetBall = nil
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name == "Ball" or obj.Name:lower():find("ball")) then
                targetBall = obj
                break
            end
        end

        if targetBall then
            local currentDist = (rootPart.Position - targetBall.Position).Magnitude
            
            local speed = 0
            if prevDist then
                speed = math.abs(currentDist - prevDist) / dt
            end
            
            local isIncoming = prevDist and (currentDist < prevDist) or true
            
            -- Reiniciar cerrojo si la pelota se aleja
            if prevDist and currentDist > prevDist + 8 then
                parriedThisBall = false
            end
            
            local timeToImpact = 999.0
            if isIncoming and speed > 10 then
                timeToImpact = currentDist / speed
            end
            
            -- GATIGGO QUIRÚRGICO CALIBRADO PARA 81ms: 
            -- Solo actúa si el ETA es menor a 0.04 (muy cerca) o la distancia es de inminente colisión (<= 6.5 studs)
            local preciseTrigger = (isIncoming and timeToImpact <= 0.04 and speed > 50) or (currentDist <= 6.5)
            
            if preciseTrigger and not parriedThisBall and (currentTime - lastParryTime) >= cooldown then
                lastParryTime = currentTime
                parriedThisBall = true
                
                print("[Rocket Precision]: ¡Bloqueo ejecutado a quemarropa! Dist:", currentDist, "ETA:", timeToImpact)
                
                task.spawn(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    task.wait(0.04)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                end)
            end
            
            prevDist = currentDist
        else
            prevDist = nil
            parriedThisBall = false
        end
        
        prevTime = currentTime
    end)

    return Window
end

return Library
