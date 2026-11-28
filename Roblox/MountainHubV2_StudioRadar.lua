-- MOUNTAIN HUB - BETTER RADAR V2
-- Authorized Roblox Studio LocalScript.
-- Visible Workspace objects only. No remotes, game-file edits, or collection automation.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("MountainHubV2")
if oldGui then oldGui:Destroy() end

local CONFIG = {
    Range = 1000,
    Refresh = 0.5,
    CollectionRadius = 25,
    ShowHighlights = true,
    ShowLabels = true,
    RadarSize = 220,
}

local RESOURCE_TYPES = {
    {Name = "Diamond", Color = Color3.fromRGB(0, 255, 255), Keys = {"diamond"}},
    {Name = "Gold", Color = Color3.fromRGB(255, 205, 0), Keys = {"gold"}},
    {Name = "Emerald", Color = Color3.fromRGB(0, 255, 90), Keys = {"emerald"}},
    {Name = "Ruby", Color = Color3.fromRGB(255, 55, 65), Keys = {"ruby"}},
    {Name = "Sapphire", Color = Color3.fromRGB(55, 135, 255), Keys = {"sapphire"}},
    {Name = "Rare Ore", Color = Color3.fromRGB(190, 80, 255), Keys = {"rare", "ore"}},
    {Name = "Legendary", Color = Color3.fromRGB(255, 145, 35), Keys = {"legendary"}},
}

local gui = Instance.new("ScreenGui")
gui.Name = "MountainHubV2"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(290, 410)
panel.Position = UDim2.new(0, 18, 0.25, 0)
panel.BackgroundColor3 = Color3.fromRGB(19, 23, 31)
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 190, 180)
stroke.Thickness = 1.5
stroke.Parent = panel

local header = Instance.new("TextButton")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = Color3.fromRGB(25, 43, 49)
header.BorderSizePixel = 0
header.Text = "MOUNTAIN HUB  •  BETTER RADAR V2"
header.TextColor3 = Color3.fromRGB(225, 255, 250)
header.TextSize = 13
header.Font = Enum.Font.GothamBold
header.Parent = panel
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local collapse = Instance.new("TextButton")
collapse.Size = UDim2.fromOffset(28, 26)
collapse.Position = UDim2.new(1, -33, 0, 6)
collapse.BackgroundColor3 = Color3.fromRGB(40, 65, 70)
collapse.Text = "−"
collapse.TextColor3 = Color3.new(1, 1, 1)
collapse.TextSize = 18
collapse.Font = Enum.Font.GothamBold
collapse.Parent = header
Instance.new("UICorner", collapse).CornerRadius = UDim.new(0, 6)

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(12, 45)
status.Size = UDim2.new(1, -24, 0, 20)
status.BackgroundTransparency = 1
status.Text = "Scanning visible Workspace resources..."
status.TextColor3 = Color3.fromRGB(155, 190, 190)
status.TextSize = 11
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = panel

local radar = Instance.new("Frame")
radar.Name = "Radar"
radar.Size = UDim2.fromOffset(CONFIG.RadarSize, CONFIG.RadarSize)
radar.Position = UDim2.new(0.5, -CONFIG.RadarSize / 2, 0, 72)
radar.BackgroundColor3 = Color3.fromRGB(9, 17, 23)
radar.BorderSizePixel = 0
radar.ClipsDescendants = true
radar.Parent = panel
Instance.new("UICorner", radar).CornerRadius = UDim.new(1, 0)
local radarStroke = Instance.new("UIStroke")
radarStroke.Color = Color3.fromRGB(0, 120, 125)
radarStroke.Thickness = 1.5
radarStroke.Parent = radar

local function makeRing(diameter, color, thickness, transparency)
    local ring = Instance.new("Frame")
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.Position = UDim2.fromScale(0.5, 0.5)
    ring.Size = UDim2.fromOffset(diameter, diameter)
    ring.BackgroundTransparency = 1
    ring.BorderSizePixel = 0
    ring.Parent = radar
    Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
    local line = Instance.new("UIStroke")
    line.Color = color
    line.Thickness = thickness
    line.Transparency = transparency or 0
    line.Parent = ring
    return ring
end

makeRing(CONFIG.RadarSize * 0.5, Color3.fromRGB(35, 75, 82), 1, 0.25)
makeRing(CONFIG.RadarSize * 0.75, Color3.fromRGB(35, 75, 82), 1, 0.35)
local collectionRing = makeRing(10, Color3.fromRGB(255, 190, 55), 2, 0.05)

local vertical = Instance.new("Frame")
vertical.AnchorPoint = Vector2.new(0.5, 0.5)
vertical.Position = UDim2.fromScale(0.5, 0.5)
vertical.Size = UDim2.new(0, 1, 0.9, 0)
vertical.BackgroundColor3 = Color3.fromRGB(40, 75, 80)
vertical.BorderSizePixel = 0
vertical.Parent = radar

