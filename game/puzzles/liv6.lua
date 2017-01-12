name = "Complete Brainfuck Interpreter"
-- Puzzle number
n = "C.6"

lines_on_terminal = 60
memory_slots = 120

-- Bot
bot = {'b', "NORTH"}

local ans = {}
local v_code, v_in

local function create_ans()
    local mem, dp = {}, 1 -- data and data pointer
    for i = 1, 20 do mem[i] = 0 end

    -- processing matching brackets
    local match = {} -- stores matching brackets
    do
        local st = {} -- stack for loops
        for i, op in _G.ipairs(v_code) do
            if     op == '[' then _G.table.insert(st, i)
            elseif op == ']' then match[st[#st]] = i; match[i] = st[#st]; st[#st] = nil
            end
        end
    end

    local inp, ip = 1, 1 -- next position of v_in and v_code to read
    while v_code[ip] ~= 0 do
        local op = v_code[ip]
        if     op == '+' then mem[dp] = mem[dp] + 1
        elseif op == '-' then mem[dp] = mem[dp] - 1
        elseif op == '.' then _G.table.insert(ans, mem[dp])
        elseif op == ',' then mem[dp] = v_in[inp]; inp = inp + 1
        elseif op == '<' then dp = dp == 1  and 20 or dp - 1
        elseif op == '>' then dp = dp == 20 and 1  or dp + 1
        elseif op == '[' then ip = mem[dp] == 0 and match[ip] or ip
        elseif op == ']' then ip = mem[dp] ~= 0 and match[ip] or ip
        else _G.assert(false) end
        ip = ip + 1
    end
end

local function add(code, x)
    for i = 1, x, 1 do
        _G.table.insert(code, '+')
    end
    for i = -1, x, -1 do
        _G.table.insert(code, '-')
    end
end

local function ins(code, str)
    if _G.type(str) == 'number' then
        _G.table.insert(code, str)
    else
        for c in str:gmatch('.') do
            _G.table.insert(code, c)
        end
    end
end

local function rnd() return _G.love.math.random(5, 10) end

local function create_vecs()
    v_code, v_in = {}, {}
    ins(v_code, ",[>,][+]<[->+++<<++>]<.>>.>")
    for i = 1, _G.love.math.random(5, 9) do ins(v_in, rnd()) end
    ins(v_in, 0)
    add(v_code, 2)
    for i = 1, 5 do
        ins(v_code, '[->')
        add(v_code, _G.love.math.random() < .6 and 1 or 2)
    end
    ins(v_code, '.')
    for i = 1, 5 do
        ins(v_code, '<]')
    end
    ins(v_code, "<<<[.<]")
    ins(v_code, 0)
    create_ans()
end

local function create_code()
    if not v_code then
        create_vecs()
    end
    return v_code
end

local function create_in()
    if not v_code then
        create_vecs()
    end
    return v_in
end

-- name, draw background, image
o = {"obst", false, "wall_none"}
c = {"console", false, "console", "green", args = create_in, dir = "east"}
d = {"console", false, "console", "blue", args = {}, dir = "west"}
e = {"console", false, "console", "white", args = create_code, dir = "south"}

-- console objects
local bl

-- create ans vector
function on_start(room)
    -- finds consoles
    for i = 1, 20 do
        for j = 1, 20 do
            local o = room.grid_obj[i][j]
            if o and o.tp == 'console' and #o.out == 0 then
                bl = o
            end
        end
    end
end

-- Objective
objective_text = [[
You must implement a brainfuck interpreter. The instructions will be on the white console, the input on the green console and the output must be written to the blue console.
- It should support the instructions ,.<>+-[]
- After the instructions, there will be a number 0 on the white console.]]
function objective_checker(room)
    if #bl.inp == 0 then return false end
    if #bl.inp > #ans then
        _G.StepManager.stop("Wrong output", "Too many numbers!", "Retry")
        return false
    end
    for i = 1, #bl.inp do
        if bl.inp[i] ~= ans[i] then
            _G.StepManager.stop("Wrong output", "Expected " .. ans[i] .. " got " .. bl.inp[i], "Retry")
            return false
        end
    end
    return #bl.inp == #ans
end

extra_info = [[
The size of the cyclic memory should be exactly 20.
- There will be at most 80 instructions.
- The will be at most 5 levels of nested loops.
- You have 120 register positions.
- Refer to Liv's email for details on the instructions and language.]]

grid_obj =  "oooooooooooooooooooo"..
            ".........oo........."..
            ".........oo........."..
            ".........oo........."..
            ".........oo........."..
            ".........oo........."..
            ".........oo........."..
            ".........oo........."..
            ".........eo........."..
            "oooooooocbdooooooooo"..
            "wwwwwwwwwwwwwwwwwwww"..
            "wwwwwwwwwwwwwwwwwwww"..
            "wwwwwwwwwwwwwwwwwwww"..
            "wwwwwwwwwwwwwwwwwwww"..
            "wwwwwwwwwwwwwwwwwwww"..
            "wwwwwwwwwwwwwwwwwwww"..
            "wwwwwwwwwwwwwwwwwwww"..
            "wwwwwwwwwwwwwwwwwwww"..
            "wwwwwwwwwwwwwwwwwwww"..
            "wwwwwwwwwwwwwwwwwwww"

-- Floor
w = "white_floor"
_G.getfenv()[','] = "black_floor"
r = "red_tile"

grid_floor = "wwwwwwwwwwwwwwwwwwww"..
             "ww,,wwwwwllwwwww,,ww"..
             "www,,wwwwllwwww,,www"..
             "wwww,,wwwllwww,,wwww"..
             "wwwww,,wwllww,,wwwww"..
             "wwwww,,wwllww,,wwwww"..
             "wwww,,wwwllwww,,wwww"..
             "www,,wwwwllwwww,,www"..
             "ww,,wwwwwwwwwwww,,ww"..
             "lllllllllwwlllllllll"..
             "wwwwwwwwwwwwwwwwwwww"..
             "wwwwww,,wwwwwwwwwwww"..
             "wwwwww,,wwwwwwwwwwww"..
             "wwww,,,,,,w,,,,,wwww"..
             "wwww,,,,,,w,,,,,wwww"..
             "w,,www,,wwwwwwwww,,w"..
             "w,,www,,wwwwwwwww,,w"..
             "wwwwwwwwwwwwwwwwww,w"..
             "wwwwwwwwwwwwwwwwwwww"..
             "wwwwwwwwwwwwwwwwwwww"
