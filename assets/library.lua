local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local THEME = {
	Background = Color3.fromRGB(34, 34, 34),
	Secondary = Color3.fromRGB(28, 28, 28),
	Tertiary = Color3.fromRGB(38, 38, 38),
	Active = Color3.fromRGB(60, 60, 60),
	Accent = Color3.fromRGB(0, 120, 215),
	Text = Color3.fromRGB(230, 230, 230),
	SubText = Color3.fromRGB(180, 180, 180),
	Error = Color3.fromRGB(255, 80, 80),
	Success = Color3.fromRGB(0, 200, 80),
	Warning = Color3.fromRGB(255, 180, 40),
	Border = Color3.fromRGB(55, 55, 55),
	TitleBar = Color3.fromRGB(24, 24, 24),
	Console = Color3.fromRGB(20, 20, 20),
}

local tweenFast = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
local tweenMed  = TweenInfo.new(0.25, Enum.EasingStyle.Quad)
local tweenSlow = TweenInfo.new(0.35, Enum.EasingStyle.Quad)

local function tween(obj, props, info)
	TweenService:Create(obj, info or tweenFast, props):Play()
end

local function makeLabel(parent, text, size, color, font)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text or ""
	l.TextSize = size or 13
	l.TextColor3 = color or THEME.Text
	l.Font = font or Enum.Font.SourceSans
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Size = UDim2.new(1, 0, 1, 0)
	l.Parent = parent
	return l
end

local function makeStroke(parent, color)
	local s = Instance.new("UIStroke")
	s.Color = color or THEME.Border
	s.Thickness = 1
	s.Parent = parent
	return s
end

local function hsvToRgb(h, s, v)
	local r, g, b
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)
	i = i % 6
	if i == 0 then r,g,b = v,t,p
	elseif i == 1 then r,g,b = q,v,p
	elseif i == 2 then r,g,b = p,v,t
	elseif i == 3 then r,g,b = p,q,v
	elseif i == 4 then r,g,b = t,p,v
	elseif i == 5 then r,g,b = v,p,q
	end
	return Color3.new(r, g, b)
end

local function rgbToHsv(color)
	local r, g, b = color.R, color.G, color.B
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local delta = max - min
	local h, s, v = 0, 0, max
	if max ~= 0 then s = delta / max end
	if delta ~= 0 then
		if max == r then h = (g - b) / delta % 6
		elseif max == g then h = (b - r) / delta + 2
		else h = (r - g) / delta + 4
		end
		h = h / 6
	end
	return h, s, v
end

local notifGui = Instance.new("ScreenGui")
notifGui.Name = "LibraryNotifs"
notifGui.ResetOnSpawn = false
notifGui.DisplayOrder = 99999
notifGui.IgnoreGuiInset = true
notifGui.Parent = game:GetService("CoreGui")

local notifHolder = Instance.new("Frame")
notifHolder.Size = UDim2.new(0, 260, 1, 0)
notifHolder.Position = UDim2.new(1, -270, 0, 0)
notifHolder.BackgroundTransparency = 1
notifHolder.Parent = notifGui

local notifLayout = Instance.new("UIListLayout")
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Padding = UDim.new(0, 4)
notifLayout.Parent = notifHolder

local notifPad = Instance.new("UIPadding")
notifPad.PaddingBottom = UDim.new(0, 8)
notifPad.Parent = notifHolder

function Library.notify(title, message, notifType, duration)
	notifType = notifType or "info"
	duration = duration or 3

	local accentColor = ({
		info = THEME.Accent,
		success = THEME.Success,
		error = THEME.Error,
		warning = THEME.Warning,
	})[notifType] or THEME.Accent

	local icon = ({
		info = "[i]",
		success = "[+]",
		error = "[-]",
		warning = "[!]",
	})[notifType] or "[i]"

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(1, 0, 0, 56)
	notif.BackgroundColor3 = THEME.Secondary
	notif.Position = UDim2.new(1, 10, 0, 0)
	notif.Parent = notifHolder
	makeStroke(notif, THEME.Border)

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 2, 1, 0)
	bar.BackgroundColor3 = accentColor
	bar.BorderSizePixel = 0
	bar.Parent = notif

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0, 30, 0, 16)
	iconLabel.Position = UDim2.new(0, 10, 0, 8)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = icon
	iconLabel.TextColor3 = accentColor
	iconLabel.TextSize = 12
	iconLabel.Font = Enum.Font.Code
	iconLabel.TextXAlignment = Enum.TextXAlignment.Left
	iconLabel.Parent = notif

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -44, 0, 16)
	titleLabel.Position = UDim2.new(0, 40, 0, 8)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = THEME.Text
	titleLabel.TextSize = 13
	titleLabel.Font = Enum.Font.SourceSansSemibold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = notif

	local msgLabel = Instance.new("TextLabel")
	msgLabel.Size = UDim2.new(1, -44, 0, 24)
	msgLabel.Position = UDim2.new(0, 40, 0, 26)
	msgLabel.BackgroundTransparency = 1
	msgLabel.Text = message
	msgLabel.TextColor3 = THEME.SubText
	msgLabel.TextSize = 12
	msgLabel.Font = Enum.Font.SourceSans
	msgLabel.TextXAlignment = Enum.TextXAlignment.Left
	msgLabel.TextWrapped = true
	msgLabel.Parent = notif

	local progressBar = Instance.new("Frame")
	progressBar.Size = UDim2.new(1, 0, 0, 1)
	progressBar.Position = UDim2.new(0, 0, 1, -1)
	progressBar.BackgroundColor3 = accentColor
	progressBar.BorderSizePixel = 0
	progressBar.Parent = notif

	tween(notif, {Position = UDim2.new(0, 0, 0, 0)}, tweenMed)
	TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 1)}):Play()

	task.delay(duration, function()
		tween(notif, {Position = UDim2.new(1, 10, 0, 0)}, tweenMed)
		task.delay(0.25, function() notif:Destroy() end)
	end)
