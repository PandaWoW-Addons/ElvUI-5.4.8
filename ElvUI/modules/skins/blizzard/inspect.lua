local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local pairs, unpack = pairs, unpack

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.inspect then return end

	local InspectFrame = _G["InspectFrame"]
	InspectFrame:StripTextures(true)
	InspectFrame:SetTemplate("Transparent")

	InspectFrameInset:StripTextures(true)

	S:HandleCloseButton(InspectFrameCloseButton)

	for i = 1, 4 do
		S:HandleTab(_G["InspectFrameTab"..i])
	end

	InspectModelFrame:StripTextures()
	InspectModelFrame:CreateBackdrop("Default")
	InspectModelFrame.backdrop:Point("TOPLEFT", E.PixelMode and -1 or -2, E.PixelMode and 1 or 2)
	InspectModelFrame.backdrop:Point("BOTTOMRIGHT", E.PixelMode and 1 or 2, E.PixelMode and -2 or -3)

	InspectModelFrameBorderTopLeft:Kill()
	InspectModelFrameBorderTopRight:Kill()
	InspectModelFrameBorderTop:Kill()
	InspectModelFrameBorderLeft:Kill()
	InspectModelFrameBorderRight:Kill()
	InspectModelFrameBorderBottomLeft:Kill()
	InspectModelFrameBorderBottomRight:Kill()
	InspectModelFrameBorderBottom:Kill()
	InspectModelFrameBorderBottom2:Kill()

	--Re-add the overlay texture which was removed via StripTextures
	InspectModelFrameBackgroundOverlay:SetTexture(0, 0, 0)

