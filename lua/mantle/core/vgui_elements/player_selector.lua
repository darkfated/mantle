local CARD_HEIGHT = 56

function Mantle.ui.player_selector(onSelect, filterFn)
    if IsValid(Mantle.ui.menu_player_selector) then
        Mantle.ui.menu_player_selector:Remove()
    end

    local frame = vgui.Create('MantleFrame')
    Mantle.ui.menu_player_selector = frame
    frame:SetSize(400, 520)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle('')
    frame:SetCenterTitle(Mantle.lang.get('mantle', 'player_title'))
    frame:ShowAnimation()
    frame:SetPopupPad(12)

    local cards = {}
    local shownCount = 0

    local function getPlayerList()
        local list = {}
        for _, pl in player.Iterator() do
            if IsValid(pl) and (!filterFn or filterFn(pl)) then
                table.insert(list, pl)
            end
        end

        table.sort(list, function(a, b)
            local na, nb = a:Name():lower(), b:Name():lower()
            if na == nb then
                return a:UserID() < b:UserID()
            end
            return na < nb
        end)

        return list
    end

    local search = vgui.Create('MantleEntry', frame)
    search:Dock(TOP)
    search:DockMargin(0, 0, 0, 8)
    search:SetTall(32)
    search:SetPlaceholder(Mantle.lang.get('mantle', 'player_search'))

    local countLabel = vgui.Create('Panel', frame)
    countLabel:Dock(TOP)
    countLabel:SetTall(18)
    countLabel:SetMouseInputEnabled(false)
    countLabel.Paint = function(_, w, h)
        draw.SimpleText(
            Mantle.lang.get('mantle', 'player_count') .. ' - ' .. shownCount,
            'Fated.14', 0, h * 0.5,
            Mantle.color.text_muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
        )
    end

    local sp = vgui.Create('MantleScrollPanel', frame)
    sp:Dock(FILL)

    local function createPlayerCard(pl)
        local card = vgui.Create('Button', sp)
        card:Dock(TOP)
        card:DockMargin(0, 0, 0, 8)
        card:SetTall(CARD_HEIGHT)
        card:SetText('')
        card._hoverLerp = 0

        local teamColor = IsValid(pl) and team.GetColor(pl:Team()) or Mantle.color.status_disconnect
        card._teamColor = teamColor

        card.DoClick = function()
            if IsValid(pl) then
                onSelect(pl)
            end

            Mantle.func.sound()
            frame:Close()
        end

        card.Paint = function(self, w, h)
            local ft = FrameTime()
            local hovered = self:IsHovered()
            self._hoverLerp = Mantle.func.approachExp(self._hoverLerp, hovered and 1 or 0, 14, ft)

            RNDX.Rect(0, 0, w, h)
                :Rad(14)
                :Color(Mantle.color.panel_alpha[1])
            :Draw()

            if self._hoverLerp > 0.01 then
                local hv = Mantle.color.hover_overlay
                RNDX.Rect(0, 0, w, h)
                    :Rad(14)
                    :Color(Color(hv.r, hv.g, hv.b, math.floor(hv.a * self._hoverLerp)))
                :Draw()
            end

            RNDX.Rect(0, 0, w, h)
                :Rad(14)
                :Color(Mantle.color.window_shadow)
                :Outline(1)
            :Draw()

            RNDX.Rect(0, 12, 3, h - 24)
                :Rad(100)
                :Color(self._teamColor)
            :Draw()

            if !IsValid(pl) then
                draw.SimpleText(
                    Mantle.lang.get('mantle', 'player_offline'),
                    'Fated.16', 56, h * 0.5,
                    Mantle.color.status_disconnect, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
                )
                return
            end

            draw.SimpleText(pl:Name(), 'Fated.18', 56, 9, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            local group = pl:GetUserGroup() or 'user'
            group = string.upper(string.sub(group, 1, 1)) .. string.sub(group, 2)
            draw.SimpleText(group, 'Fated.14', 56, h - 9, Mantle.color.text_muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

            draw.SimpleText(
                pl:Ping() .. ' ' .. Mantle.lang.get('mantle', 'player_ping'),
                'Fated.16', w - 12, h - 9,
                Mantle.color.text_muted, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM
            )
        end

        local avatar = vgui.Create('AvatarImage', card)
        avatar:SetSize(40, 40)
        avatar:SetPos(8, 8)
        avatar:SetMouseInputEnabled(false)
        avatar:SetKeyboardInputEnabled(false)
        if IsValid(pl) then
            avatar:SetSteamID(pl:SteamID64(), 64)
        end

        table.insert(cards, card)
        return card
    end

    local function rebuild()
        for _, card in ipairs(cards) do
            card:Remove()
        end
        cards = {}
        shownCount = 0

        local query = string.lower(search:GetValue())
        for _, pl in ipairs(getPlayerList()) do
            local name = pl:Name():lower()
            if query == '' or string.find(name, query, 1, true) then
                createPlayerCard(pl)
                shownCount = shownCount + 1
            end
        end

        sp:SetScroll(0)
    end

    search.textEntry.OnTextChanged = function()
        rebuild()
    end

    local btnClose = vgui.Create('MantleBtn', frame)
    btnClose:Dock(BOTTOM)
    btnClose:SetTall(32)
    btnClose:SetTxt(Mantle.lang.get('mantle', 'player_close'))
    btnClose.DoClick = function()
        frame:Close()
        Mantle.func.sound()
    end

    frame.OnRemove = function()
        hook.Remove('PlayerConnect', 'MantlePlayerSelector')
        hook.Remove('PlayerDisconnect', 'MantlePlayerSelector')
        Mantle.ui.menu_player_selector = nil
    end

    hook.Add('PlayerConnect', 'MantlePlayerSelector', rebuild)
    hook.Add('PlayerDisconnect', 'MantlePlayerSelector', rebuild)

    rebuild()
end