end

function Library.new(title, options)
	local self = setmetatable({}, Library)
	self.tabs = {}
	self.activeTab = nil
	options = options or {}

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "UILibrary"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 9999
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = game:GetService("CoreGui")

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 520, 0, 400)
	main.Position = UDim2.new(0.5, -260, 0.5, -200)
	main.BackgroundColor3 = THEME.Background
	main.BorderSizePixel = 0
	main.Parent = screenGui
	makeStroke(main, THEME.Border)

	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 34)
	titleBar.BackgroundColor3 = THEME.TitleBar
	titleBar.BorderSizePixel = 0
	titleBar.Parent = main

	local titleLabel = makeLabel(titleBar, title or "Library", 14, THEME.Text, Enum.Font.SourceSansSemibold)
	titleLabel.Size = UDim2.new(1, -80, 1, 0)
	titleLabel.Position = UDim2.new(0, 8, 0, 0)

	local function makeHeaderBtn(text, xOffset)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 36, 0, 22)
		btn.Position = UDim2.new(1, xOffset, 0, 6)
		btn.BackgroundColor3 = THEME.Tertiary
		btn.Text = text
		btn.TextColor3 = THEME.Text
		btn.TextSize = 13
		btn.Font = Enum.Font.SourceSans
		btn.AutoButtonColor = false
		btn.BorderSizePixel = 0
		btn.Parent = titleBar
		makeStroke(btn, THEME.Border)
		btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = THEME.Active}) end)
		btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = THEME.Tertiary}) end)
		return btn
	end

	local btnClose = makeHeaderBtn("X", -44)
	local btnMin   = makeHeaderBtn("_", -84)

	btnClose.MouseEnter:Connect(function() tween(btnClose, {TextColor3 = THEME.Error}) end)
	btnClose.MouseLeave:Connect(function() tween(btnClose, {TextColor3 = THEME.Text}) end)

	local minimized = false
	local fullSize = UDim2.new(0, 520, 0, 400)

	btnClose.MouseButton1Click:Connect(function()
		tween(main, {Size = UDim2.new(0, 520, 0, 0)}, tweenMed)
		task.delay(0.25, function() screenGui:Destroy() end)
	end)

	btnMin.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			tween(main, {Size = UDim2.new(0, 520, 0, 34)}, tweenMed)
		else
			tween(main, {Size = fullSize}, tweenMed)
		end
	end)

	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, 0, 0, 26)
	tabBar.Position = UDim2.new(0, 0, 0, 34)
	tabBar.BackgroundColor3 = THEME.Secondary
	tabBar.BorderSizePixel = 0
	tabBar.Parent = main
	makeStroke(tabBar, THEME.Border)

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Padding = UDim.new(0, 0)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabBar

	local contentArea = Instance.new("Frame")
	contentArea.Size = UDim2.new(1, 0, 1, -60)
	contentArea.Position = UDim2.new(0, 0, 0, 60)
	contentArea.BackgroundTransparency = 1
	contentArea.Parent = main

	self.screenGui = screenGui
	self.main = main
	self.tabBar = tabBar
	self.contentArea = contentArea

	tween(main, {Size = fullSize}, tweenMed)

	local dragging, dragStart, startPos
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	if options.toggleKey then
		UserInputService.InputBegan:Connect(function(input, gpe)
			if not gpe and input.KeyCode == options.toggleKey then
				screenGui.Enabled = not screenGui.Enabled
			end
		end)
	end

	return self
