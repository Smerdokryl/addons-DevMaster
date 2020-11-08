--[[
DevMaster = LibStub("AceAddon-3.0"):NewAddon("DevMaster")

function DevMaster:OnInitialize()
  -- Code that you want to run when the addon is first loaded goes here.
end

function DevMaster:OnEnable()
    -- Called when the addon is enabled
end

function DevMaster:OnDisable()
    -- Called when the addon is disabled
end
]]--


--Global variables for easy use
on = "on"
off = "off"

--Global functions for easy use
function ToggleFrame(frame)
	if (frame:IsShown()) then
		frame:Hide();
	else
		frame:Show();
	end
end

function FrameDropdownCheck(self, frame)
	--print(self);
	--print(frame);
	if 		frame == 1 then frame = GMPanel_Frame
	elseif 	frame == 2 then frame = DevPanel_Frame
	elseif 	frame == 3 then frame = GMSpeed_Frame
	elseif 	frame == 4 then frame = GMScale_Frame
	elseif	frame == 5 then 
		TargetSelf = not TargetSelf;
	end
	ToggleFrame(frame);
end

function SpeedDropdownCheck(self, id, typ)
	speedType=typ
	for i=1,5,1 do DevMaster_SpeedMenu[i].checked = false end
	DevMaster_SpeedMenu[id].checked=true
	DevMaster_Speed_DropdownMenuText:SetText(typ)
end

function ChangeMode(button, mode)
	if (button:GetChecked()) then
		return on;
	else
		return off;
	end
end

function NonZero(value)
	if (tonumber(value) ~= nil) then 
		if (tonumber(value) > 0) then
			return true
		else
			return false
		end
	else
		return false
	end
end

function ChatCommand(text, param)
	if TargetSelf then SendChatMessage("/target player", "GUILD") end

	if param then 
		SendChatMessage(text .. " " .. param, "GUILD") 
	else 
		SendChatMessage(text, "GUILD") 
	end
	
	if TargetSelf then SendChatMessage("/targetlasttarget", "GUILD") end
end

-- Initialisation
GMmode=off;
Devmode=off;
Flight=off;
Visible=on;
MorphFrame=off;
speedType="all";
TargetSelf=true;

-- Minimap button handling

-- add this to your SavedVariables or as a separate SavedVariable to store its position
DevMaster_Settings = {
	MinimapPos = 360 -- default position of the minimap icon in degrees
}

-- Call this in a mod's initialization to move the minimap button to its saved position (also used in its movement)
-- ** do not call from the mod's OnLoad, VARIABLES_LOADED or later is fine. **
function DevMaster_MinimapButton_Reposition()
	DevMaster_MinimapButton:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(DevMaster_Settings.MinimapPos)),(80*sin(DevMaster_Settings.MinimapPos))-52);
end

-- Only while the button is dragged this is called every frame
function DevMaster_MinimapButton_DraggingFrame_OnUpdate() -- Ignore
	local xpos,ypos = GetCursorPosition();
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom();

	xpos = xmin-xpos/UIParent:GetScale()+70; -- get coordinates as differences from the center of the minimap
	ypos = ypos/UIParent:GetScale()-ymin-70;

	DevMaster_Settings.MinimapPos = math.deg(math.atan2(ypos,xpos)); -- save the degrees we are relative to the minimap center
	DevMaster_MinimapButton_Reposition(); -- move the button
end

DevMaster_FramesMenu = {
		{text="GM panel", 			checked=true, func=FrameDropdownCheck, arg1=1,	isNotRadio=true, notCheckable=false, keepShownOnClick=true},
		{text="Developer panel", 	checked=false, func=FrameDropdownCheck, arg1=2,	disabled=true, isNotRadio=true, notCheckable=false, keepShownOnClick=true},
		{text="Speed slider", 		checked=true, func=FrameDropdownCheck, arg1=3,	isNotRadio=true, notCheckable=false, keepShownOnClick=true},
		{text="Scale slider", 		checked=true, func=FrameDropdownCheck, arg1=4,	isNotRadio=true, notCheckable=false, keepShownOnClick=true},
		{text="Auto-target self",	checked=true, func=FrameDropdownCheck, arg1=5,	isNotRadio=true, notCheckable=false, keepShownOnClick=true}
	}

