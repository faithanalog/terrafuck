local C = terralib.includecstring [[
    #include <stdio.h>
]]


function move_ptr_right(ptr, mem)
    return quote
        ptr = (ptr + 1) % [ mem.type.N ]
    end
end

function move_ptr_left(ptr, mem)
    return quote
        ptr = (ptr - 1) % [ mem.type.N ]
    end
end

function inc_cell(ptr, mem)
    return quote
        mem[ptr] = mem[ptr] + 1
    end
end

function dec_cell(ptr, mem)
    return quote
        mem[ptr] = mem[ptr] - 1
    end
end

function output_cell(ptr, mem)
    return quote
        C.putchar(mem[ptr])
    end
end

function input_cell(ptr, mem)
    return quote
        mem[ptr] = C.getchar()
    end
end

function do_loop(ptr, mem, body)
    return quote
        while mem[ptr] ~= 0 do
            [ body ]
        end
    end
end

function compile_lp(s, i, ptr, mem)
    local qq = {}
    while i <= #s do
        local c = s:sub(i,i)
        i = i + 1
        if c == ">" then
            table.insert(qq, move_ptr_right(ptr, mem))
        elseif c == "<" then
            table.insert(qq, move_ptr_left(ptr, mem))
        elseif c == "+" then
            table.insert(qq, inc_cell(ptr, mem))
        elseif c == "-" then
            table.insert(qq, dec_cell(ptr, mem))
        elseif c == "." then
            table.insert(qq, output_cell(ptr, mem))
        elseif c == "," then
            table.insert(qq, input_cell(ptr, mem))
        elseif c == "[" then
            local body
            body, i = compile_lp(s, i, ptr, mem)
            table.insert(qq, do_loop(ptr, mem, body))
        elseif c == "]" then
            return qq, i
        end
    end
    return qq, i
end

function compile(ptr, mem)
    local f = io.open(arg[1])
    local s = f:read()
    return compile_lp(s, 1, ptr, mem)
end

terra main()
    var ptr : int = 0
    var mem : int[8192]
    for i = 0, [ mem.type.N ] do
        mem[i] = 0
    end
    [ compile(ptr, mem) ]
end

terralib.saveobj(arg[1] .. "-exe", { main = main } )