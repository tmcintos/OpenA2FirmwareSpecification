-- pandoc-raw-html.lua
-- A Pandoc Lua filter to pass through RawInline HTML without modification.

function RawInline (elem)
  if elem.format == "html" then
    return elem
  end
end

function RawBlock (elem)
  if elem.format == "html" then
    return elem
  end
end
