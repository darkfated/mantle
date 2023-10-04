Mantle.func = {}
Mantle.ui = {}

local function create_fonts()
	for s = 1, 50 do
		surface.CreateFont('Fated.' .. s, {
			font = 'Montserrat Medium',
			size = s,
			weight = 500,
			extended = true
		})
	end
end

local function create_ui_func()
	local color_white = Color(255, 255, 255)
	local mat_blur = Material('pp/blurscreen')
	local scrw, scrh = ScrW(), ScrH()

	function Mantle.func.blur(panel)
		local x, y = panel:LocalToScreen(0, 0)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(mat_blur)

		for i = 1, 6 do
			mat_blur:SetFloat('$blur', i)
			mat_blur:Recompute()

			render.UpdateScreenEffectTexture()

			surface.DrawTexturedRect(-x, -y, scrw, scrh)
		end
	end
end

local function create_vgui()
	local color_white = Color(255, 255, 255)
	local mat_close = Material('mantle/close_btn.png')

	function Mantle.ui.frame(s, title, width, height, close_bool)
		s:SetSize(width, height)
		s:SetTitle('')
		s:ShowCloseButton(false)
		s:DockPadding(6, 30, 6, 6)
		s.Paint = function(_, w, h)
			draw.RoundedBoxEx(6, 0, 0, w, 24, Mantle.color.header, true, true)
			draw.RoundedBoxEx(6, 0, 24, w, h - 24, Mantle.color.background, false, false, true, true)

			draw.SimpleText(title, 'Fated.16', 6, 4, color_white)
		end

		if close_bool then
			s.cls = vgui.Create('DButton', s)
			s.cls:SetSize(20, 20)
			s.cls:SetPos(width - 22, 2)
			s.cls:SetText('')
			s.cls.Paint = function(_, w, h)
				surface.SetDrawColor(color_white)
				surface.SetMaterial(mat_close)
				surface.DrawTexturedRect(0, 0, w, h)
			end
			s.cls.DoClick = function()
				s:Remove()
			end
			s.cls.DoRightClick = function()
				local DM = DermaMenu()
				DM:AddOption('Remove Window', function()
					s:Remove()
				end)
				DM:Open()
			end
		end
	end

	function Mantle.ui.sp(s)
		local vbar = s:GetVBar()
		vbar:SetWide(12)
		vbar.Paint = nil
		vbar.btnDown.Paint = nil
		vbar.btnUp.Paint = nil
		vbar.btnGrip.Paint = function(_, w, h)
			draw.RoundedBox(6, 6, 0, w - 6, h, Mantle.color.vbar)
		end
	end

	function Mantle.ui.btn(s)
		s:SetTall(32)
		s.Paint = function(self, w, h)
			if !self.btn_text then
				self.btn_text = self:GetText()
				self:SetText('')
			end

			draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Mantle.color.button_hovered or Mantle.color.button)

			Mantle.func.gradient(0, 0, w, h, 1, Mantle.color.button_shadow)

			draw.SimpleText(self.btn_text, 'Fated.18', w * 0.5, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end

create_ui_func()
create_fonts()
create_vgui()

concommand.Add('mantle_ui_test', function()
	local frame = vgui.Create('DFrame')
	Mantle.ui.frame(frame, 'Test', 600, 400, true)
	frame:Center()
	frame:MakePopup()

	local main_sp = vgui.Create('DScrollPanel', frame)
	Mantle.ui.sp(main_sp)
	main_sp:Dock(FILL)
	
	for i = 1, 22 do
		local btn = vgui.Create('DButton', main_sp)
		Mantle.ui.btn(btn)
		btn:Dock(TOP)
		btn:DockMargin(0, 0, 0, 6)
		btn:SetText('Button ' .. i)
	end
end)
