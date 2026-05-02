#Requires AutoHotkey v2.0

class Base_Box {
    __New(config_overrides := Map()) {
        base_config := Map(
            "bg_color", "1e1e1e",
            "text_color", "86d486",
            "title_color", "white",
            "divider_color", "555555",
            "font", "Courier New",
            "font_size", 12,
            "title_font_size", 24,
            "width", 400,
            "margin_x", 32,
            "margin_y", 32,
            "corner_radius", 64,
            "opacity", 255,
            "fade_delay", 20,
        )

        this.config := Utils.merge_objects(base_config, config_overrides)
    }

    render() {
        this.create_gui()
        this.style_gui()
        this.add_content()
        this.show_gui()
        this.position_gui()
        this.apply_rounded_corners()
        this.fade_in()
        this.apply_logic()
        this.fade_out()
        this.destroy()
    }

    create_gui() {
        this.gui := Gui("+AlwaysOnTop -Caption")
    }

    style_gui() {
        c := this.config
        this.gui.BackColor := c["bg_color"]
        this.gui.MarginX := c["margin_x"]
        this.gui.MarginY := c["margin_y"]
        WinSetTransparent(0, this.gui.Hwnd)
    }

    add_content() {

    }

    show_gui() {
        this.gui.Show("AutoSize Center")
    }

    position_gui() {
        WinGetPos &x, &y, &w, &h, this.gui.Hwnd
        WinMove x, A_ScreenHeight / 3 - h / 2, , , this.gui.Hwnd
    }

    apply_rounded_corners() {
        WinGetPos &x, &y, &w, &h, this.gui.Hwnd
        r := this.config["corner_radius"]
        hrgn := DllCall("CreateRoundRectRgn", "int", 0, "int", 0, "int", w, "int", h, "int", r, "int", r, "ptr")
        DllCall("SetWindowRgn", "ptr", this.gui.Hwnd, "ptr", hrgn, "int", true)
    }

    fade_in() {
        config := this._get_fade_config('in')
        loop config.iteration_count {
            opacity := config.calculate_opacity(A_Index)
            WinSetTransparent(opacity, this.gui.Hwnd)
            Sleep this.config["fade_delay"]
        }
    }

    apply_logic() {

    }

    fade_out() {
        config := this._get_fade_config('out')
        loop config.iteration_count {
            opacity := config.calculate_opacity(A_Index)
            WinSetTransparent(opacity, this.gui.Hwnd)
            Sleep this.config["fade_delay"]
        }
    }

    destroy() {
        this.gui.Destroy()
    }

    _get_fade_config(type) {
        iteration_count := 10
        max_opacity := this.config["opacity"]
        step := Integer(max_opacity / (iteration_count - 1))
        calculate_opacity(_, loop_index) {
            if(type = 'in'){
                return (loop_index - 1) * step
            }
            return max_opacity - (loop_index - 1) * step
        }

        return {
            iteration_count: iteration_count,
            calculate_opacity: calculate_opacity,
        }
    }
}
