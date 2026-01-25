-- Wrap ESC character (U+241B) with Apple Symbols font
function Str(el)
  if el.text:find("\u{241B}") then
    local parts = {}
    for char in el.text:gmatch(utf8.charpattern or ".") do
      if char == "\u{241B}" then
        parts[#parts+1] = pandoc.RawInline("latex", "\\sym{\u{241B}}")
      else
        parts[#parts+1] = pandoc.Str(char)
      end
    end
    return parts
  end
  return el
end