local horizontal = Instance.new("Frame")
horizontal.AnchorPoint = Vector2.new(0.5, 0.5)
horizontal.Position = UDim2.fromScale(0.5, 0.5)
horizontal.Size = UDim2.new(0.9, 0, 0, 1)
horizontal.BackgroundColor3 = Color3.fromRGB(40, 75, 80)
horizontal.BorderSizePixel = 0
horizontal.Parent = radar

local center = Instance.new("Frame")
center.AnchorPoint = Vector2.new(0.5, 0.5)
center.Position = UDim2.fromScale(0.5, 0.5)
center.Size = UDim2.fromOffset(9, 9)
center.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
center.BorderSizePixel = 0
center.Parent = radar
Instance.new("UICorner", center).CornerRadius = UDim.new(1, 0)

local zoomRow = Instance.new("Frame")
zoomRow.Position = UDim2.fromOffset(12, 300)
zoomRow.Size = UDim2.new(1, -24, 0, 30)
zoomRow.BackgroundTransparency = 1
zoomRow.Parent = panel
local zoomLayout = Instance.new("UIListLayout")
zoomLayout.FillDirection = Enum.FillDirection.Horizontal
zoomLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
zoomLayout.Padding = UDim.new(0, 6)
zoomLayout.Parent = zoomRow

local zoomValues = {100, 250, 500, 1000}
local zoomButtons = {}
local function setZoom(value)
    CONFIG.Range = value
    for range, button in pairs(zoomButtons) do
        button.BackgroundColor3 = range == value and Color3.fromRGB(0, 145, 135) or Color3.fromRGB(38, 48, 58)
    end
end

for _, range in ipairs(zoomValues) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 58, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(38, 48, 58)
    button.Text = tostring(range)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 11
    button.Font = Enum.Font.GothamBold
    button.Parent = zoomRow
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
    zoomButtons[range] = button
    button.Activated:Connect(function() setZoom(range) end)
end
setZoom(CONFIG.Range)

local radiusText = Instance.new("TextLabel")
radiusText.Position = UDim2.fromOffset(12, 337)
radiusText.Size = UDim2.new(1, -24, 0, 18)
radiusText.BackgroundTransparency = 1
radiusText.TextColor3 = Color3.fromRGB(255, 205, 105)
radiusText.TextSize = 11
radiusText.Font = Enum.Font.Gotham
radiusText.TextXAlignment = Enum.TextXAlignment.Left
radiusText.Parent = panel

local legend = Instance.new("TextLabel")
legend.Position = UDim2.fromOffset(12, 359)
legend.Size = UDim2.new(1, -24, 0, 38)
legend.BackgroundTransparency = 1
legend.Text = "● Diamond  ● Gold  ● Emerald  ● Ruby\n● Sapphire  ● Rare  ● Legendary"
legend.TextColor3 = Color3.fromRGB(175, 195, 200)
legend.TextSize = 10
legend.Font = Enum.Font.Gotham
legend.TextWrapped = true
legend.Parent = panel

-- Drag the panel from its header; touch and mouse are both supported.
local dragging, dragInput, dragStart, startPosition
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)

local collapsed = false
collapse.Activated:Connect(function()
    collapsed = not collapsed
    for _, child in ipairs(panel:GetChildren()) do
        if child ~= header and child ~= stroke then child.Visible = not collapsed end
    end
    panel.Size = collapsed and UDim2.fromOffset(290, 38) or UDim2.fromOffset(290, 410)
    collapse.Text = collapsed and "+" or "−"
end)

-- Cache candidate BaseParts as the Workspace changes. This avoids a full
-- GetDescendants() traversal on every radar refresh.
local candidates = {}
local function addCandidate(instance)
    if instance:IsA("BasePart") then candidates[instance] = true end
end
local function removeCandidate(instance)
    candidates[instance] = nil
end
for _, instance in ipairs(Workspace:GetDescendants()) do addCandidate(instance) end
local addedConnection = Workspace.DescendantAdded:Connect(addCandidate)
local removingConnection = Workspace.DescendantRemoving:Connect(removeCandidate)

local function getResourceType(part)
    local current = part
    for _ = 1, 5 do
        if not current then break end
        local attribute = current:GetAttribute("ResourceType")
        if typeof(attribute) == "string" then
            local wanted = string.lower(attribute)
            for _, resource in ipairs(RESOURCE_TYPES) do
                if string.lower(resource.Name) == wanted then return resource end
            end
        end
        local name = string.lower(current.Name)
        for _, resource in ipairs(RESOURCE_TYPES) do
            for _, key in ipairs(resource.Keys) do
                if string.find(name, key, 1, true) then return resource end
            end
        end
        current = current.Parent
    end
    return nil
end

