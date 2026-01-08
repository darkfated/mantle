local function Create()
    if IsValid(MantleMenu) then
        MantleMenu:Remove()
    end

    MantleMenu = vgui.Create('MantleFrame')
    MantleMenu:SetSize(1200, 700)
    MantleMenu:Center()
    MantleMenu:MakePopup()
    MantleMenu:SetCenterTitle('Меню Mantle')
    MantleMenu:ShowAnimation()

    local tabs = vgui.Create('MantleTabs', MantleMenu)
    tabs:Dock(FILL)

    tabs:AddTab({
        title = 'Компоненты UI',
        description = 'Пользовательские элементы интерфейса',
        icon = Material('icon16/chart_pie.png'),
    }, CreateMantleUITab())

    tabs:AddTab({
        title = 'Всплывающие элементы',
        description = 'Открывающие меню и всплывающие окна',
        icon = Material('icon16/application_double.png'),
    }, CreateMantlePopupTab())

    tabs:AddTab({
        title = 'Функции',
        description = 'Справочник по встроенным функциям',
        icon = Material('icon16/error.png'),
    }, CreateMantleFunctionsTab())

    tabs:AddTab({
        title = 'Настройки Mantle',
        description = 'Здесь вы можете изменить настройки библиотеки',
        icon = Material('icon16/cog.png'),
    }, CreateMantleSettingsTab())
end

local function createCopyButton(parent, snippet)
    local b = vgui.Create('MantleBtn', parent)
    b:SetTxt('Копировать')
    b:SetWide(110)
    b.DoClick = function()
        SetClipboardText(snippet)
        MantleMenu:Notify(snippet)

        Mantle.func.sound()
    end

    return b
end

local function createInfo(info, pan)
    local panel = vgui.Create('Panel')
    panel:Dock(TOP)
    panel:DockMargin(0, 0, 0, 6)
    panel:SetTall(50)
    panel.Paint = function(_, w, h)
        RNDX().Rect(0, 0, w, h)
            :Rad(32)
            :Color(Mantle.color.p)
            :Shape(RNDX.SHAPE_IOS)
        :Draw()

        draw.SimpleText(info[1], 'Fated.RegularPlus', 16, 8, Mantle.color.text)
        draw.SimpleText(info[2], 'Fated.Regular', 16, h - 8, Mantle.color.text_muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end

    local btnCopy = createCopyButton(panel, info[1])
    btnCopy:Dock(RIGHT)
    btnCopy:DockMargin(0, 8, 8, 8)

    pan:AddItem(panel)
end

function MantleCreateCategory(name, info_table, pan, ui_element, is_active)
    local category = vgui.Create('MantleCategory', pan)
    category:Dock(TOP)
    category:DockMargin(0, 0, 0, 6)
    category:SetText(name)

    if is_active then
        category:SetActive(true)
    end

    for _, info in ipairs(info_table) do
        createInfo(info, category)
    end

    if ui_element then
        category:AddItem(ui_element)
    end
end

concommand.Add('mantle_menu', function()
    Create()
end)
