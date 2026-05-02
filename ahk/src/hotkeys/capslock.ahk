#Requires AutoHotkey v2.0

; === Declarations ==================================================
global is_caps_down := false
global caps_down_tick := 0
global caps_used := false

mark_and_send(keys) {
    global caps_used
    caps_used := true
    Send(keys)
}

; === Hotkey Logic ==================================================
+CapsLock::CapsLock

*CapsLock:: {
    global is_caps_down, caps_down_tick, caps_used
    is_caps_down := true
    caps_down_tick := A_TickCount
    caps_used := false
}

*CapsLock Up:: {
    global is_caps_down, caps_down_tick, caps_used
    if (A_TickCount - caps_down_tick) < 250 && !caps_used
        Send "{Esc}"
    is_caps_down := false
}

; === Hotkeys =======================================================
#HotIf is_caps_down
    ; Space to Right
    Space::mark_and_send("{Space}{Left}")

    ; Scroll
    Up::mark_and_send("{WheelUp}")
    Down::mark_and_send("{WheelDown}")
    Left::mark_and_send("+{WheelUp}")
    Right::mark_and_send("+{WheelDown}")

    ; Movement
    i::mark_and_send("{Up}")
    k::mark_and_send("{Down}")
    j::mark_and_send("{Left}")
    l::mark_and_send("{Right}")

    ; Utils
    y::mark_and_send("^{z}")
    h::mark_and_send("{Home}")
    `;::mark_and_send("{End}")
    u::mark_and_send("{Backspace}")
    n::mark_and_send("^{Backspace}")
    o::mark_and_send("{Del}")
    Delete::mark_and_send("+{End}{Backspace}")
    Backspace::mark_and_send("+{Home}{Backspace}")

    ; Default
    Enter::mark_and_send("^{Enter}")

    a::mark_and_send("^{a}")
    b::mark_and_send("^{b}")
    c::mark_and_send("^{c}")
    d::mark_and_send("^{d}")
    e::mark_and_send("^{e}")
    f::mark_and_send("^{f}")
    g::mark_and_send("^{g}")
    m::mark_and_send("^{m}")
    p::mark_and_send("^{p}")
    q::mark_and_send("^{q}")
    r::mark_and_send("^{r}")
    s::mark_and_send("^{s}")
    t::mark_and_send("^{t}")
    v::mark_and_send("^{v}")
    w::mark_and_send("^{w}")
    x::mark_and_send("^{x}")
    z::mark_and_send("^{z}")

    1::mark_and_send("^{1}")
    2::mark_and_send("^{2}")
    3::mark_and_send("^{3}")
    4::mark_and_send("^{4}")
    5::mark_and_send("^{5}")
    6::mark_and_send("^{6}")
    7::mark_and_send("^{7}")
    8::mark_and_send("^{8}")
    9::mark_and_send("^{9}")
    0::mark_and_send("^{0}")

    -::mark_and_send("^{-}")
    =::mark_and_send("^{=}")
    [::mark_and_send("^{[}")
    ]::mark_and_send("^{]}")
    \::mark_and_send("^{\}")
    '::mark_and_send("^{' }")
    ,::mark_and_send("^{,}")
    .::mark_and_send("^{.}")
    /::mark_and_send("^/{ }")
#HotIf