
weaks = %w(
der/die/das
derselb-/derjenig-
dies-/jen-/jeglich-/jed-
manch-/solch-/welch-
alle
beide
)

mixed = %w(ein-/kein-/eine/keine mein-/dein-/ihr-...)

strongs = %w(
-
etwas/mehr
wenig-/viel-/mehrer-/einig-
##
ein paar/bisschen
)

def xprint(title, arr)
  genders = %w(1M 2F 3N 4Pl)
  cases = %w(nom acc dat gen)
  entries = genders.
              product(cases).
              map { |e| e.join(' + ') }.
              map { |e| e.gsub!(/\d/, '') }.
              map { |e| "- [ ] #{e}" }
  ret = []
  arr.each do |e|
    ret << "*** #{e} (#{title}) [/]"
    ret += entries
  end

  return ret
end

items = xprint('weak', weaks) + xprint('mixed', mixed) + xprint('strong', strongs)
# puts items.size
puts items
