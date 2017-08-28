local UIWidgets = {"HUD Presets",
                   "EPIC Menu", "Chili Crude Player List", "Chili Core Selector", "Chili Economy Panel Default",
                   "Chili Global Commands", "Chili EndGame Window", "Chili Integral Menu", --"Chili Resource Bars Classic",
                   "Chili Minimap", "Chili Pro Console", "Chili Selections & CursorTip v2"}

return {
    startStop = {
        x = "48.5%",
        y = 52,
    },

    OnStopEditingUnsynced = function()
        for _, widgetName in ipairs(UIWidgets) do
            widgetHandler:EnableWidget(widgetName)
        end
    end,

    OnStartEditingUnsynced = function()
        for _, widgetName in ipairs(UIWidgets) do
            widgetHandler:DisableWidget(widgetName)
        end
        Spring.SendCommands("tooltip 0")
        gl.SlaveMiniMap(true)
        SB.delay(function()
            widgetHandler:DisableWidget("Chili Economy Panel Default")
        end)
    end,
}
