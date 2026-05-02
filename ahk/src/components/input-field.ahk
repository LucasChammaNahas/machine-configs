#Requires AutoHotkey v2.0

; ^!Space::SetTimer(() => Input_Box("a", "b"), -1000)
; ^!Space:: Input_Box("a", "b")

Input_Box(prompt := "", title := "Input") {
    ; === Configuration ===
    config := {
        bg_color: "1e1e1e",
        text_color: "86d486",
        title_color: "ff8e47",
        divider_color: "555555",
        font: "Courier New",
        font_size: 12,
        title_font_size: 24,
        width: 400,
        margin_x: 32,
        margin_y: 24,
        corner_radius: 64,
        fade_step: 25,
        fade_delay: 15
    }

    ; === Create and style window ===
    win := Gui("+AlwaysOnTop -Caption +ToolWindow +OwnDialogs")
    win.BackColor := config.bg_color
    win.MarginX := config.margin_x
    win.MarginY := config.margin_y

    ; === Title ===
    win.SetFont("s" config.title_font_size " c" config.title_color, config.font)
    win.Add("Text", "Center w" config.width, title)

    ; === Prompt ===
    if (prompt) {
        win.Add("Progress", "w" config.width " h1 c" config.divider_color " Background" config.divider_color)
        win.SetFont("s" config.font_size " c" config.text_color, config.font)
        win.Add("Text", "w" config.width " Center", prompt)
    }

    ; === Input field ===
    win.SetFont("s" config.font_size " c000000", config.font)
    edit := win.Add("Edit", "w" config.width " r1")

    ; === Buttons ===
    row := win.Add("Text", "w" config.width " h8")  ; spacer
    ok_btn := win.Add("Button", "Default w80", "OK")
    cancel_btn := win.Add("Button", "w80 x+8", "Cancel")

    ; === Apply rounded corners and show ===
    WinSetTransparent(0, win.Hwnd)
    win.Show("AutoSize Center")
    WinGetPos &x, &y, &w, &h, win.Hwnd
    WinMove x, A_ScreenHeight/3 - h/2, , , win.Hwnd

    hrgn := DllCall(
        "CreateRoundRectRgn",
        "int", 0, "int", 0, "int", w, "int", h,
        "int", config.corner_radius, "int", config.corner_radius,
        "ptr"
    )
    DllCall("SetWindowRgn", "ptr", win.Hwnd, "ptr", hrgn, "int", true)
    WinActivate win.Hwnd

    ; === Fade in ===
    loop 10 {
        WinSetTransparent(A_Index * config.fade_step, win.Hwnd)
        Sleep config.fade_delay
    }

    ; === Event logic ===
    result := ""
    done := false
    win.OnEvent("Close", (*) => (done := true))
    ok_btn.OnEvent("Click", (*) => (result := edit.Value, done := true))
    cancel_btn.OnEvent("Click", (*) => (result := "", done := true))

    ; === Wait for user input ===
    while !done
        Sleep 10

    ; === Fade out ===
    loop 10 {
        WinSetTransparent(255 - A_Index * config.fade_step, win.Hwnd)
        Sleep config.fade_delay
    }

    win.Destroy()
    return result
}