DevMaster_SpeedMenu = {
		{text="All", 		checked=true,	func=SpeedDropdownCheck, arg1=1, arg2="all", 		notCheckable=false, keepShownOnClick=false},
		{text="Fly", 		checked=false, 	func=SpeedDropdownCheck, arg1=2, arg2="fly", 		notCheckable=false, keepShownOnClick=false},
		{text="Swim", 		checked=false, 	func=SpeedDropdownCheck, arg1=3, arg2="swim", 		notCheckable=false, keepShownOnClick=false},
		{text="Walk", 		checked=false, 	func=SpeedDropdownCheck, arg1=4, arg2="walk", 		notCheckable=false, keepShownOnClick=false},
		{text="Backwalk", 	checked=false, 	func=SpeedDropdownCheck, arg1=5, arg2="backwalk",	notCheckable=false, keepShownOnClick=false}
	}

-- Put your code that you want on a minimap button click here.  arg1="LeftButton", "RightButton", etc
function DevMaster_MinimapButton_OnClick(button)
	if button == "LeftButton" then 
		ToggleFrame(DevMaster_UI);
		local subframes = {DevMaster_UI:GetChildren()};
		for i = 1, 4, 1 do
			--if DevMaster_UI:IsShown() then subframes[i].Show() end
			DevMaster_FramesMenu[i].checked=DevMaster_UI:IsShown();
		end
		DevMaster_MinimapButton_DropdownMenu:Hide();
	elseif button == "RightButton" then
		if DevMaster_MinimapButton_DropdownMenu:IsShown() then DevMaster_MinimapButton_DropdownMenu:Hide() else
			DevMaster_MinimapButton_DropdownMenu:Show()
			EasyMenu(DevMaster_FramesMenu, DevMaster_MinimapButton_DropdownMenu, DevMaster_MinimapButton, 0, 0, nil);
		end
	end
end

function DevMaster_Speed_DropdownMenuButton_OnClick(button)
	--[[if SpeedMenu then
		if SpeedMenu:IsShown() then SpeedMenu:Hide() else
			SpeedMenu:Show()
			--SpeedMenu = EasyMenu(DevMaster_SpeedMenu, DevMaster_Speed_DropdownMenu, DevMaster_Speed_DropdownMenu, 0, 0, nil);
		end
	else]]--
		SpeedMenu = EasyMenu(DevMaster_SpeedMenu, DevMaster_Speed_DropdownMenu, DevMaster_Speed_DropdownMenu, 0, 0, nil);
	--end
end

--------------------------------------------------

-- GM mode
function DevMaster_toggleGMmode()
	GMmode = ChangeMode(GMPanel_Frame_GMmode_Button, GMmode);
	SendChatMessage(".gm " .. GMmode, "GUILD");
end

function DevMaster_toggleDevmode()
	Devmode = ChangeMode(GMPanel_Frame_Devmode_Button, Devmode);
	SendChatMessage(".dev " .. Devmode, "GUILD");
end

function DevMaster_toggleFlight()
	Flight = ChangeMode(GMPanel_Frame_Flymode_Button, Flight); 
	ChatCommand(".gm fly ", Flight);
	--SendChatMessage(".gm fly " .. Flight, "GUILD");
end

function DevMaster_toggleVisibility()
	Visible = ChangeMode(GMPanel_Frame_Visiblemode_Button, Visible);
	if Visible == off then Invisible = on else Invisible = off end;
	SendChatMessage(".gm visible " .. Invisible, "GUILD");
end



function DevMaster_toggleMorphFrame(self)
	if (self:GetChecked()) then
		if MorphFrame == off then
			QuestFrame_ShowQuestPortrait(GMPanel_Frame, 0, 0," ")
			CreateFrame("EditBox", "DevMaster_MorphSearchBox", QuestNPCModelTextFrame, "MorphSearchBoxTemplate")
			MorphFrame = on
		else
			QuestFrame_ShowQuestPortrait(GMPanel_Frame, 0, 0," ")
		end
	else
		QuestFrame_HideQuestPortrait(GMPanel_Frame)
	end
end

function DevMaster_toggleMorph(self)
	Morphed = ChangeMode(self, 0)
	if Morphed == on then 
		SendChatMessage(".morph " .. DevMaster_MorphSearchBox:GetText(), "GUILD");
	else 
		SendChatMessage(".demorph", "GUILD");
	end
end