end

function Library:addTab(name)
	local tab = {}
	tab.name = name
	tab.elements = {}

	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(0, 0, 1, 0)
	tabBtn.AutomaticSize = Enum.AutomaticSize.X
	tabBtn.BackgroundColor3 = THEME.Secondary
	tabBtn.Text = name
	tabBtn.TextColor3 = THEME.SubText
	tabBtn.TextSize = 13
	tabBtn.Font = Enum.Font.SourceSans
	tabBtn.AutoButtonColor = false
	tabBtn.BorderSizePixel = 0
	tabBtn.LayoutOrder = #self.tabs + 1
	tabBtn.Parent = self.tabBar

	local tabPad = Instance.new("UIPadding")
	tabPad.PaddingLeft = UDim.new(0, 12)
	tabPad.PaddingRight = UDim.new(0, 12)
	tabPad.Parent = tabBtn

	local underline = Instance.new("Frame")
	underline.Size = UDim2.new(0, 0, 0, 2)
	underline.Position = UDim2.new(0.5, 0, 1, -2)
	underline.AnchorPoint = Vector2.new(0.5, 0)
	underline.BackgroundColor3 = THEME.Accent
	underline.BorderSizePixel = 0
	underline.Parent = tabBtn

	local tabContent = Instance.new("ScrollingFrame")
	tabContent.Size = UDim2.new(1, 0, 1, 0)
	tabContent.BackgroundTransparency = 1
	tabContent.BorderSizePixel = 0
	tabContent.ScrollBarThickness = 4
	tabContent.ScrollBarImageColor3 = THEME.Active
	tabContent.Visible = false
	tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabContent.Parent = self.contentArea

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.Padding = UDim.new(0, 0)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Parent = tabContent

	local contentPad = Instance.new("UIPadding")
	contentPad.PaddingTop = UDim.new(0, 6)
	contentPad.PaddingLeft = UDim.new(0, 8)
	contentPad.PaddingRight = UDim.new(0, 8)
	contentPad.PaddingBottom = UDim.new(0, 6)
	contentPad.Parent = tabContent

	tab.btn = tabBtn
	tab.content = tabContent
	tab.underline = underline

	tabBtn.MouseEnter:Connect(function()
		if self.activeTab ~= tab then
			tween(tabBtn, {TextColor3 = THEME.Text})
		end
	end)
	tabBtn.MouseLeave:Connect(function()
		if self.activeTab ~= tab then
			tween(tabBtn, {TextColor3 = THEME.SubText})
		end
	end)
	tabBtn.MouseButton1Click:Connect(function()
		self:switchTab(tab)
	end)

	table.insert(self.tabs, tab)
	if #self.tabs == 1 then
		self:switchTab(tab)
	end

	return tab
end

function Library:switchTab(targetTab)
	for _, tab in ipairs(self.tabs) do
		tab.content.Visible = false
		tween(tab.btn, {TextColor3 = THEME.SubText, BackgroundColor3 = THEME.Secondary})
		tween(tab.underline, {Size = UDim2.new(0, 0, 0, 2)})
	end
	targetTab.content.Visible = true
	tween(targetTab.btn, {TextColor3 = THEME.Text, BackgroundColor3 = THEME.Active})
	tween(targetTab.underline, {Size = UDim2.new(1, 0, 0, 2)}, tweenMed)
	self.activeTab = targetTab
end

function Library:addSection(tab, label)
	local section = Instance.new("Frame")
	section.Size = UDim2.new(1, 0, 0, 22)
	section.BackgroundColor3 = THEME.TitleBar
	section.BorderSizePixel = 0
	section.LayoutOrder = #tab.elements + 1
	section.Parent = tab.content
	makeStroke(section, THEME.Border)

	local topLine = Instance.new("Frame")
	topLine.Size = UDim2.new(0, 0, 0, 1)
	topLine.BackgroundColor3 = THEME.Accent
	topLine.BorderSizePixel = 0
	topLine.Parent = section
	tween(topLine, {Size = UDim2.new(1, 0, 0, 1)}, tweenSlow)

	makeLabel(section, "  " .. label, 11, THEME.SubText, Enum.Font.SourceSansSemibold)

	table.insert(tab.elements, section)
	return section
end

