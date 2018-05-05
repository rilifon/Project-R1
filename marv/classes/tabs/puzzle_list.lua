--[[
#####################################
Marvellous Inc.
Copyright (C) 2017  MarvellousSoft & USPGameDev
See full license in file LICENSE.txt
(https://github.com/MarvellousSoft/MarvInc/blob/dev/LICENSE.txt)
#####################################
]]--

local ScrollWindow = require "classes.scroll_window"
require "classes.tabs.tab"
local AuthorButton = require "classes.tabs.puzzle_list_buttons"
local border_w = 20

PuzzleListTab = Class {
    __includes = {Tab},

    button_color = 40,

    init = function(self, eps, dy)
        Tab.init(self, eps, dy)


        local categories = {"main game", "dlc"}
        local button_dy = 20
        local button_w = 130
        local button_h = 30

        self.buttons = {} -- buttons for each category
        self.lists = {} -- puzzle list for each category
        for i, name in ipairs(categories) do
            local callback = function(b) self.active_list = self.lists[i] end
            local b = Button(self.pos.x + border_w + (self.w - 2 * border_w) * i / (#categories + 1) - button_w / 2, self.pos.y + button_dy, button_w, 30, callback, name, FONTS.fira(20), nil, nil, Color.black(), 'line')
            b.text_color = Color.black()
            table.insert(self.buttons, b)
            local obj = {
                pos = Vector(self.pos.x + border_w, self.pos.y + button_dy + button_h + 20),
                getHeight = function(obj) return obj.true_h end,
                draw = function() self:list_draw() end,
                mousePressed = function(obj, ...) self:list_mousePressed(...) end,
                mouseMoved = function(obj, x, y) obj.mx, obj.my = x, y end,
                true_h = 0, mx = 0, my = 0
            }
            table.insert(self.lists, ScrollWindow(self.w - 2 * border_w, self.pos.y + self.h - obj.pos.y, obj))
        end
        self.active_list = self.lists[1]

        self:refresh()

        self.tp = "puzzle_list_tab"
        self:setId("puzzle_list_tab")
    end
}

function PuzzleListTab:draw()
    for _, b in ipairs(self.buttons) do
        b:draw()
    end
    self.active_list:draw()
end

function PuzzleListTab:mousePressed(x, y, but)
    if but ~= 1 then return end
    for _, b in ipairs(self.buttons) do
        b:checkCollides(x, y)
    end
    self.active_list:mousePressed(x, y, but)
end

function PuzzleListTab:refresh()
    -- refresh the puzzle list
    -- for now just checks the emails for available puzzles
    local l = self.active_list
    l.buttons = {}
    table.insert(l.buttons, AuthorButton(self.pos.x + border_w, 0, self.w - 2 * border_w, 40, "Janine Leubwitz", {{name = "Puzzle Name", id = "puzzle id", status = "completed"}}))
    table.insert(l.buttons, AuthorButton(self.pos.x + border_w, 0, self.w - 2 * border_w, 40, "Olivia Kavanagh", {{name = "Puzzle Name2", id = "puzzle id2", status = "open"}, {name = "Very very very very very long puzzle name", id = "puzzle id3", status = "completed"}}))
end

function PuzzleListTab:mouseMoved(x, y)
    local o = self.active_list.obj
    if not Util.pointInRect(x, y, o.pos.x, o.pos.y, self.active_list.w, self.active_list.h) then
        o.mx, o.my = 0, 0
    end
    self.active_list:mouseMoved(x, y)
end
function PuzzleListTab:mouseReleased(...) self.active_list:mouseReleased(...) end
function PuzzleListTab:mouseScroll(...) self.active_list:mouseScroll(...) end
function PuzzleListTab:update(...) self.active_list:update(...) end

function PuzzleListTab:list_draw()
    local y = self.active_list.obj.pos.y
    local sep_h = 10
    local mx, my = self.active_list.obj.mx, self.active_list.obj.my
    for _, b in ipairs(self.active_list.buttons) do
        b.pos.y = y
        y = y + b:draw(mx, my) + sep_h
    end
    self.active_list.obj.true_h = y - self.active_list.obj.pos.y
end

function PuzzleListTab:list_mousePressed(x, y, but)
    for _, b in ipairs(self.active_list.buttons) do
        b:checkCollides(x, y)
    end
end
