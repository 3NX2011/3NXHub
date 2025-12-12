local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Library:CreateWindow(title)
    local Window = {}
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "3NXHub"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -400, 0.5, -250)
    MainFrame.Size = UDim2.new(0, 800, 0, 500)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Sidebar.BorderSizePixel = 0
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 10)
    SidebarCorner.Parent = Sidebar
    
    local SidebarCover = Instance.new("Frame")
    SidebarCover.Parent = Sidebar
    SidebarCover.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SidebarCover.BorderSizePixel = 0
    SidebarCover.Position = UDim2.new(1, -10, 0, 0)
    SidebarCover.Size = UDim2.new(0, 10, 1, 0)
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = Sidebar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 0, 0, 10)
    TitleLabel.Size = UDim2.new(1, 0, 0, 40)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Sidebar
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 10, 0, 60)
    TabContainer.Size = UDim2.new(1, -20, 1, -70)
    TabContainer.ScrollBarThickness = 4
    TabContainer.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabContainer
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 210, 0, 10)
    ContentFrame.Size = UDim2.new(1, -220, 1, -20)
    
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    function Window:CreateTab(name, icon)
        local Tab = {}
        
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name
        TabButton.Parent = TabContainer
        TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 0, 40)
        TabButton.Font = Enum.Font.Gotham
        TabButton.Text = "  " .. name
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.TextSize = 14
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.AutoButtonColor = false
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = name .. "Page"
        TabPage.Parent = ContentFrame
        TabPage.BackgroundTransparency = 1
        TabPage.BorderSizePixel = 0
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.Visible = false
        TabPage.ScrollBarThickness = 6
        TabPage.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = TabPage
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 10)
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                tab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
                tab.Page.Visible = false
            end
            
            TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabPage.Visible = true
            Window.CurrentTab = Tab
        end)
        
        Tab.Button = TabButton
        Tab.Page = TabPage
        Tab.Elements = {}
        
        function Tab:CreateSection(name)
            local Section = {}
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = name
            SectionFrame.Parent = TabPage
            SectionFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Size = UDim2.new(1, 0, 0, 50)
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 8)
            SectionCorner.Parent = SectionFrame
            
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Parent = SectionFrame
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Position = UDim2.new(0, 15, 0, 10)
            SectionLabel.Size = UDim2.new(1, -30, 0, 30)
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.Text = name
            SectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            SectionLabel.TextSize = 16
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local ElementContainer = Instance.new("Frame")
            ElementContainer.Name = "ElementContainer"
            ElementContainer.Parent = SectionFrame
            ElementContainer.BackgroundTransparency = 1
            ElementContainer.Position = UDim2.new(0, 15, 0, 45)
            ElementContainer.Size = UDim2.new(1, -30, 1, -50)
            
            local ElementLayout = Instance.new("UIListLayout")
            ElementLayout.Parent = ElementContainer
            ElementLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ElementLayout.Padding = UDim.new(0, 8)
            
            ElementLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, ElementLayout.AbsoluteContentSize.Y + 55)
            end)
            
            Section.Container = ElementContainer
            
            function Section:CreateToggle(name, default, callback)
                callback = callback or function() end
                local toggled = default or false
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = name
                ToggleFrame.Parent = ElementContainer
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
                
                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Parent = ToggleFrame
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
                ToggleLabel.Font = Enum.Font.Gotham
                ToggleLabel.Text = name
                ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                ToggleLabel.TextSize = 13
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Parent = ToggleFrame
                ToggleButton.BackgroundColor3 = toggled and Color3.fromRGB(60, 150, 255) or Color3.fromRGB(40, 40, 40)
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Position = UDim2.new(1, -40, 0.5, -10)
                ToggleButton.Size = UDim2.new(0, 40, 0, 20)
                ToggleButton.Text = ""
                ToggleButton.AutoButtonColor = false
                
                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(1, 0)
                ToggleCorner.Parent = ToggleButton
                
                local ToggleCircle = Instance.new("Frame")
                ToggleCircle.Parent = ToggleButton
                ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ToggleCircle.BorderSizePixel = 0
                ToggleCircle.Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
                
                local CircleCorner = Instance.new("UICorner")
                CircleCorner.CornerRadius = UDim.new(1, 0)
                CircleCorner.Parent = ToggleCircle
                
                ToggleButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    
                    local colorTween = TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = toggled and Color3.fromRGB(60, 150, 255) or Color3.fromRGB(40, 40, 40)
                    })
                    
                    local positionTween = TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
                        Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                    })
                    
                    colorTween:Play()
                    positionTween:Play()
                    
                    callback(toggled)
                end)
                
                return ToggleFrame
            end
            
            function Section:CreateButton(name, callback)
                callback = callback or function() end
                
                local ButtonFrame = Instance.new("Frame")
                ButtonFrame.Name = name
                ButtonFrame.Parent = ElementContainer
                ButtonFrame.BackgroundTransparency = 1
                ButtonFrame.Size = UDim2.new(1, 0, 0, 35)
                
                local Button = Instance.new("TextButton")
                Button.Parent = ButtonFrame
                Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                Button.BorderSizePixel = 0
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.Font = Enum.Font.Gotham
                Button.Text = name
                Button.TextColor3 = Color3.fromRGB(220, 220, 220)
                Button.TextSize = 13
                Button.AutoButtonColor = false
                
                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, 6)
                ButtonCorner.Parent = Button
                
                Button.MouseEnter:Connect(function()
                    TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
                end)
                
                Button.MouseLeave:Connect(function()
                    TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                end)
                
                Button.MouseButton1Click:Connect(function()
                    callback()
                end)
                
                return ButtonFrame
            end
            
            function Section:CreateSlider(name, min, max, default, callback)
                callback = callback or function() end
                local value = default or min
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = name
                SliderFrame.Parent = ElementContainer
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Size = UDim2.new(1, 0, 0, 50)
                
                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Parent = SliderFrame
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Size = UDim2.new(1, -60, 0, 20)
                SliderLabel.Font = Enum.Font.Gotham
                SliderLabel.Text = name
                SliderLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                SliderLabel.TextSize = 13
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local SliderValue = Instance.new("TextLabel")
                SliderValue.Parent = SliderFrame
                SliderValue.BackgroundTransparency = 1
                SliderValue.Position = UDim2.new(1, -60, 0, 0)
                SliderValue.Size = UDim2.new(0, 60, 0, 20)
                SliderValue.Font = Enum.Font.GothamBold
                SliderValue.Text = tostring(value)
                SliderValue.TextColor3 = Color3.fromRGB(60, 150, 255)
                SliderValue.TextSize = 13
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                
                local SliderBack = Instance.new("Frame")
                SliderBack.Parent = SliderFrame
                SliderBack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                SliderBack.BorderSizePixel = 0
                SliderBack.Position = UDim2.new(0, 0, 0, 28)
                SliderBack.Size = UDim2.new(1, 0, 0, 6)
                
                local SliderBackCorner = Instance.new("UICorner")
                SliderBackCorner.CornerRadius = UDim.new(1, 0)
                SliderBackCorner.Parent = SliderBack
                
                local SliderFill = Instance.new("Frame")
                SliderFill.Parent = SliderBack
                SliderFill.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
                SliderFill.BorderSizePixel = 0
                SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                
                local SliderFillCorner = Instance.new("UICorner")
                SliderFillCorner.CornerRadius = UDim.new(1, 0)
                SliderFillCorner.Parent = SliderFill
                
                local SliderDot = Instance.new("Frame")
                SliderDot.Parent = SliderBack
                SliderDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderDot.BorderSizePixel = 0
                SliderDot.Position = UDim2.new((value - min) / (max - min), -8, 0.5, -8)
                SliderDot.Size = UDim2.new(0, 16, 0, 16)
                
                local SliderDotCorner = Instance.new("UICorner")
                SliderDotCorner.CornerRadius = UDim.new(1, 0)
                SliderDotCorner.Parent = SliderDot
                
                local dragging = false
                
                SliderBack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local percent = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
                        value = math.floor(min + (max - min) * percent)
                        
                        SliderValue.Text = tostring(value)
                        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                        SliderDot.Position = UDim2.new(percent, -8, 0.5, -8)
                        
                        callback(value)
                    end
                end)
                
                return SliderFrame
            end
            
            function Section:CreateDropdown(name, options, default, callback)
                callback = callback or function() end
                local selected = default or options[1] or ""
                local open = false
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Name = name
                DropdownFrame.Parent = ElementContainer
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Size = UDim2.new(1, 0, 0, 60)
                DropdownFrame.ClipsDescendants = true
                
                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Parent = DropdownFrame
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Size = UDim2.new(1, 0, 0, 20)
                DropdownLabel.Font = Enum.Font.Gotham
                DropdownLabel.Text = name
                DropdownLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                DropdownLabel.TextSize = 13
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Parent = DropdownFrame
                DropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Position = UDim2.new(0, 0, 0, 25)
                DropdownButton.Size = UDim2.new(1, 0, 0, 30)
                DropdownButton.Font = Enum.Font.Gotham
                DropdownButton.Text = "  " .. selected
                DropdownButton.TextColor3 = Color3.fromRGB(220, 220, 220)
                DropdownButton.TextSize = 13
                DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
                DropdownButton.AutoButtonColor = false
                
                local DropdownCorner = Instance.new("UICorner")
                DropdownCorner.CornerRadius = UDim.new(0, 6)
                DropdownCorner.Parent = DropdownButton
                
                local Arrow = Instance.new("TextLabel")
                Arrow.Parent = DropdownButton
                Arrow.BackgroundTransparency = 1
                Arrow.Position = UDim2.new(1, -30, 0, 0)
                Arrow.Size = UDim2.new(0, 30, 1, 0)
                Arrow.Font = Enum.Font.GothamBold
                Arrow.Text = "▼"
                Arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
                Arrow.TextSize = 10
                
                local OptionsList = Instance.new("ScrollingFrame")
                OptionsList.Parent = DropdownFrame
                OptionsList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                OptionsList.BorderSizePixel = 0
                OptionsList.Position = UDim2.new(0, 0, 0, 60)
                OptionsList.Size = UDim2.new(1, 0, 0, 0)
                OptionsList.ScrollBarThickness = 4
                OptionsList.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
                OptionsList.Visible = false
                OptionsList.CanvasSize = UDim2.new(0, 0, 0, 0)
                
                local OptionsCorner = Instance.new("UICorner")
                OptionsCorner.CornerRadius = UDim.new(0, 6)
                OptionsCorner.Parent = OptionsList
                
                local OptionsLayout = Instance.new("UIListLayout")
                OptionsLayout.Parent = OptionsList
                OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptionsLayout.Padding = UDim.new(0, 2)
                
                for _, option in ipairs(options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Parent = OptionsList
                    OptionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    OptionButton.BorderSizePixel = 0
                    OptionButton.Size = UDim2.new(1, 0, 0, 28)
                    OptionButton.Font = Enum.Font.Gotham
                    OptionButton.Text = "  " .. option
                    OptionButton.TextColor3 = Color3.fromRGB(220, 220, 220)
                    OptionButton.TextSize = 13
                    OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                    OptionButton.AutoButtonColor = false
                    
                    local OptionCorner = Instance.new("UICorner")
                    OptionCorner.CornerRadius = UDim.new(0, 4)
                    OptionCorner.Parent = OptionButton
                    
                    OptionButton.MouseEnter:Connect(function()
                        TweenService:Create(OptionButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        TweenService:Create(OptionButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        selected = option
                        DropdownButton.Text = "  " .. selected
                        callback(selected)
                        
                        open = false
                        OptionsList.Visible = false
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 60)}):Play()
                        TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                    end)
                end
                
                OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    OptionsList.CanvasSize = UDim2.new(0, 0, 0, OptionsLayout.AbsoluteContentSize.Y + 5)
                end)
                
                DropdownButton.MouseButton1Click:Connect(function()
                    open = not open
                    OptionsList.Visible = open
                    
                    local dropdownHeight = math.min(#options * 30, 120)
                    
                    if open then
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 65 + dropdownHeight)}):Play()
                        TweenService:Create(OptionsList, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, dropdownHeight)}):Play()
                        TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
                    else
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 60)}):Play()
                        TweenService:Create(OptionsList, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                    end
                end)
                
                return DropdownFrame
            end
            
            function Section:CreateTextbox(name, placeholder, callback)
                callback = callback or function() end
                
                local TextboxFrame = Instance.new("Frame")
                TextboxFrame.Name = name
                TextboxFrame.Parent = ElementContainer
                TextboxFrame.BackgroundTransparency = 1
                TextboxFrame.Size = UDim2.new(1, 0, 0, 60)
                
                local TextboxLabel = Instance.new("TextLabel")
                TextboxLabel.Parent = TextboxFrame
                TextboxLabel.BackgroundTransparency = 1
                TextboxLabel.Size = UDim2.new(1, 0, 0, 20)
                TextboxLabel.Font = Enum.Font.Gotham
                TextboxLabel.Text = name
                TextboxLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                TextboxLabel.TextSize = 13
                TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local Textbox = Instance.new("TextBox")
                Textbox.Parent = TextboxFrame
                Textbox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                Textbox.BorderSizePixel = 0
                Textbox.Position = UDim2.new(0, 0, 0, 25)
                Textbox.Size = UDim2.new(1, 0, 0, 30)
                Textbox.Font = Enum.Font.Gotham
                Textbox.PlaceholderText = placeholder
                Textbox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
                Textbox.Text = ""
                Textbox.TextColor3 = Color3.fromRGB(220, 220, 220)
                Textbox.TextSize = 13
                Textbox.TextXAlignment = Enum.TextXAlignment.Left
                
                local TextboxCorner = Instance.new("UICorner")
                TextboxCorner.CornerRadius = UDim.new(0, 6)
                TextboxCorner.Parent = Textbox
                
                local TextboxPadding = Instance.new("UIPadding")
                TextboxPadding.Parent = Textbox
                TextboxPadding.PaddingLeft = UDim.new(0, 10)
                TextboxPadding.PaddingRight = UDim.new(0, 10)
                
                Textbox.FocusLost:Connect(function(enter)
                    if enter then
                        callback(Textbox.Text)
                    end
                end)
                
                return TextboxFrame
            end
            
            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabPage.Visible = true
            Window.CurrentTab = Tab
        end
        
        TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
        end)
        
        return Tab
    end
    
    return Window
end

return Library