function Library:addButton(tab, label, desc, callback)
	if type(desc) == "function" then
		callback = desc
		desc = nil
	end

	local height = desc and 44 or 30

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, height)
	btn.BackgroundColor3 = THEME.Tertiary
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	btn.LayoutOrder = #tab.elements + 1
	btn.Parent = tab.content
	makeStroke(btn, THEME.Border)

	local lbl = makeLabel(btn, label, 13, THEME.Text, Enum.Font.SourceSans)
	lbl.Size = UDim2.new(1, -24, 0, 18)
	lbl.Position = UDim2.new(0, 8, 0, desc and 6 or 6)

	if desc then
		local descLbl = makeLabel(btn, desc, 11, THEME.SubText)
		descLbl.Size = UDim2.new(1, -24, 0, 14)
		descLbl.Position = UDim2.new(0, 8, 0, 24)
	end

	local flash = Instance.new("Frame")
	flash.Size = UDim2.new(1, 0, 1, 0)
	flash.BackgroundColor3 = Color3.new(1, 1, 1)
	flash.BackgroundTransparency = 1
	flash.BorderSizePixel = 0
	flash.ZIndex = 2
	flash.Parent = btn

	btn.MouseEnter:Connect(function()
		tween(btn, {BackgroundColor3 = THEME.Active})
		tween(lbl, {TextColor3 = Color3.new(1, 1, 1)})
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, {BackgroundColor3 = THEME.Tertiary})
		tween(lbl, {TextColor3 = THEME.Text})
	end)
	btn.MouseButton1Click:Connect(function()
		tween(flash, {BackgroundTransparency = 0.85}, tweenFast)
		tween(flash, {BackgroundTransparency = 1}, TweenInfo.new(0.3, Enum.EasingStyle.Quad))
		if callback then callback() end
	end)

	table.insert(tab.elements, btn)
	return btn
end

function Library:addToggle(tab, label, desc, default, callback)
	if type(desc) == "boolean" or (type(desc) == "nil" and type(default) == "function") then
		callback = default
		default = desc
		desc = nil
	end

	local state = default or false
	local height = desc and 44 or 30

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, height)
	row.BackgroundColor3 = THEME.Tertiary
	row.BorderSizePixel = 0
	row.LayoutOrder = #tab.elements + 1
	row.Parent = tab.content
	makeStroke(row, THEME.Border)

	local lbl = makeLabel(row, label, 13, THEME.Text)
	lbl.Size = UDim2.new(1, -60, 0, 18)
	lbl.Position = UDim2.new(0, 8, 0, desc and 6 or 6)

	if desc then
		local descLbl = makeLabel(row, desc, 11, THEME.SubText)
		descLbl.Size = UDim2.new(1, -60, 0, 14)
		descLbl.Position = UDim2.new(0, 8, 0, 24)
	end

	local box = Instance.new("Frame")
	box.Size = UDim2.new(0, 16, 0, 16)
	box.Position = UDim2.new(1, -28, 0.5, -8)
	box.BackgroundColor3 = state and THEME.Accent or THEME.Background
	box.BorderSizePixel = 0
	box.Parent = row
	makeStroke(box, state and THEME.Accent or THEME.Border)

	local check = makeLabel(box, "✓", 12, Color3.new(1,1,1), Enum.Font.SourceSansBold)
	check.TextXAlignment = Enum.TextXAlignment.Center
	check.BackgroundTransparency = 1
	check.Size = UDim2.new(1, 0, 1, 0)
	check.TextTransparency = state and 0 or 1

	local clickArea = Instance.new("TextButton")
	clickArea.Size = UDim2.new(1, 0, 1, 0)
	clickArea.BackgroundTransparency = 1
	clickArea.Text = ""
	clickArea.Parent = row

	local toggle = {}
	toggle.value = state

	function toggle:set(val)
		state = val
		toggle.value = val
		local stroke = box:FindFirstChildOfClass("UIStroke")
		tween(box, {BackgroundColor3 = val and THEME.Accent or THEME.Background})
		if stroke then tween(stroke, {Color = val and THEME.Accent or THEME.Border}) end
		tween(check, {TextTransparency = val and 0 or 1})
		if callback then callback(val) end
	end

	row.MouseEnter:Connect(function() tween(row, {BackgroundColor3 = THEME.Active}) end)
	row.MouseLeave:Connect(function() tween(row, {BackgroundColor3 = THEME.Tertiary}) end)
	clickArea.MouseButton1Click:Connect(function() toggle:set(not state) end)

	table.insert(tab.elements, row)
	return toggle
end

