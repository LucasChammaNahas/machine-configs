#Requires AutoHotkey v2.0

#Include ".\base-box.ahk"

class Message_Box extends Base_Box {
    __New(title, text := '', config := Map()) {
        super.__New(config)
        this.title := title
        this.text := text
    }

    add_content() {
        c := this.config

        this.gui.SetFont("s" c["title_font_size"] " c" c["title_color"], c["font"])
        this.gui.Add("Text", "Center w" c["width"], this.title)

        if (this.text) {
            this.gui.Add(
                "Progress",
                "w" c["width"] " h1 c" c["divider_color"] " Background" c["divider_color"]
            )
            this.gui.SetFont(
                "s" c["font_size"] " c" c["text_color"],
                c["font"]
            )
            this.gui.Add(
                "Text",
                "w" c["width"] " Center",
                this.text
            )
        }
    }

    apply_logic() {
        Sleep 1500
    }
}