local dots = {}
local highlights = {}
local function clearVisuals()
    for part, dot in pairs(dots) do
        if dot then dot:Destroy() end
        dots[part] = nil
    end
    for part, highlight in pairs(highlights) do
        if highlight then highlight:Destroy() end
        highlights[part] = nil
    end
end

local function makeDot(part, color, distance)
    local dot = Instance.new("Frame")
    dot.Name = "ResourceDot"
    dot.AnchorPoint = Vector2.new(0.5, 0.5)
    dot.Size = UDim2.fromOffset(7, 7)
    dot.BackgroundColor3 = color
    dot.BorderSizePixel = 0
    dot.ZIndex = 5
    dot.Parent = radar
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    if CONFIG.ShowLabels then
        local label = Instance.new("TextLabel")
        label.Name = "Distance"
        label.AnchorPoint = Vector2.new(0.5, 0)
        label.Position = UDim2.new(0.5, 0, 1, 1)
        label.Size = UDim2.fromOffset(54, 13)
        label.BackgroundColor3 = Color3.fromRGB(8, 13, 18)
        label.BackgroundTransparency = 0.2
        label.Text = tostring(math.floor(distance + 0.5)) .. "m"
        label.TextColor3 = color
        label.TextSize = 9
        label.Font = Enum.Font.GothamBold
        label.ZIndex = 6
        label.Parent = dot
    end
    return dot
end

local function updateRadar()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        status.Text = "Waiting for character..."
        clearVisuals()
        return
    end

    local origin = root.Position
    local camera = Workspace.CurrentCamera
    local forward = camera and camera.CFrame.LookVector or root.CFrame.LookVector
    local right = camera and camera.CFrame.RightVector or root.CFrame.RightVector
    local half = CONFIG.RadarSize / 2
    local usableRadius = half - 9
    local found = {}
    local count = 0

    -- The collection radius is displayed as a correctly scaled radar ring.
    local collectionDiameter = math.clamp((CONFIG.CollectionRadius / CONFIG.Range) * usableRadius * 2, 4, usableRadius * 2)
    collectionRing.Size = UDim2.fromOffset(collectionDiameter, collectionDiameter)
    radiusText.Text = "Range: " .. CONFIG.Range .. " studs   |   Collection radius: " .. CONFIG.CollectionRadius

    for part in pairs(candidates) do
        if part.Parent and part:IsDescendantOf(Workspace) and part:IsA("BasePart") then
            local resource = getResourceType(part)
            if resource then
                local offset = part.Position - origin
                local distance = offset.Magnitude
                if distance <= CONFIG.Range then
                    found[part] = true
                    count += 1

                    local forwardDistance = offset:Dot(forward)
                    local sideDistance = offset:Dot(right)
                    local x = math.clamp(half + (sideDistance / CONFIG.Range) * usableRadius, 5, CONFIG.RadarSize - 5)
                    local y = math.clamp(half - (forwardDistance / CONFIG.Range) * usableRadius, 5, CONFIG.RadarSize - 5)

                    if not dots[part] then dots[part] = makeDot(part, resource.Color, distance) end
                    dots[part].Position = UDim2.fromOffset(x, y)
                    dots[part].BackgroundColor3 = resource.Color
                    local label = dots[part]:FindFirstChild("Distance")
                    if label then
                        label.Text = tostring(math.floor(distance + 0.5)) .. "m"
                        label.TextColor3 = resource.Color
                    end

                    if CONFIG.ShowHighlights then
                        local highlight = highlights[part]
                        if not highlight then
                            highlight = Instance.new("Highlight")
                            highlight.Name = "MountainHubResourceHighlight"
                            highlight.Adornee = part
                            -- Keep the outline bright while retaining the visible-only
                            -- depth mode, so objects behind walls are not revealed.
                            highlight.FillTransparency = 0.9
                            highlight.OutlineTransparency = 0
                            highlight.DepthMode = Enum.HighlightDepthMode.Occluded
                            highlight.Parent = gui
                            highlights[part] = highlight
                        end
                        -- Refresh colors in case an object's resource type changes.
                        highlight.FillColor = resource.Color
                        highlight.OutlineColor = resource.Color
                    end
                end
            end
        end
    end

    for part, dot in pairs(dots) do
        if not found[part] then
            dot:Destroy()
            dots[part] = nil
        end
    end
    for part, highlight in pairs(highlights) do
        if not found[part] then
            highlight:Destroy()
            highlights[part] = nil
        end
    end
    status.Text = "Visible resources: " .. count .. "   •   Updates every " .. CONFIG.Refresh .. "s"
end

local running = true
local elapsed = 0
local heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
    if not running or collapsed then return end
    elapsed += deltaTime
    if elapsed >= CONFIG.Refresh then
        elapsed = 0
        updateRadar()
    end
end)

gui.Destroying:Connect(function()
    running = false
    heartbeatConnection:Disconnect()
    addedConnection:Disconnect()
    removingConnection:Disconnect()
    clearVisuals()
end)

updateRadar()
