local Library = {}
local CoreGui = game:GetService("CoreGui")

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
            pcall(callback)
        end)
    end

    return Window
end

return Library
