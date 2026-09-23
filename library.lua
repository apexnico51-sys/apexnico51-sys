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

    -- VARIABLES DE CONTROL ESTRICTO (Puerto exacto de tu lógica en Python)
    local lastParryTime = 0
    local cooldown = 0.35 -- Cooldown estricto para evitar spam
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

        -- Buscador de la pelota en Blade Ball
        local ballsFolder = workspace:FindFirstChild("Balls")
        if not ballsFolder then return end
        
        local foundBall = false
        for _, ball in ipairs(ballsFolder:GetChildren()) do
            if ball:IsA("BasePart") then
                foundBall = true
                local currentDist = (rootPart.Position - ball.Position).Magnitude
                
                -- Velocidad de aproximación 3D (equivalente al flujo óptico)
                local speed = 0
                if prevDist then
                    speed = math.abs(currentDist - prevDist) / dt
                end
                
                local isIncoming = prevDist and (currentDist < prevDist) or true
                
                -- Si la pelota se alejó bastante, abrimos de nuevo el permiso de bloqueo
                if prevDist and currentDist > prevDist + 5 then
                    parriedThisBall = false
                end
                
                -- Cálculo de Tiempo de Impacto (ETA)
                local timeToImpact = 999.0
                if isIncoming and speed > 5 then
                    timeToImpact = currentDist / speed
                end
                
                -- Gatillo Quirúrgico adaptado a 81ms (ETA < 0.14 o Distancia de emergencia <= 3.5)
                local preciseTrigger = (isIncoming and timeToImpact < 0.14) or (currentDist <= 3.5)
                
                if preciseTrigger and not parriedThisBall and (currentTime - lastParryTime) >= cooldown then
                    lastParryTime = currentTime
                    parriedThisBall = true
                    
                    print("[Rocket Pro]: ¡Parry ejecutado! Distancia:", currentDist, "ETA:", timeToImpact)
                    
                    -- Simulación limpia de la tecla F para el bloqueo
                    task.spawn(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                        task.wait(0.04)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                    end)
                end
                
                prevDist = currentDist
            end
        end

        if not foundBall then
            prevDist = nil
            parriedThisBall = false
        end
        
        prevTime = currentTime
    end)

    return Window
end

return Library
