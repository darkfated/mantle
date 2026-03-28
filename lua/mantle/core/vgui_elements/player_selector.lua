local color_disconnect = Color(210, 65, 65)
local color_bot = Color(70, 150, 220)
local color_online = Color(120, 180, 70)

function Mantle.ui.player_selector(onSelect, filterFn)
    if IsValid(Mantle.ui.menu_player_selector) then
        Mantle.ui.menu_player_selector:Remove()
    end

    local selector = vgui.Create('MantleFrame')
    Mantle.ui.menu_player_selector = selector
    selector:SetSize(360, 460)
    selector:Center()
    selector:MakePopup()
    selector:SetTitle('')
    selector:SetCenterTitle(Mantle.lang.get('mantle', 'player_title'))
    selector:ShowAnimation()
    selector:DockPadding(12, 36, 12, 12)

    selector.sp = vgui.Create('MantleScrollPanel', selector)
    selector.sp:Dock(FILL)

    local function createPlayerCard(pl)
        local card = vgui.Create('Button', selector.sp)
        card:Dock(TOP)
        card:DockMargin(0, 0, 0, 6)
        card:SetTall(48)
        card:SetText('')
        card.DoClick = function()
            if IsValid(pl) then
                onSelect(pl)
            end

            Mantle.func.sound()
            selector:Close()
        end
        card.playerColor = team.GetColor(pl:Team()) or color_online
        card.Paint = function(self, w, h)
            RNDX().Rect(0, 0, w, h)
                :Rad(10)
                :Color(Mantle.color.panel_alpha[1])
                :Shape(RNDX.SHAPE_IOS)
            :Draw()

            if !IsValid(pl) then
                draw.SimpleText(Mantle.lang.get('mantle', 'player_offline'), 'Fated.16', 44, h * 0.5, color_disconnect, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                return
            end

            draw.SimpleText(pl:Name(), 'Fated.18', 50, 8, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            local group = pl:GetUserGroup() or 'user'
            group = string.upper(string.sub(group, 1, 1)) .. string.sub(group, 2)
            draw.SimpleText(group, 'Fated.14', 50, h - 8, Mantle.color.text_muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
            draw.SimpleText(pl:Ping() .. ' ' .. Mantle.lang.get('mantle', 'player_ping'), 'Fated.16', w - 12, h - 8, Mantle.color.text_muted, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            local statusColor = color_disconnect
            if pl:IsBot() then
                statusColor = color_bot
            else
                statusColor = self.playerColor
            end

            RNDX().Rect(w - 26, 10, 14, 14)
                :Rad(100)
                :Color(statusColor)
            :Draw()
        end

        local avatarImg = vgui.Create('AvatarImage', card)
        avatarImg:SetSize(32, 32)
        avatarImg:SetPos(8, 8)
        avatarImg:SetSteamID(pl:SteamID64(), 64)
        avatarImg:SetMouseInputEnabled(false)
        avatarImg:SetKeyboardInputEnabled(false)

        return card
    end

    for _, pl in player.Iterator() do
        if !filterFn or filterFn(pl) then
            createPlayerCard(pl)
        end
    end

    selector.btnClose = vgui.Create('MantleBtn', selector)
    selector.btnClose:Dock(BOTTOM)
    selector.btnClose:DockMargin(0, 8, 0, 0)
    selector.btnClose:SetTall(36)
    selector.btnClose:SetTxt(Mantle.lang.get('mantle', 'player_close'))
    selector.btnClose.DoClick = function()
        selector:Close()
    end
end
