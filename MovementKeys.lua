local luna = require 'gamesense/luna'
local pui = require 'gamesense/pui'

local widget = luna.export 'widget'
local render = luna.export 'render'
local math = luna.export 'math'


local keyboard = widget.new('Movement_keys.keyboard', 50, 50, 0, 0) -- id, x, y, w, h

local workspace = pui.group('LUA', 'A')
local enabled = workspace:checkbox('Enable Movement Keys')

local use_glow = workspace:checkbox('Use glow'):depend(enabled)
local rainbow_glow = workspace:slider('Rainbow speed', 0, 50, 0, true, '', .1, { [0] = 'Off' }):depend(enabled):depend(use_glow)
local use_blur = workspace:checkbox('Use blur'):depend(enabled)

enabled:set_callback(function(this)
    keyboard:visible(this:get())
end)

local layout = {
    --[[
        number = Skip (N width)
        { vk, "diplay", width }
    ]]

        { 40, { 0x57 , 'W' , 40 }, 40 },
        { { 0x41 , 'A' , 40 }, { 0x53 , 'S' , 40 }, { 0x44 , 'D' , 40 } },
        { { 0x20 , 'SPACE' , 140 } }

    }

local animate = {}
local padding = 10

function keyboard:drawFn()
    local width, height = 0, 0
    local x, y = 0, self.y + padding

    local rainbow = rainbow_glow:get()
    local r, g, b = 255, 255, 255

    if rainbow > 0 then
        r, g, b = math.rainbow(rainbow * .1)
    end

    x, y = math.round(x), math.round(y)

    for line, store in ipairs(layout) do
        local w = 0
        x = self.x + padding
        y = y + (line > 1 and 40 + padding or 0)

        for i, key in ipairs(store) do
            if type(key) == 'number' then
                w = w + key
                x = x + key + padding

                goto skip
            end

            local vk, name, size = unpack(key)
            if size == -1 then size = renderer.measure_text('', name) end
            local isPressed = client.key_state(vk)

            -- lerps
            animate[vk] = animate[vk] or {}

            animate[vk].alpha = math.lerp(animate[vk].alpha, isPressed and 200 or 100, .05)
            animate[vk].text = math.lerp(animate[vk].text, isPressed and 255 or 200, .05)

            animate[vk].mod = math.lerp(animate[vk].mod, isPressed and 1 or 0, .05)

            -- risyem
            render.rectangle(x, y, size, 40, 0, 0, 0, animate[vk].alpha * self.alpha)
            renderer.text(x + size / 2, y + 20, 255, 255, 255, animate[vk].text * self.alpha, 'cb+', 0, name)

            if (isPressed or animate[vk].mod ~= 0) and use_glow:get() then
                render.glow(x, y, size, 40, r, g, b, 255 * animate[vk].mod * self.alpha, 4, 5)
            end

            if use_blur:get() and self.alpha ~= 0 then
                render.blur(x, y, size, 40)
            end

            x = x + size + padding
            w = w + size + padding

            ::skip::
        end

        
        height = height + 40 + padding
        width = math.max(width, w)
    end
    
    self.w = width + padding
    self.h = height + padding

    -- render.rectangle(self.x, self.y, self.w, self.h, 255, 255, 255, 10)

    self:update()
end