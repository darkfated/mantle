if SERVER then
    util.AddNetworkString('Mantle-Notify')

    --[[
        Функция для выведения в чат текста.
        Можно выводить определённой цели информацию, либо всем, указав вместо pl - true
    ]]--
    function Mantle.notify(pl, header_color, header_text, txt)
        net.Start('Mantle-Notify')
            net.WriteString(header_text)
            net.WriteColor(header_color)
            net.WriteString(txt)
        if pl == true then net.Broadcast() else net.Send(pl) end
    end
else
    net.Receive('Mantle-Notify', function()
        local headerText = net.ReadString()
        local headerColor = net.ReadColor()
        local headerColorDop = Color(header_color.r + 10, header_color.g + 10, header_color.b + 10)
        local txt = net.ReadString()
    
        chat.AddText(headerColorDop, '[', headerColor, headerText, headerColorDop, '] ', color_white, txt)
        chat.PlaySound()
    end)
end
