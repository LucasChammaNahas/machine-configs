#Requires AutoHotkey v2.0

class Utils {
    static merge_objects(base, override) {
        merged := Map()

        for key, value in base
            merged[key] := Value

        for key, value in override
            merged[key] := Value


        return merged
    }
}