function Library:addSlider(tab, label, desc, config, callback)
	if type(desc) == "table" then
		callback = config
		config = desc
		desc = nil
	end

	local min = config.min or 0
	local max = config.max or 100
	local default = config.default or min
	local suffix = config.suffix or ""
	local value = default
	local height = desc and 52 or 44

	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, height)
	container.BackgroundColor3 = THEME.Tertiary
	container.BorderSizePixel = 0
	container.LayoutOrder = #tab.elements + 1
	container.Parent = tab.content
	makeStroke(container, THEME.Border)

	local lbl = makeLabel(container, label, 13, THEME.Text)
	lbl.Size = UDim2.new(1, -70, 0, 18)
	lbl.Position = UDim2.new(0, 8, 0, desc and 5 or 4)

	if desc then
		local descLbl = makeLabel(container, desc, 11, THEME.SubText)
		descLbl.Size = UDim2.new(1, -70, 0, 14)
		descLbl.Position = UDim2.new(0, 8, 0, 22)
	end

	local valLabel = makeLabel(container, tostring(value) .. suffix, 12, THEME.Accent, Enum.Font.Code)
	valLabel.Size = UDim2.new(0, 58, 0, 18)
	valLabel.Position = UDim2.new(1, -66, 0, desc and 5 or 4)
	valLabel.TextXAlignment = Enum.TextXAlignment.Right

	local trackBg = Instance.new("Frame")
	trackBg.Size = UDim2.new(1, -16, 0, 4)
	trackBg.Position = UDim2.new(0, 8, 1, -14)
	trackBg.BackgroundColor3 = THEME.Background
	trackBg.BorderSizePixel = 0
	trackBg.Parent = container
	makeStroke(trackBg, THEME.Border)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = THEME.Accent
	fill.BorderSizePixel = 0
	fill.Parent = trackBg

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 8, 0, 12)
	knob.Position = UDim2.new((value - min) / (max - min), -4, 0.5, -6)
	knob.BackgroundColor3 = Color3.new(1, 1, 1)
	knob.BorderSizePixel = 0
	knob.ZIndex = 2
	knob.Parent = trackBg

	local draggingSlider = false

	local function updateSlider(inputX)
		local trackPos = trackBg.AbsolutePosition.X
		local trackSize = trackBg.AbsoluteSize.X
		local relative = math.clamp((inputX - trackPos) / trackSize, 0, 1)
		value = math.floor(min + (max - min) * relative)
		valLabel.Text = tostring(value) .. suffix
		tween(fill, {Size = UDim2.new(relative, 0, 1, 0)})
		tween(knob, {Position = UDim2.new(relative, -4, 0.5, -6)})
		if callback then callback(value) end
	end

	trackBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = true
			updateSlider(input.Position.X)
			tween(knob, {Size = UDim2.new(0, 10, 0, 14)})
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and draggingSlider then
			draggingSlider = false
			tween(knob, {Size = UDim2.new(0, 8, 0, 12)})
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateSlider(input.Position.X)
		end
	end)

	local slider = {}
	slider.value = value
	function slider:set(val)
		value = math.clamp(val, min, max)
		slider.value = value
		local relative = (value - min) / (max - min)
		valLabel.Text = tostring(value) .. suffix
		tween(fill, {Size = UDim2.new(relative, 0, 1, 0)})
		tween(knob, {Position = UDim2.new(relative, -4, 0.5, -6)})
		if callback then callback(value) end
	end

	table.insert(tab.elements, container)
	return slider
end

