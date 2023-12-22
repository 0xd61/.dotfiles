local ls = require("luasnip")
-- some shorthands...
local snip = ls.snippet
local node = ls.snippet_node
local text = ls.text_node
local insert = ls.insert_node
local func = ls.function_node
local choice = ls.choice_node
local dynamicn = ls.dynamic_node

function date()
    return os.date('%Y/%m/%d')
end

function todo(_, _, comment)
    return comment .. " TODO(dgl): "
end

function note(_, _, comment)
    return comment .. " NOTE(dgl): "
end

ls.add_snippets(nil, {
    all = {
        snip({
            trig = "date",
            namr = "Date",
            dscr = "Date in the form of YYYY/MM/DD",
        }, {
            func(date, {}),
        }),
    },
    c = {
        snip("todo", {
            func(todo, {}, { user_args = { "//" }}),
        }),
        snip("note", {
            func(note, {}, { user_args = { "//" }}),
        }),
        snip("guard", {
            text "#ifndef ",
            insert(1, "Name"),
            func(function(args) return { "", "#define " .. args[1][1], "" } end, {1}),
            insert(0),
            func(function(args) return { "", "", "#endif // " .. args[1][1] } end, {1}),
        })
    },
    cpp = {
        snip("todo", {
            func(todo, {}, { user_args = { "//" }}),
        }),
        snip("note", {
            func(note, {}, { user_args = { "//" }}),
        }),
        snip("guard", {
            text "#ifndef ",
            insert(1, "Name"),
            func(function(args) return { "", "#define " .. args[1][1], "" } end, {1}),
            insert(0),
            func(function(args) return { "", "", "#endif // " .. args[1][1] } end, {1}),
        })
    },
    go = {
        snip("todo", {
            func(todo, {}, { user_args = { "//" }}),
        }),
        snip("note", {
            func(note, {}, { user_args = { "//" }}),
        }),
        snip("ife", {
            text "if err != nil",
            text { " {", "" },
            text "\t",
            insert(0),
            text { "", "}" },
        }),
    },
    lua = {
        snip("todo", {
            func(todo, {}, { user_args = { "--" }}),
        }),
        snip("note", {
            func(note, {}, { user_args = { "--" }}),
        }),
    },
})

