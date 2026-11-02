local PANEL = {}

local math_max = math.max
local math_min = math.min
local math_floor = math.floor
local math_rad = math.rad
local math_tan = math.tan
local math_atan = math.atan
local string_find = string.find
local string_match = string.match

local function colorAlpha(color, alpha)
    if !color then return Color(255, 255, 255, math_floor(alpha or 255)) end

    return Color(color.r, color.g, color.b, math_floor(math.Clamp(alpha or color.a or 255, 0, 255)))
end

local function getModelName(path)
    local name = string_match(path, '([^/]+)%.mdl$') or path
    name = string.gsub(name, '_', ' ')

    return name
end

local function normalizeModel(data)
    local modelPath
    local name
    local description

    if isstring(data) then
        modelPath = data
    elseif istable(data) then
        modelPath = data.model or data.path or data[1]
        name = data.name or data.title
        description = data.description
    end

    if !isstring(modelPath) or modelPath == '' then return end

    modelPath = string.Trim(modelPath)
    if modelPath == '' then return end

    return {
        model = modelPath,
        name = tostring(name or getModelName(modelPath)),
        description = tostring(description or '')
    }
end

function PANEL:Init()
    self:DockMargin(8, 8, 8, 8)

    self.models = {}
    self._rows = {}
    self._selected = 0
    self._query = ''
    self._updatingSearch = false
    self._searchEnabled = true
    self._previewEnabled = true
    self._autoRotate = false
    self._autoRotateOrigin = 0
    self._autoRotateStarted = 0
    self._modelYaw = 0
    self._zoom = 1
    self._baseCameraDistance = 100
    self._cameraCenter = Vector(0, 0, 36)
    self._cameraRadius = 36
    self._previewError = nil
    self._lastPreviewW = 0
    self._lastPreviewH = 0
    self._dragging = false
    self._dragX = 0
    self._fov = 34

    self.previewCard = vgui.Create('Panel', self)
    self.previewCard.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(16)
            :Color(Mantle.color.focus_panel)
        :Draw()

        local outline = Mantle.color.panel and Mantle.color.panel[3] or Mantle.color.gray
        RNDX.Rect(0, 0, w, h)
            :Rad(16)
            :Color(colorAlpha(outline, 38))
            :Outline(1)
        :Draw()
    end

    self.previewHeader = vgui.Create('Panel', self.previewCard)
    self.previewHeader.Paint = function(_, w, h)
        draw.SimpleText(Mantle.lang.get('mantle', 'model_preview'), 'Fated.14', 14, h * 0.5, Mantle.color.text_muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    self.resetView = vgui.Create('Button', self.previewHeader)
    self.resetView:SetText('')
    self.resetView:SetCursor('hand')
    self.resetView.Paint = function(s, w, h)
        local hover = s:IsHovered()
        if hover then
            RNDX.Rect(0, 0, w, h)
                :Rad(7)
                :Color(Mantle.color.tab_hover)
            :Draw()
        end

        draw.SimpleText(Mantle.lang.get('mantle', 'model_reset_view'), 'Fated.14', w * 0.5, h * 0.5, hover and Mantle.color.theme or Mantle.color.text_muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    self.resetView.DoClick = function()
        self:ResetView()
        Mantle.func.sound()
    end

    self.previewStage = vgui.Create('Panel', self.previewCard)
    self.previewStage.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(11)
            :Color(Mantle.color.background)
        :Draw()
    end

    self.preview = vgui.Create('DModelPanel', self.previewStage)
    self.preview:SetZPos(0)
    self.preview:SetFOV(self._fov)
    self.preview:SetAnimated(false)
    self.preview:SetAmbientLight(Color(130, 130, 130))
    self.preview:SetDirectionalLight(BOX_TOP, Color(255, 255, 255))
    self.preview:SetDirectionalLight(BOX_FRONT, Color(190, 190, 190))
    self.preview.LayoutEntity = function(_, ent)
        if !IsValid(ent) then return end

        if self._autoRotate then
            local yaw = (self._autoRotateOrigin + (RealTime() - self._autoRotateStarted) * 18) % 360
            ent:SetAngles(Angle(0, yaw, 0))
        else
            ent:SetAngles(Angle(0, self._modelYaw, 0))
        end
    end
    self.preview.OnMousePressed = function(pnl, mouseCode)
        if mouseCode != MOUSE_LEFT or !IsValid(pnl:GetEntity()) then return end

        local ent = pnl:GetEntity()
        if self._autoRotate then
            self._modelYaw = ent:GetAngles().y
            self._autoRotate = false
        end

        self._dragging = true
        self._dragX = select(1, input.GetCursorPos())
        pnl:MouseCapture(true)
    end
    self.preview.OnCursorMoved = function(_, x, y)
        if !self._dragging then return end

        local mouseX = select(1, input.GetCursorPos())
        local delta = mouseX - self._dragX
        self._dragX = mouseX
        self._modelYaw = (self._modelYaw + delta * 0.55) % 360
    end
    self.preview.OnMouseReleased = function(pnl, mouseCode)
        if mouseCode != MOUSE_LEFT or !self._dragging then return end

        self._dragging = false
        pnl:MouseCapture(false)
    end
    self.preview.OnMouseWheeled = function(_, delta)
        if !IsValid(self.preview:GetEntity()) then return end

        self._zoom = math.Clamp(self._zoom * (delta > 0 and 0.9 or 1.1), 0.55, 2.6)
        self:_updateCamera()

        return true
    end

    self.previewMessage = vgui.Create('Panel', self.previewStage)
    self.previewMessage:SetZPos(2)
    self.previewMessage:SetMouseInputEnabled(false)
    self.previewMessage.Paint = function(_, w, h)
        local message = self._previewError
        if !message then
            message = #self.models == 0 and Mantle.lang.get('mantle', 'model_empty_list') or Mantle.lang.get('mantle', 'model_choose')
        end

        draw.SimpleText(message, 'Fated.16', w * 0.5, h * 0.5, Mantle.color.text_muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.previewFooter = vgui.Create('Panel', self.previewCard)

    self.previewName = vgui.Create('MantleText', self.previewFooter)
    self.previewName:SetPadding(0)
    self.previewName:SetFont('Fated.16')
    self.previewName:SetAlign(TEXT_ALIGN_LEFT)
    self.previewName:SetVAlign(TEXT_ALIGN_CENTER)
    self.previewName:SetColor(Mantle.color.text)

    self.previewPath = vgui.Create('MantleText', self.previewFooter)
    self.previewPath:SetPadding(0)
    self.previewPath:SetFont('Fated.14')
    self.previewPath:SetAlign(TEXT_ALIGN_LEFT)
    self.previewPath:SetVAlign(TEXT_ALIGN_CENTER)
    self.previewPath:SetColor(Mantle.color.text_muted)

    self.catalogCard = vgui.Create('Panel', self)
    self.catalogCard.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(16)
            :Color(Mantle.color.focus_panel)
        :Draw()

        local outline = Mantle.color.panel and Mantle.color.panel[3] or Mantle.color.gray
        RNDX.Rect(0, 0, w, h)
            :Rad(16)
            :Color(colorAlpha(outline, 38))
            :Outline(1)
        :Draw()
    end

    self.catalogHeader = vgui.Create('Panel', self.catalogCard)
    self.catalogHeader.Paint = function(_, w, h)
        draw.SimpleText(Mantle.lang.get('mantle', 'model_catalog'), 'Fated.14', 14, h * 0.5, Mantle.color.text_muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        local visibleCount = self._filteredCount or 0
        local totalCount = #self.models
        draw.SimpleText(visibleCount .. ' / ' .. totalCount, 'Fated.14', w - 14, h * 0.5, Mantle.color.text_muted, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    self.search = vgui.Create('MantleEntry', self.catalogCard)
    self.search:DockMargin(0, 0, 0, 0)
    self.search:SetPlaceholder(Mantle.lang.get('mantle', 'model_search'))
    self.search.textEntry.OnTextChanged = function()
        if self._updatingSearch then return end

        self._query = utf8.lower(string.Trim(self.search:GetValue() or ''))
        self:_rebuildModelList()
    end

    self.list = vgui.Create('MantleScrollPanel', self.catalogCard)

    self.emptyState = vgui.Create('Panel', self.catalogCard)
    self.emptyState:SetMouseInputEnabled(false)
    self.emptyState.Paint = function(_, w, h)
        local message = #self.models == 0 and Mantle.lang.get('mantle', 'model_empty_list') or Mantle.lang.get('mantle', 'model_no_results')
        draw.SimpleText(message, 'Fated.14', w * 0.5, h * 0.5, Mantle.color.text_muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.OnSelect = function() end
    self._filteredCount = 0
    self.previewMessage:SetVisible(true)
end

function PANEL:_updatePreviewDetails()
    local selected = self.models[self._selected]

    if IsValid(self.previewName) then
        self.previewName:SetText(selected and selected.name or '')
    end

    if IsValid(self.previewPath) then
        self.previewPath:SetText(selected and selected.model or '')
    end
end

function PANEL:_updateRowSelection()
    for _, row in ipairs(self._rows) do
        if IsValid(row) and IsValid(row.titleText) then
            local active = row._modelIndex == self._selected
            row.titleText:SetColor(active and Mantle.color.theme or Mantle.color.text)
        end
    end
end

function PANEL:_clearPreview()
    if IsValid(self.preview) then
        local ent = self.preview:GetEntity()
        if IsValid(ent) then ent:Remove() end
        self.preview:SetEntity(nil)
    end

    if IsValid(self.previewMessage) then
        self.previewMessage:SetVisible(true)
    end

    self._previewError = nil
    self._cameraCenter = Vector(0, 0, 36)
    self._cameraRadius = 36
    self._baseCameraDistance = 100
    self._zoom = 1
    self:_updatePreviewDetails()
end

function PANEL:_setPreviewModel(item)
    self:_clearPreview()

    if !item then
        self.preview:InvalidateLayout(true)
        self:_updatePreviewMessage()
        return false
    end

    local loadOK = pcall(self.preview.SetModel, self.preview, item.model)
    local ent = self.preview:GetEntity()
    local loadedPath = IsValid(ent) and string.lower(ent:GetModel() or '') or ''

    if !loadOK or !IsValid(ent) or loadedPath == 'models/error.mdl' then
        self._previewError = Mantle.lang.get('mantle', 'model_load_error')
        self:_clearPreviewEntity()
        self:_updatePreviewMessage()
        return false
    end

    self:_updatePreviewMessage()

    ent:SetPos(vector_origin)
    ent:SetAngles(Angle(0, self._modelYaw, 0))

    local idleSequences = {
        'idle_all_01',
        'idle_all',
        'idle_unarmed',
        'idle'
    }

    for _, sequence in ipairs(idleSequences) do
        local sequenceId = ent:LookupSequence(sequence)
        if sequenceId and sequenceId >= 0 then
            ent:ResetSequence(sequenceId)
            ent:SetCycle(0.15)
            break
        end
    end

    self:_fitCamera()
    return true
end

function PANEL:_clearPreviewEntity()
    local ent = IsValid(self.preview) and self.preview:GetEntity() or nil
    if IsValid(ent) then ent:Remove() end
    if IsValid(self.preview) then self.preview:SetEntity(nil) end
end

function PANEL:_updatePreviewMessage()
    if !IsValid(self.previewMessage) then return end
    self.previewMessage:SetVisible(!IsValid(self.preview:GetEntity()))
end

function PANEL:_fitCamera(keepZoom)
    if !IsValid(self.preview) then return end

    local ent = self.preview:GetEntity()
    if !IsValid(ent) then return end

    ent:SetupBones()

    local mins, maxs = ent:GetRenderBounds()
    local size = maxs - mins
    if size:LengthSqr() <= 1 and ent.GetModelBounds then
        mins, maxs = ent:GetModelBounds()
        size = maxs - mins
    end

    local center = (mins + maxs) * 0.5
    local radius = math_max(size:Length() * 0.5, 8)

    self._cameraCenter = center
    self._cameraRadius = radius

    local width = math_max(1, self.preview:GetWide())
    local height = math_max(1, self.preview:GetTall())
    local aspect = width / height
    local fov = self._fov
    local effectiveFov = fov

    if aspect < 1 then
        local horizontalFov = math.deg(2 * math_atan(math_tan(math_rad(fov * 0.5)) * math_max(aspect, 0.35)))
        effectiveFov = math_min(fov, horizontalFov)
    end

    self._baseCameraDistance = radius / math_max(math.sin(math_rad(effectiveFov * 0.5)), 0.1) * 1.12
    if !keepZoom then self._zoom = 1 end
    self:_updateCamera()
end

function PANEL:_updateCamera()
    if !IsValid(self.preview) then return end

    local distance = self._baseCameraDistance * self._zoom
    local center = self._cameraCenter
    local offset = Vector(distance, 0, distance * 0.08)

    self.preview:SetLookAt(center)
    self.preview:SetCamPos(center + offset)
end

function PANEL:_rebuildModelList()
    if !IsValid(self.list) then return end

    for _, row in ipairs(self._rows) do
        if IsValid(row) then row:Remove() end
    end
    self._rows = {}

    local query = self._query
    local count = 0

    for index, item in ipairs(self.models) do
        local haystack = utf8.lower(item.name .. ' ' .. item.description .. ' ' .. item.model)
        if query == '' or string_find(haystack, query, 1, true) then
            count = count + 1

            local modelIndex = index
            local rowItem = item
            local row = vgui.Create('Button')
            row:SetText('')
            row:SetCursor('hand')
            row:SetTall(rowItem.description != '' and 60 or 52)

            row._modelIndex = modelIndex

            local thumbnail = vgui.Create('SpawnIcon', row)
            thumbnail:SetSize(44, 44)
            thumbnail:SetMouseInputEnabled(false)
            thumbnail:SetKeyboardInputEnabled(false)
            thumbnail:SetTooltip(rowItem.model)
            pcall(thumbnail.SetModel, thumbnail, rowItem.model)

            local titleText = vgui.Create('MantleText', row)
            titleText:SetPadding(0)
            titleText:SetFont('Fated.16')
            titleText:SetAlign(TEXT_ALIGN_LEFT)
            titleText:SetVAlign(TEXT_ALIGN_CENTER)
            titleText:SetColor(self._selected == modelIndex and Mantle.color.theme or Mantle.color.text)
            titleText:SetText(rowItem.name)
            row.titleText = titleText

            local descriptionText
            if rowItem.description != '' then
                descriptionText = vgui.Create('MantleText', row)
                descriptionText:SetPadding(0)
                descriptionText:SetFont('Fated.14')
                descriptionText:SetAlign(TEXT_ALIGN_LEFT)
                descriptionText:SetVAlign(TEXT_ALIGN_CENTER)
                descriptionText:SetColor(Mantle.color.text_muted)
                descriptionText:SetText(rowItem.description)
            end

            row.PerformLayout = function(s, w, h)
                thumbnail:SetPos(6, math_floor((h - 44) * 0.5))

                if IsValid(titleText) then
                    if IsValid(descriptionText) then
                        titleText:SetPos(60, 5)
                        titleText:SetSize(math_max(0, w - 72), 24)
                        descriptionText:SetPos(60, 31)
                        descriptionText:SetSize(math_max(0, w - 72), 20)
                    else
                        titleText:SetPos(60, 0)
                        titleText:SetSize(math_max(0, w - 72), h)
                    end
                end
            end

            row.Paint = function(s, w, h)
                local active = self._selected == modelIndex
                local hovered = s:IsHovered()

                if active then
                    RNDX.Rect(0, 0, w, h)
                        :Rad(9)
                        :Color(colorAlpha(Mantle.color.theme, 18))
                    :Draw()

                    RNDX.Rect(0, 0, w, h)
                        :Rad(9)
                        :Color(colorAlpha(Mantle.color.theme, 100))
                        :Outline(1)
                    :Draw()
                elseif hovered then
                    RNDX.Rect(0, 0, w, h)
                        :Rad(9)
                        :Color(Mantle.color.tab_hover)
                    :Draw()
                end

            end

            row.DoClick = function()
                if self:SetSelected(modelIndex, false, true) then
                    Mantle.func.sound()
                end
            end

            self.list:AddItem(row)
            row:Dock(TOP)
            row:DockMargin(0, 0, 0, 5)
            self._rows[#self._rows + 1] = row
        end
    end

    self._filteredCount = count
    self.emptyState:SetVisible(count == 0)
    self.list:SetScroll(0)
    self:InvalidateLayout(true)
end

function PANEL:SetModels(models)
    local previous = self:GetSelectedModel()
    local normalized = {}

    if istable(models) then
        for _, data in ipairs(models) do
            local item = normalizeModel(data)
            if item then
                normalized[#normalized + 1] = item
            end
        end
    end

    self.models = normalized
    self._selected = 0

    self:_rebuildModelList()

    if #self.models == 0 then
        self:_clearPreview()
        return
    end

    local selectedIndex = 1
    if previous then
        for index, item in ipairs(self.models) do
            if item.model == previous then
                selectedIndex = index
                break
            end
        end
    end

    self:SetSelected(selectedIndex, true)
end

function PANEL:GetModels()
    return self.models
end

function PANEL:SetSelected(index, isSilent, forceNotify)
    index = tonumber(index)
    if !index then return false end

    index = math_floor(index)
    local item = self.models[index]
    if !item then return false end

    if self._selected == index then
        if forceNotify and !isSilent and self.OnSelect then
            self:OnSelect(index, item.model, item)
        end

        return true
    end

    self._selected = index
    self._modelYaw = 0
    self._zoom = 1
    self:_setPreviewModel(item)
    self:_updateRowSelection()

    if !isSilent and self.OnSelect then
        self:OnSelect(index, item.model, item)
    end

    self.previewFooter:InvalidateLayout(true)
    self:InvalidateLayout(true)

    return true
end

function PANEL:GetSelected()
    return self._selected
end

function PANEL:GetSelectedModel()
    local item = self.models[self._selected]
    return item and item.model or nil
end

function PANEL:GetSelectedData()
    return self.models[self._selected]
end

function PANEL:IsSelectedModelValid()
    local item = self.models[self._selected]
    local ent = IsValid(self.preview) and self.preview:GetEntity() or nil

    return item != nil and !self._previewError and IsValid(ent)
end

function PANEL:SetSearchEnabled(enabled)
    self._searchEnabled = tobool(enabled)
    self.search:SetVisible(self._searchEnabled)

    if !self._searchEnabled and self._query != '' then
        self._query = ''
        self._updatingSearch = true
        self.search:SetValue('')
        self._updatingSearch = false
        self:_rebuildModelList()
    end

    self:InvalidateLayout(true)
end

function PANEL:SetPreviewEnabled(enabled)
    self._previewEnabled = tobool(enabled)
    self.previewCard:SetVisible(self._previewEnabled)
    self:InvalidateLayout(true)
end

function PANEL:SetAutoRotate(enabled)
    enabled = tobool(enabled)
    if enabled == self._autoRotate then return end

    local ent = IsValid(self.preview) and self.preview:GetEntity() or nil
    if enabled then
        self._autoRotateOrigin = IsValid(ent) and ent:GetAngles().y or self._modelYaw
        self._autoRotateStarted = RealTime()
    elseif IsValid(ent) then
        self._modelYaw = ent:GetAngles().y
    end

    self._autoRotate = enabled
end

function PANEL:GetAutoRotate()
    return self._autoRotate
end

function PANEL:SetFOV(fov)
    fov = tonumber(fov)
    if !fov then return end

    self._fov = math.Clamp(fov, 20, 70)
    self.preview:SetFOV(self._fov)
    self:_fitCamera(true)
end

function PANEL:ResetView()
    self._modelYaw = 0
    self._autoRotateOrigin = 0
    self._autoRotateStarted = RealTime()
    self._zoom = 1
    self:_fitCamera(true)
end


function PANEL:OnRemove()
    if self._dragging and IsValid(self.preview) then
        self._dragging = false
        self.preview:MouseCapture(false)
    end
end

function PANEL:PerformLayout(w, h)
    if !IsValid(self.previewCard) or !IsValid(self.catalogCard) then return end

    local gap = 10
    local compact = w < 560

    if self._previewEnabled and compact then
        local maxPreviewHeight = math_max(0, h - gap - 110)
        local previewHeight = math_min(math_max(140, math_floor(h * 0.54)), maxPreviewHeight)
        self.previewCard:SetPos(0, 0)
        self.previewCard:SetSize(w, previewHeight)
        self.catalogCard:SetPos(0, previewHeight + gap)
        self.catalogCard:SetSize(w, math_max(0, h - previewHeight - gap))
    elseif self._previewEnabled then
        local previewWidth = math_floor((w - gap) * 0.6)
        self.previewCard:SetPos(0, 0)
        self.previewCard:SetSize(previewWidth, h)
        self.catalogCard:SetPos(previewWidth + gap, 0)
        self.catalogCard:SetSize(math_max(0, w - previewWidth - gap), h)
    else
        self.previewCard:SetVisible(false)
        self.catalogCard:SetPos(0, 0)
        self.catalogCard:SetSize(w, h)
    end

    if self._previewEnabled then
        self.previewCard:SetVisible(true)
        local previewW, previewH = self.previewCard:GetSize()
        local headerH = 34
        local footerH = 48
        local inset = 8

        self.previewHeader:SetPos(inset, inset)
        self.previewHeader:SetSize(math_max(0, previewW - inset * 2), headerH)
        self.resetView:SetSize(112, 24)
        self.resetView:SetPos(math_max(0, previewW - inset * 2 - 112), 5)

        self.previewStage:SetPos(inset, inset + headerH)
        self.previewStage:SetSize(math_max(0, previewW - inset * 2), math_max(0, previewH - headerH - footerH - inset * 3))
        self.preview:SetPos(1, 1)
        self.preview:SetSize(math_max(0, self.previewStage:GetWide() - 2), math_max(0, self.previewStage:GetTall() - 2))

        self.previewFooter:SetPos(inset, previewH - footerH - inset)
        self.previewFooter:SetSize(math_max(0, previewW - inset * 2), footerH)
        self.previewName:SetPos(6, 2)
        self.previewName:SetSize(math_max(0, self.previewFooter:GetWide() - 12), 20)
        self.previewPath:SetPos(6, 24)
        self.previewPath:SetSize(math_max(0, self.previewFooter:GetWide() - 12), 20)
    end

    local catalogW, catalogH = self.catalogCard:GetSize()
    local catalogInset = 8
    local headerHeight = 34
    local searchHeight = self._searchEnabled and 32 or 0
    local searchGap = self._searchEnabled and 8 or 0

    self.catalogHeader:SetPos(catalogInset, catalogInset)
    self.catalogHeader:SetSize(math_max(0, catalogW - catalogInset * 2), headerHeight)
    self.search:SetVisible(self._searchEnabled)

    if self._searchEnabled then
        self.search:SetPos(catalogInset, catalogInset + headerHeight)
        self.search:SetSize(math_max(0, catalogW - catalogInset * 2), searchHeight)
    end

    local listY = catalogInset + headerHeight + searchHeight + searchGap
    local listHeight = math_max(0, catalogH - listY - catalogInset)
    self.list:SetPos(catalogInset, listY)
    self.list:SetSize(math_max(0, catalogW - catalogInset * 2), listHeight)
    self.emptyState:SetPos(catalogInset, listY)
    self.emptyState:SetSize(math_max(0, catalogW - catalogInset * 2), listHeight)

    local previewW, previewH = self.preview:GetSize()
    if self._previewEnabled and (previewW != self._lastPreviewW or previewH != self._lastPreviewH) then
        self._lastPreviewW = previewW
        self._lastPreviewH = previewH
        self:_fitCamera(true)
    end

    self.previewMessage:SetPos(0, 0)
    self.previewMessage:SetSize(self.preview:GetSize())
end

vgui.Register('MantleModelSelector', PANEL, 'EditablePanel')

function Mantle.ui.model_selector(models, callback)
    if IsValid(Mantle.ui.menu_model_selector) then
        Mantle.ui.menu_model_selector:Remove()
    end

    local frame = vgui.Create('MantleFrame')
    if !IsValid(frame) then return end

    Mantle.ui.menu_model_selector = frame
    frame:SetSize(math.Clamp(ScrW() - 80, 640, 960), math.Clamp(ScrH() - 80, 500, 700))
    frame:Center()
    frame:MakePopup()
    frame:SetTitle('')
    frame:SetCenterTitle('')
    frame:LiteMode()
    frame:DisableCloseBtn()
    frame:ShowAnimation()

    local header = vgui.Create('Panel', frame)
    header:Dock(TOP)
    header:DockMargin(0, 0, 0, 12)
    header:SetTall(28)
    header:SetMouseInputEnabled(false)
    header.Paint = function(_, w, h)
        draw.SimpleText(Mantle.lang.get('mantle', 'model_title'), 'Fated.20b', 0, h * 0.5, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local footer = vgui.Create('Panel', frame)
    footer:Dock(BOTTOM)
    footer:DockMargin(0, 12, 0, 0)
    footer:SetTall(36)

    local selector

    local closeButton = vgui.Create('MantleBtn', footer)
    closeButton:SetTxt(Mantle.lang.get('mantle', 'model_close'))
    closeButton.DoClick = function()
        frame:Close()
        Mantle.func.sound()
    end

    local applyButton = vgui.Create('MantleBtn', footer)
    applyButton:SetTxt(Mantle.lang.get('mantle', 'apply'))
    applyButton:SetEnabled(false)
    applyButton:SetAlpha(130)
    applyButton.DoClick = function()
        if !IsValid(selector) or !selector:IsSelectedModelValid() then return end

        local model = selector:GetSelectedModel()
        local data = selector:GetSelectedData()
        local index = selector:GetSelected()

        if isfunction(callback) then
            callback(model, data, index)
        end

        if IsValid(frame) then
            frame:Close()
        end

        Mantle.func.sound()
    end

    footer.PerformLayout = function(_, w, h)
        local gap = 8
        local buttonW = math_floor((w - gap) * 0.5)
        closeButton:SetPos(0, 0)
        closeButton:SetSize(buttonW, h)
        applyButton:SetPos(buttonW + gap, 0)
        applyButton:SetSize(math_max(0, w - buttonW - gap), h)
    end

    selector = vgui.Create('MantleModelSelector', frame)
    selector:Dock(FILL)
    selector.OnSelect = function(self)
        local valid = self:IsSelectedModelValid()
        applyButton:SetEnabled(valid)
        applyButton:SetAlpha(valid and 255 or 130)
    end
    selector:SetModels(istable(models) and models or {})

    local firstValid = selector:IsSelectedModelValid()
    applyButton:SetEnabled(firstValid)
    applyButton:SetAlpha(firstValid and 255 or 130)

    frame.OnRemove = function()
        if Mantle.ui.menu_model_selector == frame then
            Mantle.ui.menu_model_selector = nil
        end
    end

    return frame, selector
end
