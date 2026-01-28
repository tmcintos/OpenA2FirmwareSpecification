-- Shift headings for PDF generation only
-- Removes the first level 1 heading (document title, redundant with title page)
-- Promotes all other headings up one level (H2->H1, H3->H2, etc.)

local first_h1_removed = false

function Header(el)
  -- Remove the first H1 heading entirely
  if el.level == 1 and not first_h1_removed then
    first_h1_removed = true
    return {}  -- Remove this heading and its content would naturally follow
  end
  
  -- Promote all other headings up one level
  el.level = el.level - 1
  
  -- Safety check - don't go below level 1
  if el.level < 1 then
    el.level = 1
  end
  
  return el
end
