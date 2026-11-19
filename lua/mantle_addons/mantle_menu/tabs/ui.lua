local function L(key)
    return Mantle.lang.get('mantle_menu', key)
end

local function buildPanel(tab)
    local panel = vgui.Create('MantleScrollPanel')

    local panelBtns = vgui.Create('Panel')
    panelBtns:Dock(TOP)
    panelBtns:SetTall(168)

    local btn1 = vgui.Create('MantleBtn', panelBtns)
    btn1:Dock(TOP)
    btn1:SetTall(40)
    btn1:SetTxt(L('ui_btn_default'))

    local btn2 = vgui.Create('MantleBtn', panelBtns)
    btn2:Dock(TOP)
    btn2:SetTall(40)
    btn2:SetTxt(L('ui_btn_ripple'))
    btn2:SetRipple(true)

    local btn3 = vgui.Create('MantleBtn', panelBtns)
    btn3:Dock(TOP)
    btn3:SetTall(40)
    btn3:SetTxt(L('ui_btn_custom'))
    btn3:SetColor(Color(182, 65, 65))
    btn3:SetColorHover(Color(146, 46, 46))
    btn3:SetIcon(Material('icon16/delete.png'), 16)

    local cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('ui_category_button'))
    cat:SetActive(true)
    panelBtns:DockMargin(8, 8, 8, 8)
    cat:AddItem(panelBtns)

    local checkbox = vgui.Create('MantleCheckBox')
    checkbox:Dock(TOP)
    checkbox:SetTxt(L('ui_checkbox_hud'))
    checkbox:SetConvar('cl_drawhud')

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('ui_category_checkbox'))
    cat:SetActive(true)
    checkbox:DockMargin(8, 8, 8, 8)
    cat:AddItem(checkbox)

    local entry = vgui.Create('MantleEntry')
    entry:Dock(TOP)
    entry:SetTitle(L('ui_entry_title'))
    entry:SetPlaceholder('darkf')

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('ui_category_entry'))
    cat:SetActive(true)
    entry:DockMargin(8, 8, 8, 8)
    cat:AddItem(entry)

    local panelFrames = vgui.Create('Panel')
    panelFrames:Dock(TOP)
    panelFrames:SetTall(112)

    local btnFrame1 = vgui.Create('MantleBtn', panelFrames)
    btnFrame1:Dock(TOP)
    btnFrame1:SetTxt(L('ui_btn_frame'))
    btnFrame1:SetTall(40)
    btnFrame1.DoClick = function()
        local frame = vgui.Create('MantleFrame')
        frame:SetSize(400, 300)
        frame:Center()
        frame:MakePopup()
        frame:SetCenterTitle(L('ui_frame_center'))
    end

    local btnFrame2 = vgui.Create('MantleBtn', panelFrames)
    btnFrame2:Dock(TOP)
    btnFrame2:SetTxt(L('ui_btn_frame_lite'))
    btnFrame2:SetTall(40)
    btnFrame2.DoClick = function()
        local frame = vgui.Create('MantleFrame')
        frame:SetSize(400, 300)
        frame:Center()
        frame:MakePopup()
        frame:LiteMode()
    end

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('ui_category_frame'))
    cat:SetActive(true)
    panelFrames:DockMargin(8, 8, 8, 8)
    cat:AddItem(panelFrames)

    local sp = vgui.Create('MantleScrollPanel')
    sp:Dock(TOP)
    sp:SetTall(210)

    for k = 1, 10 do
        local spPanel = vgui.Create('MantlePanel', sp)
        spPanel:Dock(TOP)
        spPanel:SetTall(70)
        spPanel:SetColorAlpha(1)
        spPanel:SetRadius(16)
    end

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('ui_category_scroll'))
    cat:SetActive(true)
    sp:DockMargin(8, 8, 8, 8)
    cat:AddItem(sp)

    local panelTabs = vgui.Create('Panel')
    panelTabs:Dock(TOP)
    panelTabs:SetTall(420)

    local testTabs = vgui.Create('MantleTabs', panelTabs)
    testTabs:Dock(TOP)
    testTabs:SetTall(200)
    local testTab1 = vgui.Create('Panel')
    testTab1.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w - 12, h):Rad(16):Color(53, 98, 40):Draw()
    end
    testTabs:AddTab('Test1', testTab1)

    local testTab2 = vgui.Create('Panel')
    testTab2.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w - 12, h):Rad(16):Color(108, 41, 45):Draw()
    end
    testTabs:AddTab('Test2', testTab2)

    local testTabs2 = vgui.Create('MantleTabs', panelTabs)
    testTabs2:Dock(FILL)
    testTabs2:SetTabStyle('classic')
    local testTab3 = vgui.Create('Panel')
    testTab3.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w - 12, h):Rad(16):Color(51, 61, 116):Draw()
    end
    testTabs2:AddTab('Test3', testTab3)

    local testTab4 = vgui.Create('Panel')
    testTab4.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w - 12, h):Rad(16):Color(138, 89, 43):Draw()
    end
    testTabs2:AddTab('Test4', testTab4)

    local testTab5 = vgui.Create('Panel')
    testTab5.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w - 12, h):Rad(16):Color(43, 138, 133):Draw()
    end
    testTabs2:AddTab(L('ui_tab_icon'), testTab5, Material('icon16/folder.png'))

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('ui_category_tabs'))
    cat:SetActive(true)
    panelTabs:DockMargin(8, 8, 8, 8)
    cat:AddItem(panelTabs)

    local hscroll = vgui.Create('MantleHScroll')
    hscroll:Dock(TOP)
    hscroll:SetTall(80)

    for i = 1, 8 do
        local btn = vgui.Create('MantleBtn')
        btn:SetSize(120, 60)
        btn:SetTxt(string.format(L('ui_hscroll_item'), i))
        btn:Dock(LEFT)
        hscroll:AddItem(btn)
    end

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('ui_category_hscroll'))
    cat:SetActive(true)
    hscroll:DockMargin(8, 8, 8, 8)
    cat:AddItem(hscroll)

    local combo = vgui.Create('MantleComboBox')
    combo:SetPlaceholder(L('ui_combo_placeholder'))
    for i = 1, 8 do
        combo:AddChoice(string.format(L('ui_combo_variant'), i), 'value' .. i)
    end
    combo.OnSelect = function(idx, text, data)
        chat.AddText(color_white, 'You picked: ', Mantle.color.theme, text, color_white, ' (', tostring(data), ')')
    end
    combo:Dock(TOP)

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('ui_category_combo'))
    cat:SetActive(true)
    combo:DockMargin(8, 8, 8, 8)
    cat:AddItem(combo)

    local tableExample = vgui.Create('MantleTable')
    tableExample:Dock(TOP)
    tableExample:SetTall(250)

    tableExample:AddColumn(L('ui_table_name'), 200, TEXT_ALIGN_LEFT, true)
    tableExample:AddColumn(L('ui_table_type'), 120, TEXT_ALIGN_CENTER, true)
    tableExample:AddColumn(L('ui_table_quality'), 100, TEXT_ALIGN_CENTER, true)
    tableExample:AddColumn(L('ui_table_price'), 110, TEXT_ALIGN_RIGHT, true)

    local products = {
        {L('ui_product_1_name'), L('ui_product_1_type'), L('ui_product_1_quality'), 89},
        {L('ui_product_2_name'), L('ui_product_2_type'), L('ui_product_2_quality'), 45},
        {L('ui_product_3_name'), L('ui_product_3_type'), L('ui_product_3_quality'), 120},
        {L('ui_product_4_name'), L('ui_product_4_type'), L('ui_product_4_quality'), 95},
        {L('ui_product_5_name'), L('ui_product_5_type'), L('ui_product_5_quality'), 65},
        {L('ui_product_6_name'), L('ui_product_6_type'), L('ui_product_6_quality'), 350},
        {L('ui_product_7_name'), L('ui_product_7_type'), L('ui_product_7_quality'), 450},
        {L('ui_product_8_name'), L('ui_product_8_type'), L('ui_product_8_quality'), 380},
        {L('ui_product_9_name'), L('ui_product_9_type'), L('ui_product_9_quality'), 450},
        {L('ui_product_10_name'), L('ui_product_10_type'), L('ui_product_10_quality'), 180},
        {L('ui_product_11_name'), L('ui_product_11_type'), L('ui_product_11_quality'), 85},
        {L('ui_product_12_name'), L('ui_product_12_type'), L('ui_product_12_quality'), 120},
        {L('ui_product_13_name'), L('ui_product_13_type'), L('ui_product_13_quality'), 65},
        {L('ui_product_14_name'), L('ui_product_14_type'), L('ui_product_14_quality'), 280},
        {L('ui_product_15_name'), L('ui_product_15_type'), L('ui_product_15_quality'), 320},
        {L('ui_product_16_name'), L('ui_product_16_type'), L('ui_product_16_quality'), 180},
        {L('ui_product_17_name'), L('ui_product_17_type'), L('ui_product_17_quality'), 45},
        {L('ui_product_18_name'), L('ui_product_18_type'), L('ui_product_18_quality'), 35},
        {L('ui_product_19_name'), L('ui_product_19_type'), L('ui_product_19_quality'), 120},
        {L('ui_product_20_name'), L('ui_product_20_type'), L('ui_product_20_quality'), 180}
    }

    for _, product in ipairs(products) do
        tableExample:AddItem(unpack(product))
    end

    tableExample:SetAction(function(row_data)
        chat.AddText(color_white, 'Selected product: ', Mantle.color.theme, row_data[1], color_white, ' (', row_data[2], ')')
    end)

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('ui_category_table'))
    cat:SetActive(true)
    tableExample:DockMargin(8, 8, 8, 8)
    cat:AddItem(tableExample)

    local panelCat = vgui.Create('Panel')
    panelCat:Dock(TOP)
    panelCat:SetTall(170)
    panelCat.Paint = nil

    local catDemo = vgui.Create('MantleCategory', panelCat)
    catDemo:Dock(TOP)
    catDemo:SetCenterText(true)
    catDemo:SetActive(true)

    local panGreen = vgui.Create('MantlePanel')
    panGreen:Dock(TOP)
    panGreen:SetTall(50)
    panGreen:SetCustomColor(Color(93, 179, 101))
    catDemo:AddItem(panGreen)

    local panRed = vgui.Create('MantlePanel')
    panRed:Dock(TOP)
    panRed:SetTall(50)
    panRed:SetCustomColor(Color(179, 110, 93))
    catDemo:AddItem(panRed)

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('ui_category_category'))
    cat:SetActive(true)
    panelCat:DockMargin(8, 8, 8, 8)
    cat:AddItem(panelCat)

    local slider = vgui.Create('MantleSlideBox')
    slider:Dock(TOP)
    slider:SetRange(0, 5)
    slider:SetText(L('ui_slider_test'))

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('ui_category_slider'))
    cat:SetActive(true)
    slider:DockMargin(8, 8, 8, 8)
    cat:AddItem(slider)

    local textCategory = vgui.Create('MantleCategory', panel)
    textCategory:Dock(TOP)
    textCategory:SetText(L('ui_category_text'))
    textCategory:SetActive(true)

    local panelTexts = vgui.Create('MantlePanel')
    panelTexts:Dock(TOP)
    panelTexts:DockMargin(8, 8, 8, 8)
    panelTexts:DockPadding(8, 8, 8, 8)
    panelTexts:SetTall(388)
    panelTexts:SetColorAlpha(2)

    local panelText1 = vgui.Create('MantlePanel', panelTexts)
    panelText1:DockMargin(0, 0, 0, 8)
    panelText1:Dock(TOP)
    panelText1:SetTall(70)
    panelText1:SetColorAlpha(1)

    local text1 = vgui.Create('MantleText', panelText1)
    text1:Dock(FILL)
    text1:SetPadding(10)
    text1:SetFont('Fated.16')
    text1:SetText(L('ui_text_1'))

    local panelText2 = vgui.Create('MantlePanel', panelTexts)
    panelText2:DockMargin(0, 0, 0, 8)
    panelText2:Dock(TOP)
    panelText2:SetTall(130)
    panelText2:SetColorAlpha(1)

    local text2 = vgui.Create('MantleText', panelText2)
    text2:Dock(FILL)
    text2:SetPadding(12)
    text2:SetFont('Fated.20')
    text2:SetText(L('ui_text_2'))
    text2:SetAlign(TEXT_ALIGN_CENTER)
    text2:SetVAlign('center')

    local panelText3 = vgui.Create('MantlePanel', panelTexts)
    panelText3:DockMargin(0, 0, 0, 8)
    panelText3:Dock(TOP)
    panelText3:SetTall(60)
    panelText3:SetColorAlpha(1)

    local text3 = vgui.Create('MantleText', panelText3)
    text3:Dock(FILL)
    text3:SetPadding(8)
    text3:SetFont('Fated.16')
    text3:SetText(L('ui_text_3_prefix') .. string.rep(L('ui_text_long_word'), 8))

    local panelText4 = vgui.Create('MantlePanel', panelTexts)
    panelText4:Dock(TOP)
    panelText4:DockMargin(0, 0, 0, 0)
    panelText4:SetTall(88)
    panelText4:SetColorAlpha(1)

    local text4 = vgui.Create('MantleText', panelText4)
    text4:Dock(FILL)
    text4:SetPadding(8)
    text4:SetFont('Fated.16')
    text4:SetText(L('ui_text_4'))

    textCategory:AddItem(panelTexts)

    return panel
end

Mantle.menu.registerTab('ui', {
    order = 2,
    title = L('tab_ui'),
    description = L('tab_ui_desc'),
    icon = Material('icon16/chart_pie.png'),
    build = buildPanel
})
