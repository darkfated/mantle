if SERVER then
    util.AddNetworkString('Mantle-Notify')

    function Mantle.notify(pl, header_color, header, txt)
        net.Start('Mantle-Notify')
        net.WriteString(header)
        net.WriteColor(header_color)
        net.WriteString(txt)

        if pl == true then
            net.Broadcast()
        else
            net.Send(pl)
        end
    end
else
    net.Receive('Mantle-Notify', function()
        local header_txt = net.ReadString()
        local header_color = net.ReadColor()
        local txt = net.ReadString()
        local header_color_dop = Color(header_color.r + 10, header_color.g + 10, header_color.b + 10)
    
        chat.AddText(header_color_dop, '[', header_color, header_txt, header_color_dop, '] ', color_white, txt)
        chat.PlaySound()
    end)
end
