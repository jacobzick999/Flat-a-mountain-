-- MOUNTAIN HUB V2 - STUDIO RADAR
-- Authorized Roblox Studio LocalScript for an experience you own or are allowed to edit.
-- Resource discovery is intentionally limited to instances tagged "RadarResource"
-- with a String attribute named "ResourceType". No unrestricted Workspace ESP,
-- remote calls, collection automation, or game-file modifications.

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local COLORS = {
    Diamond = Color3.fromRGB(80, 220, 255),
    Gold = Color3.fromRGB(255, 205, 45),
    Emerald = Color3.fromRGB(50, 220, 110),
    Ruby = Color3.fromRGB(255, 65, 75),
    Sapphire = Color3.fromRGB(65, 130, 255),
    Rare = Color3.fromRGB(190, 90, 255),
    Legendary = Color3.fromRGB(255, 145, 35),
    Default = Color3.fromRGB(235, 235, 235),
}
local RANGES = {100, 250, 500, 1000}
local rangeIndex = 4
local radarRadius = 105
local scanInterval = 0.35
local lastScan = 0
local tracked = {}

local old = playerGui:FindFirstChild("MountainHubV2")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "MountainHubV2"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(310, 430)
panel.Position = UDim2.new(0, 24, 0.22, 0)
panel.BackgroundColor3 = Color3.fromRGB(24, 27, 34)
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(70, 80, 100)
stroke.Thickness = 1
stroke.Parent = panel

local header = Instance.new("TextButton")
header.Size = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = Color3.fromRGB(35, 41, 52)
header.Text = "MOUNTAIN HUB V2     [−]"
header.TextColor3 = Color3.new(1, 1, 1)
header.Font = Enum.Font.GothamBold
header.TextSize = 14
header.Parent = panel
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local body = Instance.new("Frame")
body.Name = "Body"
body.Position = UDim2.fromOffset(0, 44)
body.Size = UDim2.new(1, 0, 1, -50)
body.BackgroundTransparency = 1
body.Parent = panel

local function label(parent, text, size, position, color)
    local obj = Instance.new("TextLabel")
    obj.BackgroundTransparency = 1
    obj.Size = size
    obj.Position = position
    obj.Text = text
    obj.TextColor3 = color or Color3.fromRGB(235, 238, 245)
    obj.Font = Enum.Font.Gotham
    obj.TextSize = 12
    obj.TextXAlignment = Enum.TextXAlignment.Left
    obj.Parent = parent
    return obj
end

local rangeLabel = label(body, "RADAR RANGE: 1000 STUDS", UDim2.new(1, -20, 0, 20), UDim2.fromOffset(12, 0))
local rangeRow = Instance.new("Frame")
rangeRow.BackgroundTransparency = 1
rangeRow.Position = UDim2.fromOffset(10, 22)
rangeRow.Size = UDim2.new(1, -20, 0, 30)
rangeRow.Parent = body

local function makeButton(parent, text, position, size)
    local b = Instance.new("TextButton")
    b.Position = position
    b.Size = size
    b.BackgroundColor3 = Color3.fromRGB(48, 57, 72)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 11
    b.AutoButtonColor = true
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

for i, range in ipairs(RANGES) do
    local b = makeButton(rangeRow, tostring(range), UDim2.new((i - 1) * 0.25, 2, 0, 0), UDim2.new(0.25, -5, 1, 0))
    b.MouseButton1Click:Connect(function()
        rangeIndex = i
        rangeLabel.Text = "RADAR RANGE: " .. range .. " STUDS"
    end)
end

local radar = Instance.new("Frame")
radar.Name = "Radar"
radar.Size = UDim2.fromOffset(radarRadius * 2, radarRadius * 2)
radar.Position = UDim2.new(0.5, -radarRadius, 0, 62)
radar.BackgroundColor3 = Color3.fromRGB(12, 16, 22)
radar.BackgroundTransparency = 0.05
radar.BorderSizePixel = 0
radar.ClipsDescendants = true
radar.Parent = body
Instance.new("UICorner", radar).CornerRadius = UDim.new(1, 0)
local radarStroke = Instance.new("UIStroke")
radarStroke.Color = Color3.fromRGB(75, 100, 125)
radarStroke.Thickness = 2
radarStroke.Parent = radar

local function ring(diameter)
    local f = Instance.new("Frame")
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Position = UDim2.fromScale(0.5, 0.5)
    f.Size = UDim2.fromOffset(diameter, diameter)
    f.BackgroundTransparency = 1
    f.Parent = radar
    Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(45, 58, 72)
    s.Thickness = 1
    s.Parent = f
end
ring(140)
ring(70)

local center = Instance.new("Frame")
center.AnchorPoint = Vector2.new(0.5, 0.5)
center.Position = UDim2.fromScale(0.5, 0.5)
center.Size = UDim2.fromOffset(7, 7)
center.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
center.BorderSizePixel = 0
center.Parent = radar
Instance.new("UICorner", center).CornerRadius = UDim.new(1, 0)

local status = label(body, "Waiting for tagged resources...", UDim2.new(1, -20, 0, 18), UDim2.fromOffset(12, 278), Color3.fromRGB(160, 205, 255))
status.TextXAlignment = Enum.TextXAlignment.Center

