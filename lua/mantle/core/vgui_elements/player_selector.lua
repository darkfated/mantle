local color_disconnect = Color(210, 65, 65)
local color_bot = Color(70, 150, 220)
local color_online = Color(120, 180, 70)

function Mantle.ui.player_selector(do_click, func_check)
    if IsValid(Mantle.ui.menu_player_selector) then
        Mantle.ui.menu_player_selector:Remove()
    end

    Mantle.ui.menu_player_selector = vgui.Create('MantleFrame')
    Mantle.ui.menu_player_selector:SetSize(340, 398)
    Mantle.ui.menu_player_selector:Center()
    Mantle.ui.menu_player_selector:MakePopup()
    Mantle.ui.menu_player_selector:SetTitle('')
    Mantle.ui.menu_player_selector:SetCenterTitle(Mantle.lang.get('mantle', 'player_title'))
    Mantle.ui.menu_player_selector:ShowAnimation()

    local contentPanel = vgui.Create('Panel', Mantle.ui.menu_player_selector)
    contentPanel:Dock(FILL)
    contentPanel:DockMargin(8, 0, 8, 8)
    Mantle.ui.menu_player_selector.sp = vgui.Create('MantleScrollPanel', contentPanel)
    Mantle.ui.menu_player_selector.sp:Dock(FILL)

    local CARD_HEIGHT = 44
    local AVATAR_SIZE = 32
    local AVATAR_X = 14

    local function CreatePlayerCard(pl)
        local card = vgui.Create('DButton', Mantle.ui.menu_player_selector.sp)
        card:Dock(TOP)
        card:DockMargin(0, 5, 0, 0)
        card:SetTall(CARD_HEIGHT)
        card:SetText('')
        card.hover_status = 0
        card.OnCursorEntered = function(self)
            self:SetCursor('hand')
        end
        card.OnCursorExited = function(self)
            self:SetCursor('arrow')
        end
        card.Think = function(self)
            local target = self:IsHovered() and 1 or 0
            self.hover_status = Mantle.func.approachExp(self.hover_status, target, 8, FrameTime())
        end
        card.DoClick = function()
            if IsValid(pl) then
                Mantle.func.sound()
                do_click(pl)
            end
            Mantle.ui.menu_player_selector:Remove()
        end
        card.pl_color = team.GetColor(pl:Team()) or color_online
        card.Paint = function(self, w, h)
            RNDX().Rect(0, 0, w, h)
                :Rad(10)
                :Color(Mantle.color.panel[1])
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
            if self.hover_status > 0 then
                RNDX().Rect(0, 0, w, h)
                    :Rad(10)
                    :Color(Color(0, 0, 0, 40 * self.hover_status))
                    :Shape(RNDX.SHAPE_IOS)
                :Draw()
            end

            local infoX = AVATAR_X + AVATAR_SIZE + 10

            if !IsValid(pl) then
                draw.SimpleText(Mantle.lang.get('mantle', 'player_offline'), 'Fated.18', infoX, h * 0.5, color_disconnect, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                return
            end

            draw.SimpleText(pl:Name(), 'Fated.18', infoX, 6, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            local group = pl:GetUserGroup() or 'user'
            group = string.upper(string.sub(group, 1, 1)) .. string.sub(group, 2)
            draw.SimpleText(group, 'Fated.14', infoX, h - 6, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
            draw.SimpleText(pl:Ping() .. ' ' .. Mantle.lang.get('mantle', 'player_ping'), 'Fated.16', w - 20, h - 6, Mantle.color.gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

            local statusColor = color_disconnect
            if pl:IsBot() then
                statusColor = color_bot
            else
                statusColor = self.pl_color
            end

            RNDX.DrawCircle(w - 24, 14, 12, statusColor)
        end

        local avatarImg = vgui.Create('AvatarImage', card)
        avatarImg:SetSize(AVATAR_SIZE, AVATAR_SIZE)
        avatarImg:SetPos(AVATAR_X, (CARD_HEIGHT - AVATAR_SIZE) * 0.5)
        avatarImg:SetSteamID(pl:SteamID64(), 64)
        avatarImg:SetMouseInputEnabled(false)
        avatarImg:SetKeyboardInputEnabled(false)
        avatarImg.PaintOver = function() end
        avatarImg:SetPos(AVATAR_X, (card:GetTall() - AVATAR_SIZE) * 0.5)

        return card
    end

    for _, pl in player.Iterator() do
        CreatePlayerCard(pl)
    end

    Mantle.ui.menu_player_selector.btn_close = vgui.Create('MantleBtn', Mantle.ui.menu_player_selector)
    Mantle.ui.menu_player_selector.btn_close:Dock(BOTTOM)
    Mantle.ui.menu_player_selector.btn_close:DockMargin(16, 8, 16, 12)
    Mantle.ui.menu_player_selector.btn_close:SetTall(36)
    Mantle.ui.menu_player_selector.btn_close:SetTxt(Mantle.lang.get('mantle', 'player_close'))
    Mantle.ui.menu_player_selector.btn_close:SetColorHover(color_disconnect)
    Mantle.ui.menu_player_selector.btn_close.DoClick = function()
        Mantle.ui.menu_player_selector:Remove()
    end
end