function Library:addDropdown(tab, label, desc, options, default, callback)
	if type(desc) == "table" then
		callback = default
		default = options
		options = desc
		desc = nil
	end

	local selected = default or options[1] or "Select..."
	local open = false

	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 30)
	container.BackgroundColor3 = THEME.Tertiary
	container.BorderSizePixel = 0
	container.LayoutOrder = #tab.elements + 1
	container.ClipsDescendants = false
	container.ZIndex = 10
	container.Parent = tab.content
	makeStroke(container, THEME.Border)

	local lbl = makeLabel(container, label, 13, THEME.Text)
	lbl.Size = UDim2.new(0.5, -8, 0, 30)
	lbl.Position = UDim2.new(0, 8, 0, 0)

	local selectedLabel = makeLabel(container, selected, 12, THEME.SubText, Enum.Font.Code)
	selectedLabel.Size = UDim2.new(0.5, -28, 0, 30)
	selectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
	selectedLabel.TextXAlignment = Enum.TextXAlignment.Right

	local arrow = makeLabel(container, "v", 11, THEME.SubText, Enum.Font.Code)
	arrow.Size = UDim2.new(0, 20, 0, 30)
	arrow.Position = UDim2.new(1, -22, 0, 0)
	arrow.TextXAlignment = Enum.TextXAlignment.Center

	local clickArea = Instance.new("TextButton")
	clickArea.Size = UDim2.new(1, 0, 0, 30)
	clickArea.BackgroundTransparency = 1
	clickArea.Text = ""
	clickArea.ZIndex = 11
	clickArea.Parent = container

	local dropdown = Instance.new("Frame")
	dropdown.Size = UDim2.new(1, 0, 0, 0)
	dropdown.Position = UDim2.new(0, 0, 1, 1)
	dropdown.BackgroundColor3 = THEME.Secondary
	dropdown.BorderSizePixel = 0
	dropdown.Visible = false
	dropdown.ZIndex = 20
	dropdown.ClipsDescendants = true
	dropdown.Parent = container
	makeStroke(dropdown, THEME.Border)

	local ddLayout = Instance.new("UIListLayout")
	ddLayout.Padding = UDim.new(0, 0)
	ddLayout.Parent = dropdown

	local function closeDropdown()
		open = false
		tween(dropdown, {Size = UDim2.new(1, 0, 0, 0)}, tweenFast)
		tween(arrow, {TextTransparency = 0})
		arrow.Text = "v"
		task.delay(0.15, function() if not open then dropdown.Visible = false end end)
	end

	local function openDropdown()
		open = true
		dropdown.Visible = true
		tween(dropdown, {Size = UDim2.new(1, 0, 0, #options * 24)}, tweenFast)
		arrow.Text = "^"
	end

	for _, option in ipairs(options) do
		local optBtn = Instance.new("TextButton")
		optBtn.Size = UDim2.new(1, 0, 0, 24)
		optBtn.BackgroundColor3 = option == selected and THEME.Active or THEME.Secondary
		optBtn.Text = "  " .. option
		optBtn.TextColor3 = option == selected and THEME.Text or THEME.SubText
		optBtn.TextSize = 12
		optBtn.Font = Enum.Font.SourceSans
		optBtn.TextXAlignment = Enum.TextXAlignment.Left
		optBtn.AutoButtonColor = false
		optBtn.BorderSizePixel = 0
		optBtn.ZIndex = 21
		optBtn.Parent = dropdown

		optBtn.MouseEnter:Connect(function()
			if option ~= selected then tween(optBtn, {BackgroundColor3 = THEME.Tertiary}) end
		end)
		optBtn.MouseLeave:Connect(function()
			if option ~= selected then tween(optBtn, {BackgroundColor3 = THEME.Secondary}) end
		end)
		optBtn.MouseButton1Click:Connect(function()
			selected = option
			selectedLabel.Text = option
			for _, child in ipairs(dropdown:GetChildren()) do
				if child:IsA("TextButton") then
					tween(child, {BackgroundColor3 = THEME.Secondary, TextColor3 = THEME.SubText})
				end
			end
			tween(optBtn, {BackgroundColor3 = THEME.Active, TextColor3 = THEME.Text})
			closeDropdown()
			if callback then callback(option) end
		end)
	end

	container.MouseEnter:Connect(function() tween(container, {BackgroundColor3 = THEME.Active}) end)
	container.MouseLeave:Connect(function() tween(container, {BackgroundColor3 = THEME.Tertiary}) end)
	clickArea.MouseButton1Click:Connect(function()
		if open then closeDropdown() else openDropdown() end
	end)

	table.insert(tab.elements, container)

	local dd = {}
	dd.value = selected
	function dd:set(val)
		selected = val
		selectedLabel.Text = val
		dd.value = val
	end
	return dd
end

function Library:addInput(tab, label, desc, placeholder, callback)
	if type(desc) == "string" and not placeholder then
		placeholder = desc
		desc = nil
	end

	local height = desc and 52 or 42

	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, height)
	container.BackgroundColor3 = THEME.Tertiary
	container.BorderSizePixel = 0
	container.LayoutOrder = #tab.elements + 1
	container.Parent = tab.content
	makeStroke(container, THEME.Border)

	local lbl = makeLabel(container, label, 13, THEME.Text)
	lbl.Size = UDim2.new(1, -16, 0, 18)
	lbl.Position = UDim2.new(0, 8, 0, desc and 4 or 4)

	if desc then
		local descLbl = makeLabel(container, desc, 11, THEME.SubText)
		descLbl.Size = UDim2.new(1, -16, 0, 14)
		descLbl.Position = UDim2.new(0, 8, 0, 20)
	end

	local inputBox = Instance.new("TextBox")
	inputBox.Size = UDim2.new(1, -16, 0, 20)
	inputBox.Position = UDim2.new(0, 8, 1, -26)
	inputBox.BackgroundColor3 = THEME.Background
	inputBox.PlaceholderText = placeholder or "Enter value..."
	inputBox.PlaceholderColor3 = THEME.SubText
	inputBox.Text = ""
	inputBox.TextColor3 = THEME.Text
	inputBox.TextSize = 12
	inputBox.Font = Enum.Font.Code
	inputBox.ClearTextOnFocus = false
	inputBox.TextXAlignment = Enum.TextXAlignment.Left
	inputBox.BorderSizePixel = 0
	inputBox.Parent = container
	local inputStroke = makeStroke(inputBox, THEME.Border)

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 6)
	pad.Parent = inputBox

	inputBox.Focused:Connect(function()
		tween(inputStroke, {Color = THEME.Accent})
		tween(container, {BackgroundColor3 = THEME.Active})
	end)
	inputBox.FocusLost:Connect(function(entered)
		tween(inputStroke, {Color = THEME.Border})
		tween(container, {BackgroundColor3 = THEME.Tertiary})
		if entered and callback then callback(inputBox.Text) end
	end)

	table.insert(tab.elements, container)
	return inputBox
end

function Library:addKeybind(tab, label, desc, default, callback)
	if type(desc) == "userdata" or type(desc) == "nil" then
		callback = default
		default = desc
		desc = nil
	end

	local bound = default or Enum.KeyCode.Unknown
	local listening = false

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, desc and 44 or 30)
	row.BackgroundColor3 = THEME.Tertiary
	row.BorderSizePixel = 0
	row.LayoutOrder = #tab.elements + 1
	row.Parent = tab.content
	makeStroke(row, THEME.Border)

	local lbl = makeLabel(row, label, 13, THEME.Text)
	lbl.Size = UDim2.new(1, -100, 0, 18)
	lbl.Position = UDim2.new(0, 8, 0, desc and 5 or 6)

	if desc then
		local descLbl = makeLabel(row, desc, 11, THEME.SubText)
		descLbl.Size = UDim2.new(1, -100, 0, 14)
		descLbl.Position = UDim2.new(0, 8, 0, 24)
	end

	local keyBtn = Instance.new("TextButton")
	keyBtn.Size = UDim2.new(0, 80, 0, 20)
	keyBtn.Position = UDim2.new(1, -88, 0.5, -10)
	keyBtn.BackgroundColor3 = THEME.Background
	keyBtn.Text = "[" .. bound.Name .. "]"
	keyBtn.TextColor3 = THEME.SubText
	keyBtn.TextSize = 11
	keyBtn.Font = Enum.Font.Code
	keyBtn.AutoButtonColor = false
	keyBtn.BorderSizePixel = 0
	keyBtn.Parent = row
	local keyStroke = makeStroke(keyBtn, THEME.Border)

	keyBtn.MouseButton1Click:Connect(function()
		if listening then return end
		listening = true
		keyBtn.Text = "[...]"
		tween(keyBtn, {TextColor3 = THEME.Accent})
		tween(keyStroke, {Color = THEME.Accent})
	end)

	row.MouseEnter:Connect(function() tween(row, {BackgroundColor3 = THEME.Active}) end)
	row.MouseLeave:Connect(function() tween(row, {BackgroundColor3 = THEME.Tertiary}) end)

	UserInputService.InputBegan:Connect(function(input, gpe)
		if listening and input.UserInputType == Enum.UserInputType.Keyboard then
			listening = false
			bound = input.KeyCode
			keyBtn.Text = "[" .. bound.Name .. "]"
			tween(keyBtn, {TextColor3 = THEME.SubText})
			tween(keyStroke, {Color = THEME.Border})
		elseif not listening and not gpe and input.KeyCode == bound then
			if callback then callback() end
		end
	end)

	table.insert(tab.elements, row)
	return keyBtn
