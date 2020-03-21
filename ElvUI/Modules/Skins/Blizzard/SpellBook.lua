local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local select, unpack = select, unpack

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.spellbook then return end

	SpellBookFrame:StripTextures(true)
	SpellBookFrame:SetTemplate("Transparent")
	SpellBookFrame:Width(460)

	SpellBookFrameInset:StripTextures(true)
	SpellBookSpellIconsFrame:StripTextures(true)
	SpellBookSideTabsFrame:StripTextures(true)
	SpellBookPageNavigationFrame:StripTextures(true)

	SpellBookPageText:SetTextColor(1, 1, 1)
	SpellBookPageText:Point("BOTTOMRIGHT", SpellBookFrame, "BOTTOMRIGHT", -90, 15)

	S:HandleNextPrevButton(SpellBookPrevPageButton)
	SpellBookPrevPageButton:Point("BOTTOMRIGHT", SpellBookFrame, "BOTTOMRIGHT", -45, 10)
	SpellBookPrevPageButton:Size(24)

	S:HandleNextPrevButton(SpellBookNextPageButton)
	SpellBookNextPageButton:Point("BOTTOMRIGHT", SpellBookPageNavigationFrame, "BOTTOMRIGHT", -10, 10)
	SpellBookNextPageButton:Size(24)

	SpellBookFrameTutorialButton:Hide()

	S:HandleCloseButton(SpellBookFrameCloseButton)

	-- Spell Buttons
	for i = 1, SPELLS_PER_PAGE do
		local button = _G["SpellButton"..i]
		local icon = _G["SpellButton"..i.."IconTexture"]
		local cooldown = _G["SpellButton"..i.."Cooldown"]
		local highlight = _G["SpellButton"..i.."Highlight"]

		for j = 1, button:GetNumRegions() do
			local region = select(j, button:GetRegions())
			if region:GetObjectType() == "Texture" then
				if region:GetTexture() ~= "Interface\\Buttons\\ActionBarFlyoutButton" then
					region:SetTexture(nil)
				end
			end
		end

		button:CreateBackdrop("Default", true)
		button.backdrop:SetFrameLevel(button.backdrop:GetFrameLevel() - 1)

		button.bg = CreateFrame("Frame", nil, button)
		button.bg:CreateBackdrop("Transparent", true)
		button.bg:Point("TOPLEFT", -7, 9)
		button.bg:Point("BOTTOMRIGHT", 170, -10)
		button.bg:SetFrameLevel(button.bg:GetFrameLevel() - 2)

		icon:SetTexCoord(unpack(E.TexCoords))

		highlight:SetAllPoints()
		hooksecurefunc(highlight, "SetTexture", function(self, texture)
			if texture == "Interface\\Buttons\\ButtonHilight-Square" or texture == "Interface\\Buttons\\UI-PassiveHighlight" then
				self:SetTexture(1, 1, 1, 0.3)
			end
		end)

		E:RegisterCooldown(cooldown)

		if i == 1 then
			button:Point("TOPLEFT", SpellBookSpellIconsFrame, "TOPLEFT", 15, -75)
		elseif i == 2 or i == 4 or i == 6 or i == 8 or i == 10 or i == 12 then
			button:Point("TOPLEFT", _G["SpellButton"..i - 1], "TOPLEFT", 225, 0)
		elseif i == 3 or i == 5 or i == 7 or i == 9 or i == 11 then
			button:Point("TOPLEFT", _G["SpellButton"..i - 2], "BOTTOMLEFT", 0, -27)
		end

	end

	hooksecurefunc("SpellButton_UpdateButton", function(self)
		local name = self:GetName()
		local spellName = _G[name.."SpellName"]
		local spellSubName = _G[name.."SubSpellName"]
		local spellLevel = _G[name.."RequiredLevelString"]
		local r = spellName:GetTextColor()

		if r < 0.8 then
			spellName:SetTextColor(0.6, 0.6, 0.6)

			if spellSubName then
				spellSubName:SetTextColor(0.6, 0.6, 0.6)
			end
		else
			if spellSubName then
				spellSubName:SetTextColor(1, 1, 1)
			end
		end

		if spellLevel then
			spellLevel:SetTextColor(0.6, 0.6, 0.6)
		end
	end)

	-- Skill Line Tabs
	for i = 1, MAX_SKILLLINE_TABS do
		local tab = _G["SpellBookSkillLineTab"..i]
		local flash = _G["SpellBookSkillLineTab"..i.."Flash"]

		tab:StripTextures()
		tab:SetTemplate()
		tab:StyleButton(nil, true)
		tab.pushed = true

		tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		tab:GetNormalTexture():SetInside()

		if i == 1 then
			tab:Point("TOPLEFT", SpellBookSideTabsFrame, "TOPRIGHT", E.PixelMode and -1 or 1, -40)
		end

		hooksecurefunc(tab:GetHighlightTexture(), "SetTexture", function(self, texPath)
			if texPath ~= nil then self:SetPushedTexture(nil) end
		end)

		hooksecurefunc(tab:GetCheckedTexture(), "SetTexture", function(self, texPath)
			if texPath ~= nil then self:SetHighlightTexture(nil) end
		end)

		flash:Kill()
	end

	-- Bottom Tabs
	for i = 1, 5 do
		local tab = _G["SpellBookFrameTabButton"..i]

		S:HandleTab(tab)

		if i == 1 then
			tab:ClearAllPoints()
			tab:Point("TOPLEFT", SpellBookFrame, "BOTTOMLEFT", 0, 2)
		end
	end

	-- Professions
	for frame, numItems in pairs({["PrimaryProfession"] = 2, ["SecondaryProfession"] = 4}) do
		for i = 1, numItems do
			local item = _G[frame..i]

			item:StripTextures()
			item:CreateBackdrop("Transparent")
			item:Height(numItems == 2 and 90 or 60)

			item.missingHeader:SetTextColor(1, 0.80, 0.10)
			item.missingText:SetTextColor(1, 1, 1)
			item.missingText:FontTemplate(nil, 12, "OUTLINE")

			item.statusBar:StripTextures()
			item.statusBar:CreateBackdrop()
			item.statusBar:SetStatusBarTexture(E.media.normTex)
			item.statusBar:SetStatusBarColor(0.22, 0.39, 0.84)
			item.statusBar:Size(numItems == 2 and 180 or 120, numItems == 2 and 20 or 18)
			item.statusBar:Point("TOPLEFT", numItems == 2 and 250 or 5, numItems == 2 and -10 or -35)
			item.statusBar.rankText:Point("CENTER")
			item.statusBar.rankText:FontTemplate(nil, 12, "OUTLINE")

			if item.unlearn then
				S:HandleCloseButton(item.unlearn)
				item.unlearn:Size(26)
				item.unlearn:Point("RIGHT", item.statusBar, "LEFT", -128, -9)
				item.unlearn.Texture:SetVertexColor(1, 0, 0)

				item.unlearn:HookScript("OnEnter", function(btn) btn.Texture:SetVertexColor(1, 1, 1) end)
				item.unlearn:HookScript("OnLeave", function(btn) btn.Texture:SetVertexColor(1, 0, 0) end)
			end

			if item.icon then
				item.icon:SetTexCoord(unpack(E.TexCoords))
				item.icon:SetDesaturated(false)
				item.icon:SetAlpha(1)
			end

			if numItems == 2 then
				item:Point("TOPLEFT", 10, -(i == 1 and 30 or 130))
				item.rank:Point("TOPLEFT", 120, -23)
			end

			for j = 1, 2 do
				local button = item["button"..j]

				button:StripTextures()
				button:CreateBackdrop()
				button:SetFrameLevel(button:GetFrameLevel() + 2)

				if numItems == 2 then
					button:Point(j == 1 and "TOPLEFT" or "TOPRIGHT", j == 1 and item.button2 or item, j == 1 and "BOTTOMLEFT" or "TOPRIGHT", j == 1 and 135 or -235, j == 1 and 40 or -45)
				elseif numItems == 4 then
					button:Point("TOPRIGHT", j == 1 and item or item.button1, j == 1 and "TOPRIGHT" or "TOPLEFT", j == 1 and -100 or -95, j == 1 and -10 or 0)
				end

				button:StyleButton(true)
				button.pushed:SetAllPoints()
				button.checked:SetAllPoints()
				button.highlightTexture:SetAllPoints()
				hooksecurefunc(button.highlightTexture, "SetTexture", function(self, texture)
					if texture == "Interface\\Buttons\\ButtonHilight-Square" or texture == "Interface\\Buttons\\UI-PassiveHighlight" then
						self:SetTexture(1, 1, 1, 0.3)
					end
				end)

				button.iconTexture:SetTexCoord(unpack(E.TexCoords))
				button.iconTexture:SetAllPoints()

				if button.unlearn then
					S:HandleCloseButton(button.unlearn)
					button.unlearn:Size(26)
					button.unlearn:Point("RIGHT", button, "LEFT", 0, 0)
					button.unlearn.Texture:SetVertexColor(1, 0, 0)

					button.unlearn:HookScript("OnEnter", function(btn) btn.Texture:SetVertexColor(1, 1, 1) end)
					button.unlearn:HookScript("OnLeave", function(btn) btn.Texture:SetVertexColor(1, 0, 0) end)
				end

				button.subSpellString:SetTextColor(1, 1, 1)

				button.cooldown:SetAllPoints()
				E:RegisterCooldown(button.cooldown)
			end
		end
	end

	hooksecurefunc("UpdateProfessionButton", function(self)
		self.spellString:SetTextColor(1, 0.80, 0.10)
	end)

	-- Core Abilities Frame
	SpellBookCoreAbilitiesFrame:Point("TOPLEFT", -80, 5)

	local classTextColor = E:ClassColor(E.myclass)
	SpellBookCoreAbilitiesFrame.SpecName:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
	SpellBookCoreAbilitiesFrame.SpecName:Point("TOP", 37, -30)
	SpellBookCoreAbilitiesFrame.SpecName:FontTemplate(nil, 30)

	hooksecurefunc("SpellBook_UpdateCoreAbilitiesTab", function()
		local buttons = SpellBookCoreAbilitiesFrame.Abilities
		local tabs = SpellBookCoreAbilitiesFrame.SpecTabs

		for i = 1, #buttons do
			local button = buttons[i]
			if not button then return end

			if not button.isSkinned then
				button:CreateBackdrop()
				button.backdrop:SetAllPoints()
				button:StyleButton()

				button.EmptySlot:SetAlpha(0)
				button.ActiveTexture:SetAlpha(0)
				button.FutureTexture:SetAlpha(0)

				button.iconTexture:SetTexCoord(unpack(E.TexCoords))
				button.iconTexture:SetInside()

				button.Name:Point("TOPLEFT", 50, 0)

				button.bg = CreateFrame("Frame", nil, button)
				button.bg:SetTemplate("Transparent")
				button.bg:Point("TOPLEFT", -5, 5)
				button.bg:Point("BOTTOMRIGHT", 380, -20)
				button.bg:SetFrameLevel(button.bg:GetFrameLevel() - 2)

				if button.highlightTexture then
					hooksecurefunc(button.highlightTexture, "SetTexture", function(_, texOrR)
						if texOrR == [[Interface\Buttons\ButtonHilight-Square]] then
							button.highlightTexture:SetTexture(1, 1, 1, 0.3)
							button.highlightTexture:SetInside()
						end
					end)
				end

				button.isSkinned = true
			end

			if button.FutureTexture:IsShown() then
				button.iconTexture:SetDesaturated(true)

				button.Name:SetTextColor(0.6, 0.6, 0.6)
				button.InfoText:SetTextColor(0.6, 0.6, 0.6)
				button.RequiredLevel:SetTextColor(0.6, 0.6, 0.6)
			else
				button.iconTexture:SetDesaturated(false)

				button.Name:SetTextColor(1, 0.80, 0.10)
				button.InfoText:SetTextColor(1, 1, 1)
				button.RequiredLevel:SetTextColor(0.8, 0.8, 0.8)
			end
		end

		for i = 1, #tabs do
			local tab = tabs[i]

			if tab and not tab.isSkinned then
				tab:GetRegions():Hide()
				tab:SetTemplate()

				tab:GetNormalTexture():SetInside()
				tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))

				tab:StyleButton(nil, true)

				if i == 1 then
					tab:Point("TOPLEFT", SpellBookFrame, "TOPRIGHT", E.PixelMode and -1 or 1, -75)
				end

				tab.isSkinned = true
			end
		end
	end)

	-- What Has Changed Frame
	SpellBookWhatHasChanged:Point("TOPLEFT", -80, 5)

	SpellBookWhatHasChanged.ClassName:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
	SpellBookWhatHasChanged.ClassName:Point("TOP", 37, -30)
	SpellBookWhatHasChanged.ClassName:FontTemplate(nil, 30)

	local changedList = WHAT_HAS_CHANGED_DISPLAY[E.myclass]
	if changedList then
		for i = 1, #changedList do
			local frame = SpellBook_GetWhatChangedItem(i)

			frame:StripTextures()
			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point("TOPLEFT", -25, 25)
			frame.backdrop:Point("BOTTOMRIGHT", 23, -37)

			frame:SetTextColor(1, 1, 1)
			frame.Number:SetTextColor(1, 0.80, 0.10)
			frame.Number:Point("TOPLEFT", -15, 18)
			frame.Title:SetTextColor(1, 0.80, 0.10)
		end
	end
end

S:AddCallback("Spellbook", LoadSkin)