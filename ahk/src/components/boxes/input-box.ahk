#Requires AutoHotkey v2.0

#Include ".\base-box.ahk"

class Input_Box extends Base_Box {
    __New(title, text := '', config := Map()) {
        super.__New(config)
        this.title := title
        this.text := text
    }

    add_content() {
        c := this.config

        ; === Input field ===
        this.gui.SetFont("s" c["font_size"] " c000000", c["font"])
        edit := this.gui.Add("Edit", "w" c["width"] " r1")

        ; === Buttons ===
        row := this.gui.Add("Text", "w" c["width"] " h8")  ; spacer

        this.ok_btn := this.gui.Add("Button", "Default w100 h32 +Center", "OK")
        this.cancel_btn := this.gui.Add("Button", "w100 h32 x+8", "Cancel")

        this.ok_btn.SetFont("s10 caaffaa", "Segoe UI")
        this.cancel_btn.SetFont("s10 caaaaff", "Segoe UI")

        this.ok_btn.BackColor := "c0078D7"   ; Windows blue
        this.cancel_btn.BackColor := "c666666"
    }

    apply_logic() {
        ; === Event logic ===
        result := ""
        done := false
        this.gui.OnEvent("Close", (*) => (done := true))
        this.ok_btn.OnEvent("Click", (*) => (result := edit.Value, done := true))
        this.cancel_btn.OnEvent("Click", (*) => (result := "", done := true))

        ; === Wait for user input ===
        while !done
            Sleep 10
    }
}

; ^!Space:: {
;     Input_Box('a', 'b').render()
; }
