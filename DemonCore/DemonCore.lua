DemonCore = {}

DemonCore.version = "1.1"

local LuaPath = GetLuaModsPath()
local ModulePath = LuaPath .. [[DemonCore\]]
local ImageFolder = ModulePath .. [[Images\]]

DemonCore.GUI = {
    open = false,
    visible = true,
}

DemonCore.Settings = {
	DrawHotbar = true,
	SageHotbarButColOn = {
		R = 25/255,
		G = 125/255,
		B = 0/255,
		T = 255/255,
	},
	SageHotbarButColOff = {
		R = 100/255,
		G = 100/255,
		B = 100/255,
		T = 255/255,
	},
	SageHotbarButtonSizeX = 100,
	SageHotbarButtonSizeY = 30,
	SageHotbarColumns = 1,
	SageHotbarLocked = false,
	SageHotbarEnabled = true,
	SageHotbar = {
			Heal = {
				index = 1,
				name = "Heal",
				visible = true,
				bool = true,
				menu = "Heal",
				tooltip = "Enable/Disable All Heals",
			},
			OGCD = {
				index = 2,
				name = "Heal (oGCD)",
				visible = true,
				bool = true,
				menu = "Heal (oGCD)",
				tooltip = "Enable/Disable oGCD Heals",
			},
			Esuna = {
				index = 3,
				name = "Esuna",
				visible = true,
				bool = true,
				menu = "Esuna",
				tooltip = "Enable/Disable Esuna",
			},
			Kerachole = {
				index = 4,
				name = "Kerachole",
				visible = true,
				bool = true,
				menu = "Kerachole",
				tooltip = "Enable/Disable Kerachole",
			},
			Preshield = {
				index = 5,
				name = "Preshield",
				visible = true,
				bool = true,
				menu = "Preshield",
				tooltip = "Enable/disable shielding tank during dungeons to build toxicon",
		},
	},
}

local MinionPath = GetStartupPath()
local LuaPath = GetLuaModsPath()
local ModulePath = LuaPath .. [[DemonCore\]]
local ModuleSettings = ModulePath .. [[Settings.lua]]

local v = table.valid
function DemonCore.valid(...)
	local tbl = {...}
	local size = #tbl
	if size > 0 then
		local count = tbl[1]
		if type(count) == "number" then
			if size == (count + 1) then
				for i = 2, size do
					if not v(tbl[i]) then return false end
				end
				return true
			end
		else
			for i = 1, size do
				if not v(tbl[i]) then return false end
			end
			return true
		end
	end
	return false
end
local valid = DemonCore.valid

function DemonCore.LoadSettings()
	local tbl = FileLoad(ModuleSettings)
	if tbl == nil then
		local file = io.open(ModulePath..'Settings.lua', 'w')
		file:close()
	end
	local function scan(tbl,tbl2,depth)
		depth = depth or 0
		if valid(2,tbl,tbl2) then
			for k,v in pairs(tbl2) do
				if type(v) == "table" then
					if tbl[k] and valid(tbl[k]) then
						tbl[k] = table.merge(tbl[k],scan(tbl[k],v,depth+1))
					else
						tbl[k] = v
					end
				else
					if tbl[k] ~= tbl2[k] then tbl[k] = tbl2[k] end
				end
			end
		end
		return tbl
	end
	DemonCore.Settings = scan(DemonCore.Settings,tbl)
end

function DemonCore.save(force)
	if (force or TimeSince(lastcheck) > 30000) then
		lastcheck = Now()
		local base = table.deepcopy(DemonCore.Settings)
		for k, v in pairs(base) do
			if k == "SageHotbar" then
				for m,n in pairs(v) do
					n.name = nil
					n.index = nil
					n.menu = nil
					n.tooltip = nil
				end
			end
		end
		if not table.deepcompare(base,PreviousSave) then
			local tbl = FileLoad(ModuleSettings)
			if tbl == nil then
				local file = io.open(ModulePath..'Settings.lua', 'w')
				file:close()
			end
			FileSave(ModuleSettings,base)
			PreviousSave = table.deepcopy(base)
		end
	end
end
local save = DemonCore.save

function DemonCore.log(string)
    d("[DemonCore] " .. string)
end

function DemonCore.Init()
	local MainIcon = ImageFolder .. [[DemonIcon.png]]
    DemonCore.log("Initializing DemonCore v" .. tostring(DemonCore.version))
    ml_gui.ui_mgr:AddMember({ id = "FFXIVMINION##MENU_DemonCore", name = "DemonCore", onClick = function() DemonCore.GUI.open = not DemonCore.GUI.open end,  texture = MainIcon},"FFXIVMINION##MENU_HEADER")
	DemonCore.LoadSettings()