label(body, "Resource highlights", UDim2.new(1, -20, 0, 18), UDim2.fromOffset(12, 300))
local legend = label(body, "◆ Diamond   ◆ Gold   ◆ Emerald   ◆ Ruby", UDim2.new(1, -20, 0, 18), UDim2.fromOffset(12, 320))
legend.TextColor3 = Color3.fromRGB(190, 205, 225)
local legend2 = label(body, "◆ Sapphire   ◆ Rare   ◆ Legendary", UDim2.new(1, -20, 0, 18), UDim2.fromOffset(12, 340))
legend2.TextColor3 = Color3.fromRGB(190, 205, 225)
label(body, "Studio setup: tag resource Models/Parts as RadarResource", UDim2.new(1, -20, 0, 16), UDim2.fromOffset(12, 365), Color3.fromRGB(145, 155, 170))
label(body, 'Set String attribute "ResourceType" (e.g. Diamond)', UDim2.new(1, -20, 0, 16), UDim2.fromOffset(12, 382), Color3.fromRGB(145, 155, 170))

local function clearDots()
    for instance, data in pairs(tracked) do
        if data.dot then data.dot:Destroy() end
        if data.highlight then data.highlight:Destroy() end
        tracked[instance] = nil
    end
end

local function getPart(instance)
    if instance:IsA("BasePart") then return instance end
    if instance:IsA("Model") then
        return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
    end
    return nil
end

local function getResourceType(instance)
    local current = instance
    while current and current ~= workspace do
        local value = current:GetAttribute("ResourceType")
        if typeof(value) == "string" and value ~= "" then return value end
        current = current.Parent
    end
    return "Default"
end

local function colorFor(kind)
    local key = string.lower(kind)
    for name, color in pairs(COLORS) do
        if string.lower(name) == key then return color end
    end
    if string.find(key, "legend") then return COLORS.Legendary end
    if string.find(key, "rare") then return COLORS.Rare end
    return COLORS.Default
end

local function createMarker(instance, part, kind)
    local dot = Instance.new("Frame")
    dot.Name = "RadarDot"
    dot.AnchorPoint = Vector2.new(0.5, 0.5)
    dot.Size = UDim2.fromOffset(9, 9)
    dot.BackgroundColor3 = colorFor(kind)
    dot.BorderSizePixel = 0
    dot.Parent = radar
    Instance.new("UICorner", dot).CornerRadius = UDim.new(0, 2)

    local outline = Instance.new("UIStroke")
    outline.Color = Color3.new(1, 1, 1)
    outline.Thickness = 1
    outline.Parent = dot

    local highlight = Instance.new("Highlight")
    highlight.Name = "MountainHubResourceHighlight"
    highlight.Adornee = instance
    highlight.FillColor = colorFor(kind)
    highlight.OutlineColor = colorFor(kind)
    highlight.FillTransparency = 0.82
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Parent = instance

    tracked[instance] = {dot = dot, highlight = highlight, part = part, kind = kind}
end

local function scan()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        status.Text = "Waiting for character..."
        clearDots()
        return
    end

    local found = {}
    for _, instance in ipairs(CollectionService:GetTagged("RadarResource")) do
        if instance and instance:IsDescendantOf(workspace) then
            local part = getPart(instance)
            if part then
                local distance = (part.Position - root.Position).Magnitude
                if distance <= RANGES[rangeIndex] then
                    found[instance] = {part = part, distance = distance, kind = getResourceType(instance)}
                end
            end
        end
    end

    for instance, data in pairs(tracked) do
        if not found[instance] then
            if data.dot then data.dot:Destroy() end
            if data.highlight then data.highlight:Destroy() end
            tracked[instance] = nil
        end
    end

    local count = 0
    local camera = workspace.CurrentCamera
    local forward = root.CFrame.LookVector
    local right = root.CFrame.RightVector
    for instance, item in pairs(found) do
        count += 1
        if not tracked[instance] then
            createMarker(instance, item.part, item.kind)
        end
        local offset = item.part.Position - root.Position
        local x = offset:Dot(right) / RANGES[rangeIndex] * radarRadius
        local y = -offset:Dot(forward) / RANGES[rangeIndex] * radarRadius
        local magnitude = math.sqrt(x*x + y*y)
        if magnitude > radarRadius - 8 then
            local scale = (radarRadius - 8) / magnitude
            x, y = x * scale, y * scale
        end
        local dot = tracked[instance].dot
        dot.Position = UDim2.new(0.5, x, 0.5, y)

        local distanceLabel = dot:FindFirstChild("Distance")
        if not distanceLabel then
            distanceLabel = Instance.new("TextLabel")
            distanceLabel.Name = "Distance"
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.Position = UDim2.fromOffset(7, -6)
            distanceLabel.Size = UDim2.fromOffset(48, 14)
            distanceLabel.Font = Enum.Font.Gotham
            distanceLabel.TextSize = 9
            distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
            distanceLabel.TextColor3 = Color3.new(1, 1, 1)
            distanceLabel.Parent = dot
        end
        distanceLabel.Text = tostring(math.floor(item.distance)) .. "m"
    end
    status.Text = string.format("%d tagged resource(s) in range", count)
end

local collapsed = false
header.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    body.Visible = not collapsed
    panel.Size = collapsed and UDim2.fromOffset(310, 38) or UDim2.fromOffset(310, 430)
    header.Text = collapsed and "MOUNTAIN HUB V2     [+]" or "MOUNTAIN HUB V2     [−]"
end)

-- Drag panel by its header.
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

RunService.Heartbeat:Connect(function()
    if os.clock() - lastScan >= scanInterval then
        lastScan = os.clock()
        scan()
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    scan()
end)
