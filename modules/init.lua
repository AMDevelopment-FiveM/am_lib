local known = {
    'npc','target','inventory','dispatch','vehicles','ui','permissions','callbacks','logging','security',
    'database','billing','society','usable','metadata','objects','zones','blips','animations','fuel','keys',
    'garage','banking','boss','phone','doorlock','crafting','shops','weapons','entities','network','skillcheck','minigame','adapters'
}

for _, name in ipairs(known) do
    AM.Module.Register(name, { enabled = AM.Module.Enabled(name) })
end
