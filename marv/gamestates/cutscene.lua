local state = {}

local i, j = 0, 0
local step
local w, h

local quad, batch

local sound = nil

local close_door = nil

function state:enter(prev, _img, _w, _h, total)
    if _img == 'assets/cutscenes/body_drop.png' then
        sound = love.audio.newSource('assets/sound/window.ogg', 'static')
        sound:play()
    end
    n_w, n_h = _w, _h
    step = total / (n_w * n_h)
    img = love.graphics.newImage(_img)
    w, h = img:getWidth() / n_w, img:getHeight() / n_h
    quad = love.graphics.newQuad(0, 0, w, h, img:getWidth(), img:getHeight())
    batch = love.graphics.newSpriteBatch(img, 180)
    batch:add(quad, 0, 0)

    close_door = love.audio.newSource('assets/sound/car_close_door.wav', 'static')
end

local cur = 0
function state:update(dt)
    cur = cur + dt
    if cur > step then
        cur = 0
        i = i + 1
        if i == 10 and j == 10 then
            close_door:play()
        end
        if i == n_w then
            i = 0
            j = j + 1
            if j == n_h then
                Gamestate.pop()
                return
            end
        end
        quad:setViewport(i * w, j * h, w, h)
        batch:clear()
        batch:add(quad, 0, 0)
    end
end

local white = Color.white()
function state:draw()
    Color.set(white)
    love.graphics.draw(batch, 0, 0, 0, W / w, H / h)
end

function state:leave()
    if sound then
        sound:stop()
    end
    close_door:stop()
    Gamestate.push(GS.NEWS, 'against', 1)
end

return state
