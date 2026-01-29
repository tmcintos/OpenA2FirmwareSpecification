-- Pandoc Lua filter to remove HTML anchors from heading content
-- This prevents the anchors from appearing in the table of contents
-- while keeping them in other contexts

function Header(elem)
  local new_content = {}
  
  for _, inline in ipairs(elem.content) do
    if inline.t == "RawInline" and inline.format == "html" then
      -- Skip anchor tags entirely
      if not (inline.text:match('<a%s+id%s*=%s*"') or inline.text:match('%</a>')) then
        table.insert(new_content, inline)
      end
    else
      table.insert(new_content, inline)
    end
  end
  
  elem.content = new_content
  return elem
end

return {{Header = Header}}