end

-- ONLY the addColorPicker function was fixed

function Library:addColorPicker(tab, label, desc, default, callback)
	if type(desc) == "userdata" then
		callback = default
		default = desc
		desc = nil
	end

	local color = default or Color3.fromRGB(0, 120, 215)
	local h, s, v = rgbToHsv(color)
	local open = false
	local PICKER_SIZE = 160

	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 30)
	container.BackgroundColor3 = THEME.Tertiary
	container.BorderSizePixel = 0
	container.LayoutOrder = #tab.elements + 1
	container.ZIndex = 5
	container.Parent = tab.content
	makeStroke(container, THEME.Border)

	local lbl = makeLabel(container, label, 13, THEME.Text)
	lbl.Size = UDim2.new(1, -60, 0, 30)
	lbl.Position = UDim2.new(0, 8, 0, 0)

	local preview = Instance.new("Frame")
	preview.Size = UDim2.new(0, 36, 0, 16)
	preview.Position = UDim2.new(1, -44, 0.5, -8)
	preview.BackgroundColor3 = color
	preview.BorderSizePixel = 0
	preview.ZIndex = 6
	preview.Parent = container
	makeStroke(preview, THEME.Border)

	local pickerFrame = Instance.new("Frame")
	pickerFrame.Size = UDim2.new(0, PICKER_SIZE + 20, 0, PICKER_SIZE + 60)
	pickerFrame.BackgroundColor3 = THEME.Secondary
	pickerFrame.BorderSizePixel = 0
	pickerFrame.ZIndex = 999
	pickerFrame.Visible = false
	pickerFrame.Parent = self.screenGui
	makeStroke(pickerFrame, THEME.Border)

	local function updatePosition()
		local pos = container.AbsolutePosition
		local size = container.AbsoluteSize
		pickerFrame.Position = UDim2.new(0, pos.X + size.X - PICKER_SIZE, 0, pos.Y + size.Y + 4)
	end

	local wheelContainer = Instance.new("Frame")
	wheelContainer.Size = UDim2.new(0, PICKER_SIZE, 0, PICKER_SIZE)
	wheelContainer.Position = UDim2.new(0, 10, 0, 10)
	wheelContainer.BackgroundTransparency = 1
	wheelContainer.Parent = pickerFrame

	local SEGMENTS = 36
	local CENTER = PICKER_SIZE / 2
	local OUTER_R = CENTER
	local INNER_R = CENTER - 18

	for i = 1, SEGMENTS do
		local seg = Instance.new("Frame")
		local angle = (i - 1) / SEGMENTS * math.pi * 2
		local midAngle = angle + (math.pi / SEGMENTS)

		local cx = CENTER + math.cos(midAngle) * ((OUTER_R + INNER_R)/2)
		local cy = CENTER + math.sin(midAngle) * ((OUTER_R + INNER_R)/2)

		seg.Size = UDim2.new(0, 20, 0, 20)
		seg.Position = UDim2.new(0, cx - 10, 0, cy - 10)
		seg.BackgroundColor3 = hsvToRgb((i-1)/SEGMENTS,1,1)
		seg.BorderSizePixel = 0
		seg.Parent = wheelContainer
	end

	local svBox = Instance.new("Frame")
	svBox.Size = UDim2.new(0, INNER_R*2-20, 0, INNER_R*2-20)
	svBox.Position = UDim2.new(0, CENTER-(INNER_R-10), 0, CENTER-(INNER_R-10))
	svBox.Parent = wheelContainer

	local function applyColor()
		color = hsvToRgb(h,s,v)
		preview.BackgroundColor3 = color
		if callback then callback(color) end
	end

	local draggingHue, draggingSv = false, false

	local function handleHue(input)
		local center = wheelContainer.AbsolutePosition + Vector2.new(CENTER,CENTER)
		local delta = input.Position - center
		local angle = math.atan2(delta.Y, delta.X)
		if angle < 0 then angle = angle + math.pi*2 end
		h = angle/(math.pi*2)
		applyColor()
	end

	local function handleSV(input)
		local pos = svBox.AbsolutePosition
		local size = svBox.AbsoluteSize
		s = math.clamp((input.Position.X-pos.X)/size.X,0,1)
		v = 1-math.clamp((input.Position.Y-pos.Y)/size.Y,0,1)
		applyColor()
	end

	wheelContainer.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then
			draggingHue=true
			handleHue(i)
		end
	end)

	svBox.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then
			draggingSv=true
			handleSV(i)
		end
	end)

	UserInputService.InputChanged:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseMovement then
			if draggingHue then handleHue(i) end
			if draggingSv then handleSV(i) end
		end
	end)

	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then
			draggingHue=false
			draggingSv=false
		end
	end)

	local clickArea = Instance.new("TextButton")
	clickArea.Size = UDim2.new(1,0,1,0)
	clickArea.BackgroundTransparency = 1
	clickArea.Text = ""
	clickArea.Parent = container

	clickArea.MouseButton1Click:Connect(function()
		open = not open
		if open then
			updatePosition()
			pickerFrame.Visible = true
		else
			pickerFrame.Visible = false
		end
	end)

	table.insert(tab.elements, container)
end
function Library:addLabel(tab, text)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 24)
	frame.BackgroundColor3 = THEME.Console
	frame.BorderSizePixel = 0
	frame.LayoutOrder = #tab.elements + 1
	frame.Parent = tab.content
	makeStroke(frame, THEME.Border)

	local lbl = makeLabel(frame, "  " .. text, 12, THEME.SubText, Enum.Font.Code)
	lbl.Size = UDim2.new(1, 0, 1, 0)

	table.insert(tab.elements, frame)
	return lbl
end

function Library:addSeparator(tab)
	local sep = Instance.new("Frame")
	sep.Size = UDim2.new(1, 0, 0, 1)
	sep.BackgroundColor3 = THEME.Border
	sep.BorderSizePixel = 0
	sep.LayoutOrder = #tab.elements + 1
	sep.Parent = tab.content
	table.insert(tab.elements, sep)
	return sep
end

return Library
