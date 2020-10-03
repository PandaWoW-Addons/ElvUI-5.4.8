local E, L, V, P, G = unpack(select(2, ...))
local AB = E:GetModule("ActionBars")

local _G = _G

local CreateFrame = CreateFrame
local GetActionCooldown = GetActionCooldown
local HasExtraActionBar = HasExtraActionBar
local hooksecurefunc = hooksecurefunc

local ExtraActionBarHolder

local function FixExtraActionCD(button)
	if button.cooldown and button.action then
		local start, duration = GetActionCooldown(button.action)
		E.OnSetCooldown(button.cooldown, start, duration)
	end
end

function AB:Extra_SetAlpha()
	if not E.private.actionbar.enable then return end

	local alpha = E.db.actionbar.extraActionButton.alpha
	for i = 1, ExtraActionBarFrame:GetNumChildren() do
		local button = _G["ExtraActionButton"..i]
		if button then
			button:SetAlpha(alpha)
		end
	end
end

function AB:Extra_SetScale()
	if not E.private.actionbar.enable then return end

	local scale = E.db.actionbar.extraActionButton.scale
	if ExtraActionBarFrame then
		ExtraActionBarFrame:SetScale(scale)
		ExtraActionBarHolder:Size(ExtraActionBarFrame:GetWidth() * scale)
	end
end

function AB:UpdateExtraBindings()
	local color = AB.db.fontColor

	for i = 1, ExtraActionBarFrame:GetNumChildren() do
		local button = _G["ExtraActionButton"..i]
		if button then
			local hotKey = _G["ExtraActionButton"..i.."HotKey"]

			hotKey:SetShown(AB.db.hotkeytext)
			hotKey:SetTextColor(color.r, color.g, color.b)
			AB:FixKeybindText(button)
		end
	end
end

function AB:SetupExtraButton()
	ExtraActionBarHolder = CreateFrame("Frame", nil, E.UIParent)
	ExtraActionBarHolder:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 150)
	ExtraActionBarHolder:Size(ExtraActionBarFrame:GetSize())

	ExtraActionBarFrame:SetParent(ExtraActionBarHolder)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:Point("CENTER", ExtraActionBarHolder, "CENTER")
	UIPARENT_MANAGED_FRAME_POSITIONS.ExtraActionBarFrame = nil

	for i = 1, ExtraActionBarFrame:GetNumChildren() do
		local button = _G["ExtraActionButton"..i]
		if button then
			self:StyleButton(button, true)
			button:SetTemplate()

			button.noResize = true
			button.pushed = true
			button.checked = true

			button.icon:SetDrawLayer("ARTWORK")

			_G["ExtraActionButton"..i.."HotKey"].SetVertexColor = E.noop

			if E.private.skins.cleanBossButton and button.style then -- Hide the Artwork
				button.style:SetTexture()
				hooksecurefunc(button.style, "SetTexture", function(btn, tex)
					if tex ~= nil then btn:SetTexture() end
				end)
			end

			local tex = button:CreateTexture(nil, "OVERLAY")
			tex:SetTexture(0.9, 0.8, 0.1, 0.3)
			tex:SetInside()
			button:SetCheckedTexture(tex)

			if button.cooldown then
				button.cooldown.CooldownOverride = "actionbar"
				E:RegisterCooldown(button.cooldown)
				button:HookScript("OnShow", FixExtraActionCD)
			end
		end
	end

	if HasExtraActionBar() then
		ExtraActionBarFrame:Show()
	end

	E:CreateMover(ExtraActionBarHolder, "BossButton", L["Boss Button"], nil, nil, nil, "ALL,ACTIONBARS", nil, "actionbar,extraActionButton")

	AB:Extra_SetAlpha()
	AB:Extra_SetScale()
	AB:UpdateExtraBindings()
end