--[[
	-- Give inspect frame model backdrop it's color back
	for _, corner in pairs({"TopLeft", "TopRight", "BotLeft", "BotRight"}) do
		local bg = _G["InspectModelFrameBackground"..corner]
		if bg then
			bg:SetDesaturated(false)
			bg.ignoreDesaturated = true -- so plugins can prevent this if they want.
			hooksecurefunc(bg, "SetDesaturated", function(bckgnd, value)
				if value and bckgnd.ignoreDesaturated then
					bckgnd:SetDesaturated(false)
				end
			end)
		end
	end
]]

	local slots = {
		"HeadSlot",
		"NeckSlot",
		"ShoulderSlot",
		"BackSlot",
		"ChestSlot",
		"ShirtSlot",
		"TabardSlot",
		"WristSlot",
		"HandsSlot",
		"WaistSlot",
		"LegsSlot",
		"FeetSlot",
		"Finger0Slot",
		"Finger1Slot",
		"Trinket0Slot",
		"Trinket1Slot",
		"MainHandSlot",
		"SecondaryHandSlot"
	}

	for _, slot in pairs(slots) do
		local icon = _G["Inspect"..slot.."IconTexture"]
		local slot = _G["Inspect"..slot]

		slot:StripTextures()
		slot:CreateBackdrop("Default")
		slot.backdrop:SetAllPoints()
		slot:SetFrameLevel(slot:GetFrameLevel() + 2)
		slot:StyleButton(nil, true)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
	end

	hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
		if button.hasItem then
			local itemID = GetInventoryItemID(InspectFrame.unit, button:GetID())
			if itemID then
				local quality = GetInventoryItemQuality(InspectFrame.unit, button:GetID())
				if not quality then
					E:Delay(0.1, function()
						if InspectFrame.unit then
							InspectPaperDollItemSlotButton_Update(button)
						end
					end)
					return
				elseif quality then
					button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
					return
 				end
			end
		end
		button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
 	end)

	-- Control Frame
	InspectModelFrameControlFrame:StripTextures()
	InspectModelFrameControlFrame:Size(123, 23)

	local controlbuttons = {
		"InspectModelFrameControlFrameZoomInButton",
		"InspectModelFrameControlFrameZoomOutButton",
		"InspectModelFrameControlFramePanButton",
		"InspectModelFrameControlFrameRotateRightButton",
		"InspectModelFrameControlFrameRotateLeftButton",
		"InspectModelFrameControlFrameRotateResetButton"
	}

	for i = 1, #controlbuttons do
		S:HandleButton(_G[controlbuttons[i]])
		_G[controlbuttons[i].."Bg"]:Hide()
	end

	InspectModelFrameControlFrameZoomOutButton:Point("LEFT", "InspectModelFrameControlFrameZoomInButton", "RIGHT", 2, 0)
	InspectModelFrameControlFramePanButton:Point("LEFT", "InspectModelFrameControlFrameZoomOutButton", "RIGHT", 2, 0)
	InspectModelFrameControlFrameRotateRightButton:Point("LEFT", "InspectModelFrameControlFramePanButton", "RIGHT", 2, 0)
	InspectModelFrameControlFrameRotateLeftButton:Point("LEFT", "InspectModelFrameControlFrameRotateRightButton", "RIGHT", 2, 0)
	InspectModelFrameControlFrameRotateResetButton:Point("LEFT", "InspectModelFrameControlFrameRotateLeftButton", "RIGHT", 2, 0)

	-- Talent Tab
	InspectTalentFrame:StripTextures()

	Specialization:CreateBackdrop("Default", true)
	Specialization.backdrop:Point("TOPLEFT", 18, -16)
	Specialization.backdrop:Point("BOTTOMRIGHT", 20, 12)

	Specialization.ring:SetTexture("")

	Specialization.specIcon:SetTexCoord(unpack(E.TexCoords))
	Specialization.specIcon.backdrop = CreateFrame("Frame", nil, Specialization)
	Specialization.specIcon.backdrop:SetTemplate("Default")
	Specialization.specIcon.backdrop:SetOutside(Specialization.specIcon)
	Specialization.specIcon:SetParent(Specialization.specIcon.backdrop)

	Specialization:HookScript("OnShow", function(self)
		local spec = nil
		self.tooltip = nil

		if INSPECTED_UNIT ~= nil then
			spec = GetInspectSpecialization(INSPECTED_UNIT)
		end

		local _, role, description, icon
		if spec ~= nil and spec > 0 then
			role = GetSpecializationRoleByID(spec)

			if role ~= nil then
				_, _, description, icon = GetSpecializationInfoByID(spec)

				self.specIcon:SetTexture(icon)
				self.tooltip = description

				if role == "DAMAGER" then
					self.roleIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\dps.tga")
					self.roleIcon:Size(19)
				elseif role == "TANK" then
					self.roleIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\tank.tga")
					self.roleIcon:Size(20)
				elseif role == "HEALER" then
					self.roleIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\healer.tga")
					self.roleIcon:Size(20)
				end
				self.roleIcon:SetTexCoord(unpack(E.TexCoords))

				self.roleName:SetTextColor(1, 1, 1)
			end
		end
	end)

	for i = 1, 6 do
		for j = 1, 3 do
			local button = _G["TalentsTalentRow"..i.."Talent"..j]

			if button then
				button:StripTextures()
				button:CreateBackdrop("Default")
				button:Size(30)
				button:StyleButton(nil, true)
				button:GetHighlightTexture():SetInside(button.backdrop)

				button.icon:SetTexCoord(unpack(E.TexCoords))
				button.icon:SetInside(button.backdrop)

				hooksecurefunc(button.border, "Show", function()
					button.backdrop:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor))
				end)

				hooksecurefunc(button.border, "Hide", function()
					button.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				end)
			end
		end
	end

	TalentsTalentRow1:Point("TOPLEFT", 20, -142)

	InspectTalentFrame:HookScript("OnShow", function(self)
		if self.isGlyphsDone then return end

		for i = 1, 6 do
			local Glyph = InspectGlyphs["Glyph"..i]

			Glyph:SetTemplate("Default", true)
			Glyph:StyleButton(nil, true)
			Glyph:SetFrameLevel(Glyph:GetFrameLevel() + 5)
			Glyph.ring:Kill()
			Glyph.highlight:SetTexture(nil)
			Glyph.glyph:Kill()

			Glyph.icon = Glyph:CreateTexture(nil, "OVERLAY")
			Glyph.icon:SetInside()
			Glyph.icon:SetTexCoord(unpack(E.TexCoords))

			if i % 2 == 1 then
				Glyph:Size(Glyph:GetWidth() * .6, Glyph:GetHeight() * .6)
			else
				Glyph:Size(Glyph:GetWidth() * .8, Glyph:GetHeight() * .8)
			end
		end

		InspectGlyphs.Glyph1:Point("TOPLEFT", 90, -7)
		InspectGlyphs.Glyph2:Point("TOPLEFT", 15, 0)
		InspectGlyphs.Glyph3:Point("TOPLEFT", 90, -97)
		InspectGlyphs.Glyph4:Point("TOPLEFT", 15, -90)
		InspectGlyphs.Glyph5:Point("TOPLEFT", 90, -187)
		InspectGlyphs.Glyph6:Point("TOPLEFT", 15, -180)

		InspectGlyphFrameGlyph_UpdateGlyphs(self.InspectGlyphs, false)

		self.isGlyphsDone = true
	end)

	hooksecurefunc("InspectGlyphFrameGlyph_UpdateSlot", function(self)
		local id = self:GetID()
		local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup
		local _, glyphType, _, _, iconFilename = GetGlyphSocketInfo(id, talentGroup, true, INSPECTED_UNIT)

		if self.icon then
			if glyphType and iconFilename then
				self.icon:SetTexture(iconFilename)
			else
				self.icon:SetTexture("Interface\\Spellbook\\UI-Glyph-Rune1")
			end
		end
	end)

	-- PVP Tab
	InspectPVPFrame:StripTextures()

	for _, Section in pairs({"RatedBG", "Arena2v2", "Arena3v3", "Arena5v5"}) do
		local Frame = InspectPVPFrame[Section]
		Frame:CreateBackdrop("Transparent")
		Frame.backdrop:Point("TOPLEFT", 0, -1)
		Frame.backdrop:Point("BOTTOMRIGHT", 0, 1)
		Frame:EnableMouse(true)

		Frame:HookScript("OnEnter", S.SetModifiedBackdrop)
		Frame:HookScript("OnLeave", S.SetOriginalBackdrop)
	end

	-- Guild Tab
	InspectGuildFrame.bg = CreateFrame("Frame", nil, InspectGuildFrame)
	InspectGuildFrame.bg:SetTemplate("Default")	
	InspectGuildFrame.bg:Point("TOPLEFT", 7, -63)
	InspectGuildFrame.bg:Point("BOTTOMRIGHT", -9, 27)
	InspectGuildFrame.bg:SetBackdropColor(0, 0, 0, 0)
	InspectGuildFrame.bg.backdropTexture:SetAlpha(0)

	InspectGuildFrameBG:SetInside(InspectGuildFrame.bg)
	InspectGuildFrameBG:SetParent(InspectGuildFrame.bg)
	InspectGuildFrameBG:SetDesaturated(true)

	InspectGuildFrameBanner:SetParent(InspectGuildFrame.bg)
	InspectGuildFrameBannerBorder:SetParent(InspectGuildFrame.bg)
	InspectGuildFrameTabardLeftIcon:SetParent(InspectGuildFrame.bg)
	InspectGuildFrameTabardRightIcon:SetParent(InspectGuildFrame.bg)
	InspectGuildFrameGuildName:SetParent(InspectGuildFrame.bg)
	InspectGuildFrameGuildLevel:SetParent(InspectGuildFrame.bg)
	InspectGuildFrameGuildNumMembers:SetParent(InspectGuildFrame.bg)
end

S:AddCallbackForAddon("Blizzard_InspectUI", "Inspect", LoadSkin)