function DevMaster_sliderScaling(slidername,cur,prev,extralow,extrahigh)
	if cur <= 0 then 
		cur = 0.9 + (cur/10)
	end
	
	
	if floor(cur) == 1 then
		if prev > 1 then
			--[[slidername:SetValueStep(1)]]--
			if extralow then extralow() end
		elseif prev < 1 then
			--[[slidername:SetValueStep(10)]]--
			if extrahigh then extrahigh() end
		end
	end
	
	if cur ~= prev then
		return cur
	end
end


-- movement speed
prevspeed = 1
function DevMaster_setSpeed(speed)
	speed = DevMaster_sliderScaling(GMSpeed_Slider, speed, prevspeed)
	if speed then 
		SendChatMessage(".modify speed " .. speedType .. " " .. tostring(speed), "GUILD");
		
		if speed == 10 then
			if prevspeed <= 10 then
				GMSpeed_Slider:SetWidth((GMSpeed_Frame:GetWidth()-36)*3)
				GMSpeed_Slider:SetMinMaxValues(-8,50)
				getglobal(GMSpeed_Slider:GetName().."High"):SetText("50")
			end
		elseif speed <= 9 then
			if prevspeed >= speed then
				GMSpeed_Slider:SetWidth(GMSpeed_Frame:GetWidth()-36)
				GMSpeed_Slider:SetMinMaxValues(-8,10)
				getglobal(GMSpeed_Slider:GetName().."High"):SetText("10")
			end
		end
		
		prevspeed = speed
	end
end

prevscale = 1
-- scale
function DevMaster_setScale(scale)
	scale = DevMaster_sliderScaling(GMScale_Slider, scale, prevscale)
	if scale then 
		SendChatMessage(".modify scale " .. tostring(scale), "GUILD")
		prevscale = scale
	end
end

function HideChildren(name)
	local children = { name:GetChildren() };

	for _, child in ipairs(children) do
		child:Hide()
	end
end

function ShowChildren(name)
	local children = { name:GetChildren() };

	for _, child in ipairs(children) do
		child:Show()
	end
end


function ShowFrameAlone(name)
	name:Show()
	local curframe
	local parent
	repeat
		HideChildren(curframe)
		curframe:Show()
		parent = curframe:GetParent()
		curframe = parent
	until (parent == UIParent)
	curframe:Show()
end

-- /run ShowFrameAlone(WorldMapFrame.ScrollContainer)

-- Paper Doll Frame editing

function DisableFrame(name)
	name:SetScript("OnEvent", nil)
	name:Hide()
end


