VERSION = "0.1.0"

local micro = import("micro")
local config = import("micro/config")
local buffer = import("micro/buffer")
local util = import("micro/util")

function case(bp, caseFunction)
  local a, b, c = nil, nil, bp.Cursor
  local selection = c:GetSelection()

  -- This does not work
  -- local cursors = bp.Buf:GetCursors()

  -- for i, c in pairs(cursors) do
	-- 	micro.Log(c)
	-- end

  -- Try to make a selection
  if not c:HasSelection() then
    c:SelectWord()
  end

  if c:HasSelection() then
    if c.CurSelection[1]:GreaterThan(-c.CurSelection[2]) then
        a, b = c.CurSelection[2], c.CurSelection[1]
    else
        a, b = c.CurSelection[1], c.CurSelection[2]
    end
    a = buffer.Loc(a.X, a.Y)
    b = buffer.Loc(b.X, b.Y)
    selection = c:GetSelection()

    selection = util.String(selection)
  else
    return
  end

  selection = normalize(selection)

  local modifiedSelection = string.gsub(selection, ".*", normalize)
  modifiedSelection = string.gsub(modifiedSelection, ".*", caseFunction)
  bp.Buf:Replace(a, b, modifiedSelection)
  -- Select text again
  c.CurSelection[1] = a
  c.CurSelection[2] = buffer.Loc(a.X + modifiedSelection:len(), a.Y)
end

function normalize(text)
  -- Tries to turn a text into a lower case sentence
  -- Trim string
  text = text:gsub("^%s*(.-)%s*$", "%1")
  -- Return early if string is a sentence (has spaces in it)
  if text:match("%s") then
    return text:lower()
  end
  -- Split words
  text = text:gsub("(%u%l+)", " %1")
  text = text:gsub("^%l+", "%1 ")
  -- Remove underscores etc
  text = text:gsub("[^%a]", " ")
  -- Remove double spaces
  text = text:gsub("%s+", " ")
  text = text:lower()
  return text
end

-- [ Case Functions ] --

function camelCase(text)
  -- Turns a lower case sentence into camelCase
  text = pascalCase(text)
  text = text:gsub("^%u", string.lower)
  return text
end

function constantCase(text)
  -- Turns a lower case sentence into CONSTANT_CASE
  text = text:gsub("%s+", "_")
  text = text:upper()
  return text
end

function dotCase(text)
  -- Turns a lower case sentence into dot.case
  text = text:gsub("%s+", ".")
  text = text:lower()
  return text
end

function kebabCase(text)
  -- Turns a lower case sentence into kebab-case
  text = text:gsub("%s+", "-")
  text = text:lower()
  return text
end

function lowerCase(text)
  -- Turns a lower case sentence into lower case
  text = text:lower()
  return text
end

function pascalCase(text)
  -- Turns a lower case sentence into PascalCase
  text = titleCase(text)
  text = text:gsub("%s+", "")
  return text
end

function pathCase(text)
  -- Turns a lower case sentence into path/case
  text = text:gsub("%s+", "-")
  text = text:lower()
  return text
end

function snakeCase(text)
  -- Turns a lower case sentence into snake_case
  text = text:gsub("%s+", "_")
  text = text:lower()
  return text
end

function titleCase(text)
  -- Turns a lower case sentence into Title Case
  text = text:gsub("(%a)([%w_']*)", function (first, rest)
    return first:upper()..rest:lower()
  end)
  return text
end

function upperCase(text)
  -- Turns a lower case sentence into UPPER CASE
  text = text:upper()
  return text
end

-- [ Connectors ] --
function camel(bp) case(bp, camelCase) end
function constant(bp) case(bp, constantCase) end
function dot(bp) case(bp, dotCase) end
function kebab(bp) case(bp, kebabCase) end
function lower(bp) case(bp, lowerCase) end
function nocase(bp) case(bp, normalize) end
function pascal(bp) case(bp, pascalCase) end
function path(bp) case(bp, pathCase) end
function snake(bp) case(bp, snakeCase) end
function title(bp) case(bp, titleCase) end
function upper(bp) case(bp, upperCase) end

function init()
  config.MakeCommand("case.camel", camel, config.NoComplete)
  config.MakeCommand("case.constant", constant, config.NoComplete)
  config.MakeCommand("case.dot", dot, config.NoComplete)
  config.MakeCommand("case.kebab", kebab, config.NoComplete)
  config.MakeCommand("case.lower", lower, config.NoComplete)
  config.MakeCommand("case.nocase", nocase, config.NoComplete)
  config.MakeCommand("case.pascal", pascal, config.NoComplete)
  config.MakeCommand("case.path", path, config.NoComplete)
  config.MakeCommand("case.snake", snake, config.NoComplete)
  config.MakeCommand("case.title", title, config.NoComplete)
  config.MakeCommand("case.upper", upper, config.NoComplete)

  config.AddRuntimeFile("case", config.RTHelp, "help/case.md")
end