end

function DemonCore.DrawCall()
	local gamestate = GetGameState()
    if (gamestate == FFXIV.GAMESTATE.INGAME) and not Player.onlinestatus ~= 15 then
		if (DemonCore.GUI.open) then
			local WindowSizeX,WindowSizeY = 400,450
			local SubWindowSizeX,SubWindowSizeY = 350,450
			local Style = GUI:GetStyle()
			local windowPadding = Style.windowpadding
			GUI:SetNextWindowSize(WindowSizeX, WindowSizeY, GUI.SetCond_Always)
			DemonCore.GUI.visible, DemonCore.GUI.open = GUI:Begin("DemonCore v" .. tostring(DemonCore.version), DemonCore.GUI.open, GUI.WindowFlags_NoResize + GUI.WindowFlags_AlwaysUseWindowPadding + GUI.WindowFlags_NoCollapse)
			GUI:SetWindowFontSize(1.05)
			if (DemonCore.GUI.visible) then
				local Str = "Hotbar Customization:"
				local StrLength = GUI:CalcTextSize(Str)
				GUI:TextColored(0.5, 0.7, 1, 1, Str)
				GUI:NextColumn()
				GUI:Separator()
				local Str = "Enable Hotbar"
				local StrLength = GUI:CalcTextSize(Str)
				GUI:Text(Str)
				GUI:SameLine(0,SubWindowSizeX - windowPadding.x - StrLength - 15)
				DemonCore.Settings.SageHotbarEnabled,changed = GUI:Checkbox("##SageHotbarEnabled", DemonCore.Settings.SageHotbarEnabled)
				if changed then
					save(true)
				end
				GUI:NextColumn()
				
				GUI:Separator()
				local Str = "Lock Hotbar"
				local StrLength = GUI:CalcTextSize(Str)
				GUI:Text(Str)
				GUI:SameLine(0,SubWindowSizeX - windowPadding.x - StrLength - 15)
				DemonCore.Settings.SageHotbarLocked,changed = GUI:Checkbox("##SageHotbarLocked", DemonCore.Settings.SageHotbarLocked)
				if changed then
					save(true)
				end
				GUI:NextColumn()
				
				-- Enabled
				GUI:Separator()
				local settings = DemonCore.Settings.SageHotbarButColOn 
				settings.R,settings.G,settings.B,settings.T,changed = GUI:ColorEdit4("Enabled##SageHotbar",settings.R, settings.G, settings.B, settings.T)
				if changed then
					save(true)
				end
				GUI:NextColumn()
				
				-- Disabled
				GUI:Separator()
				local settings = DemonCore.Settings.SageHotbarButColOff 
				settings.R,settings.G,settings.B,settings.T,changed = GUI:ColorEdit4("Disabled##SageHotbar",settings.R, settings.G, settings.B, settings.T)
				if changed then
					save(true)
				end
				GUI:NextColumn()

				-- Size X
				GUI:Separator()
				local Str = "Button Width"
				local StrLength = GUI:CalcTextSize(Str)
				GUI:Text(Str)
				GUI:SameLine(0,SubWindowSizeX - windowPadding.x - StrLength - 95)
				GUI:PushItemWidth(100)
				DemonCore.Settings.SageHotbarButtonSizeX,changed = GUI:InputFloat("##SageHotbarButtonSizeX", DemonCore.Settings.SageHotbarButtonSizeX,1,2,0)
				GUI:PopItemWidth()
				if changed then
					save(true)
				end
				GUI:NextColumn()	
				
				-- Size Y
				GUI:Separator()
				local Str = "Button Height"
				local StrLength = GUI:CalcTextSize(Str)
				GUI:Text(Str)
				GUI:SameLine(0,SubWindowSizeX - windowPadding.x - StrLength - 95)
				GUI:PushItemWidth(100)
				DemonCore.Settings.SageHotbarButtonSizeY,changed = GUI:InputFloat("##SageHotbarButtonSizeY", DemonCore.Settings.SageHotbarButtonSizeY,1,2,0)
				GUI:PopItemWidth()
				if changed then
					save(true)
				end
				GUI:NextColumn()	
				
				-- Column
				GUI:Separator()
				local Str = "Columns"
				local StrLength = GUI:CalcTextSize(Str)
				GUI:Text(Str)
				GUI:SameLine(0,SubWindowSizeX - windowPadding.x - StrLength - 95)
				GUI:PushItemWidth(100)
				DemonCore.Settings.SageHotbarColumns,changed = GUI:InputFloat("##SageHotbarColumns", DemonCore.Settings.SageHotbarColumns,1,1,0)
				GUI:PopItemWidth()
				if changed then
					save(true)
				end
				GUI:NextColumn()
				-- Hotbar Buttons
				GUI:Text("")
				GUI:NextColumn()
				local Str = "Hotbar Buttons:"
				local StrLength = GUI:CalcTextSize(Str)
				GUI:TextColored(0.5, 0.7, 1, 1, Str)
				GUI:NextColumn()
				local count
				local Hotbar = {}
				for k,v in pairs(DemonCore.Settings.SageHotbar) do
					table.insert(Hotbar, v)
				end
				table.sort(Hotbar, function(a,b) return a.index < b.index end)
				for m,n in ipairs(Hotbar) do
					GUI:Separator()
					local StrLength = GUI:CalcTextSize(n.menu)
					GUI:Text(n.menu)
					if (GUI:IsItemHovered()) then
						GUI:SetTooltip("Adds a "..tostring(n.menu).." toggle to the Hotbar")
					end
					GUI:SameLine(0,5)
					local NewStr = string.gsub(n.name, " ", "")
					n.visible,changed = GUI:Checkbox("##SageHotbar"..tostring(NewStr).."Visible", n.visible)
					if changed then
						save(true)
					end
					GUI:NextColumn()
				end
				GUI:End()
			end
		end	
		
		if (DemonCore.Settings.DrawHotbar) then
			local GeneralProfile = TensorCore.API.TensorReactions.getGeneralReactionProfileName()
			if (Player.Job == 40) then		
				if DemonCore.Settings.SageHotbarEnabled then
					if GeneralProfile ~= nil and string.find(GeneralProfile, "demon", 1, true) and string.find(GeneralProfile, "sagemode", 1, true) then
						GUI:SetNextWindowSize(200,200,GUI.SetCond_FirstUseEver)
						GUI:Begin("DemonSageHotbar", true, (function() if DemonCore.Settings.SageHotbarLocked then
						return GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoScrollWithMouse + GUI.WindowFlags_NoCollapse + GUI.WindowFlags_AlwaysAutoResize + GUI.WindowFlags_NoMove
						else
						return GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoScrollWithMouse + GUI.WindowFlags_NoCollapse + GUI.WindowFlags_AlwaysAutoResize
				end end)())
				local Hotbar = {}
				for m,n in pairs(DemonCore.Settings.SageHotbar) do
					if n.visible then
						table.insert(Hotbar, n)
					end
				end
				table.sort(Hotbar, function(a,b) return a.index < b.index end)
				local count
				if count == nil then count = 0 end
					for k,v in pairs(Hotbar) do
						local settingsOn = DemonCore.Settings.SageHotbarButColOn 
						local settingsOff = DemonCore.Settings.SageHotbarButColOff
						local r,g,b,t = (function() if v.bool == true then return settingsOn.R, settingsOn.G, settingsOn.B, settingsOn.T else return settingsOff.R, settingsOff.G, settingsOff.B, settingsOff.T end end)()
						local butx,buty = DemonCore.Settings.SageHotbarButtonSizeX,DemonCore.Settings.SageHotbarButtonSizeY
						GUI:PushStyleVar(GUI.StyleVar_ChildWindowRounding,5)
						GUI:PushStyleColor(GUI.Col_ChildWindowBg, r, g, b, t)
						if count % DemonCore.Settings.SageHotbarColumns ~= 0 then GUI:SameLine(0,5) end
							GUI:BeginChild("##SageButton"..tostring(k), butx, buty, false, GUI.WindowFlags_NoSavedSettings + GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoScrollWithMouse)
							count = count + 1
							local x,y = GUI:CalcTextSize(v.name)
							GUI:SetCursorPos(butx/2-x/2,buty/2-y/2)
							GUI:Text(v.name)
							GUI:PopStyleColor()
							GUI:PopStyleVar()
							GUI:EndChild()
							if (GUI:IsItemHovered()) then
								GUI:SetTooltip(v.tooltip)
							end
							if GUI:IsItemClicked(0) then
								v.bool = not v.bool 
								save(true)
							end
						end
						GUI:End()
					end
				end		
			end	
		end	
	end
end

RegisterEventHandler("Module.Initalize", DemonCore.Init, "DemonCore.Init")
RegisterEventHandler("Gameloop.Draw", DemonCore.DrawCall, "DemonCore.DrawCall")