-- 
function DevMaster_GetInfo(infostring)

  if infostring ~= nil then
    --Gameobjects
    for guid in string.gmatch(infostring, Strings["lfer_GOtargid1"]) do --TARGET ID
      infostring = string.gsub (infostring, Strings["lfer_GOtargid2"], MangLinkifier_Link(Strings["lfer_GOtargid3"], "%2", "targid"))
    end
    for guid in string.gmatch(infostring, Strings["lfer_GOtargguid1"]) do --TARGET GUID
      infostring = string.gsub (infostring, Strings["lfer_GOtargguid1"], MangLinkifier_Link(Strings["lfer_GOtargguid3"], "%1", "targguid"))
    end
    for guid in string.gmatch(infostring, Strings["lfer_GOtargxyz1"]) do --TARGET XYZ
      infostring = string.gsub (infostring, Strings["lfer_GOtargxyz2"], MangLinkifier_Link(Strings["lfer_GOtargxyz3"], "1 %2 %3 %4", "targxyz"))
    end
    --NPCs
    for guid in string.gmatch(infostring, Strings["lfer_NPCInfoguid1"]) do --NPCINFO GUID
      infostring = string.gsub (infostring, Strings["lfer_NPCInfoguid2"], MangLinkifier_Link(Strings["lfer_NPCInfoguid3"], "%1", "npcguid"))
    end
    for guid in string.gmatch(infostring, Strings["lfer_NPCInfoentry1"]) do --NPCINFO Entry
      infostring = string.gsub (infostring, Strings["lfer_NPCInfoentry2"], MangLinkifier_Link(Strings["lfer_NPCInfoentry3"], "%1", "npcentry"))
    end
    for guid in string.gmatch(infostring, Strings["lfer_NPCInfodisplay1"]) do --NPCINFO Display
      infostring = string.gsub (infostring, Strings["lfer_NPCInfodisplay2"], MangLinkifier_Link(Strings["lfer_NPCInfodisplay3"], "%1", "npcdisplay"))
    end
    for guid in string.gmatch(infostring, Strings["lfer_NPCInfodisplay21"]) do --NPCINFO Display Native
      infostring = string.gsub (infostring, Strings["lfer_NPCInfodisplay22"], MangLinkifier_Link(Strings["lfer_NPCInfodisplay23"], "%1", "npcdisplay2"))
    end
    ----------====~~ ADD GO Command Match Text ~~====----------
    for guid in string.gmatch(infostring, Strings["lfer_AddGoguid1"]) do --ADDGO GUID
      infostring = string.gsub (infostring, Strings["lfer_AddGoguid2"], MangLinkifier_Link(Strings["lfer_AddGoguid3"], "%1", "addgoguid"))
    end
    for guid in string.gmatch(infostring, Strings["lfer_AddGoid1"]) do --ADDGO ID
      infostring = string.gsub (infostring, Strings["lfer_AddGoid2"], MangLinkifier_Link(Strings["lfer_AddGoid3"], "%1", "addgoid"))
    end
    for guid in string.gmatch(infostring, Strings["lfer_AddGoxyz1"]) do --ADDGO XYZ
      infostring = string.gsub (infostring, Strings["lfer_AddGoxyz2"], MangLinkifier_Link(Strings["lfer_AddGoxyz3"], "%1 %2 %3", "addgoxyz"))
    end
    ----------====~~ GPS Command Match Text ~~====----------
    for guid in string.gmatch(infostring, Strings["lfer_GPSxyz1"]) do --GPS XYZ
      infostring = string.gsub (infostring, Strings["lfer_GPSxyz2"], MangLinkifier_Link(Strings["lfer_GPSxyz3"], "%1 %2 %3", "gpsxyz"))
    end
    ----------====~~ Added Options for Clickable Links Made by Mangos ~~====----------
    for guid in string.gmatch(infostring, "%|cffffffff%|Hquest:(.*)%|h%[(.*)%]%|h%|r") do --LOOKUP QUEST
      infostring = string.gsub (infostring, "%|cffffffff%|Hquest:(.*)%|h%[(.*)%]%|h%|r", MangLinkifier_Link("%2", "%1", "lookupquest"))
    end
    for guid in string.gmatch(infostring, "%|cff(.*)%|Hitem:(.*)%|h%[(.*)%]%|h%|r") do --LOOKUP ITEM -- Bug when more than 1 item is linked in chat, it is not  translated
      infostring = string.gsub (infostring, "%|cff(.*)%|Hitem:(.*)%|h%[(.*)%]%|h%|r", MangLinkifier_Link("%3-%1", "%2", "lookupitem"))
    end
    for guid in string.gmatch(infostring, "%|cffffffff%|Hgameobject_entry:(.*)%|h%[(.*)%]%|h%|r") do --LOOKUP OBJECT
      infostring = string.gsub (infostring, "%|cffffffff%|Hgameobject_entry:(.*)%|h%[(.*)%]%|h%|r", MangLinkifier_Link("%2", "%1", "lookupgo"))
    end
    for guid in string.gmatch(infostring, "%|cffffffff%|Hcreature_entry:(.*)%|h%[(.*)%]%|h%|r") do --LOOKUP CREATURE
      infostring = string.gsub (infostring, "%|cffffffff%|Hcreature_entry:(.*)%|h%[(.*)%]%|h%|r", MangLinkifier_Link("%2", "%1", "lookupcreature"))
    end
    for guid in string.gmatch(infostring, "%|cffffffff%|Hspell:(.*)%|h%[(.*)%]%|h%|r") do --LOOKUP SPELL
      infostring = string.gsub (infostring, "%|cffffffff%|Hspell:(.*)%|h%[(.*)%]%|h%|r", MangLinkifier_Link("%2", "%1", "lookupspell"))
    end
    for guid in string.gmatch(infostring, "%|cffffffff%|Htele:(.*)%|h%[(.*)%]%|h%|r") do --LOOKUP TELE
      infostring = string.gsub (infostring, "%|cffffffff%|Htele:(.*)%|h%[(.*)%]%|h%|r", MangLinkifier_Link("%2", "%1", "lookuptele"))
    end
  end
  return infostring
end




function DevMaster_Init()
	
end