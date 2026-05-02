#Requires AutoHotkey v2.0

#Include "..\components\boxes\message-box.ahk"

#Esc:: {
    config := Map(
        "title_font_size", 48,
        "width", 320,
        "margin_y", 48,
        "corner_radius", 128,
        "opacity", 230,
    )

    Send "{Esc}"
    Message_Box("🪄 Scriptus Revivus", , config).render()
    Reload
}
