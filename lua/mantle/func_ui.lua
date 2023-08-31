Mantle.ui = {}
Mantle.func = {}

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
	local color_header = Color(51, 51, 51)
	local color_background = Color(34, 34, 34)

	function Mantle.ui.frame(s, title, width, height, close_bool)
		s:SetSize(width, height)
		s:SetTitle('')
		s:ShowCloseButton(false)
		s:DockPadding(6, 30, 6, 6)
		s.Paint = function(_, w, h)
			draw.RoundedBoxEx(6, 0, 0, w, 24, color_header, true, true)
			draw.RoundedBoxEx(6, 0, 24, w, h - 24, color_background, false, false, true, true)

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

	local color_vbar = Color(63, 66, 102)

	function Mantle.ui.sp(s)
		local vbar = s:GetVBar()
		vbar:SetWide(12)
		vbar.Paint = nil
		vbar.btnDown.Paint = nil
		vbar.btnUp.Paint = nil
		vbar.btnGrip.Paint = function(_, w, h)
			draw.RoundedBox(6, 6, 0, w - 6, h, color_vbar)
		end
	end

	local color_button = Color(76, 76, 76)
	local color_button_hovered = Color(52, 70, 109)

	function Mantle.ui.btn(s)
		s:SetTall(32)
		s.Paint = nil
		s.PaintOver = function(self, w, h)
			draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and color_button_hovered or color_button)

			draw.SimpleText(s:GetText(), 'Fated.18', w * 0.5, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end

create_fonts()
create_ui_func()
create_vgui()

concommand.Add('mantle_ui_test', function()
	local frame = vgui.Create("DFrame")
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
