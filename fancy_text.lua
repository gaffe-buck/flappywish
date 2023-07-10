function fancy_text(config)
    if not config.x then config.x = 0 end
    if not config.y then config.y = 0 end
    assert(config.text, "missing text")
    if config.bubble_depth then assert(config.background_color, "missing background color") end
    if not config.text_colors then config.text_colors = { 7 } end
    assert(type(config.text_colors) == "table", "text_colors must be a table")
    if config.wiggle then
        assert(config.wiggle.amp 
            and config.wiggle.speed
            and config.wiggle.offset, 
            "missing wiggle.amp or wiggle.speed or wiggle.offset")
    end

    if not config.letter_width then
        if config.big then config.letter_width = 8
        else config.letter_width = 4 end
    end
    
    local WHITE = 7
    local BACKGROUND_Y_OFFSET = 2
    local BACKGROUND_Y_HEIGHT = 6
    local background_x_offset = config.letter_width - 2
    if config.big then
        BACKGROUND_Y_OFFSET = 3
        BACKGROUND_Y_HEIGHT = 12
        background_x_offset = config.letter_width - 5
    end
    local letters_count = #config.text

    local function print_fancy_big(text, colors, x, y)
        local colors_count = 1
        for i = 1, letters_count do
            local prefix = ""
            if config.big then prefix = "\^t\^w" end
            local x_offset = (i - 1) * config.letter_width
            local y_offset = 0
            if config.wiggle then
                y_offset = sin(t() * config.wiggle.speed + (i * config.wiggle.offset)) * config.wiggle.amp
            end
            print(prefix .. text[i], 
                x + x_offset, 
                y + y_offset, 
                colors[colors_count])
            colors_count += 1
            if colors_count > #colors then
                colors_count = 1
            end
        end
    end

    if config.background_color then
        rectfill(
            config.x - background_x_offset, 
            config.y - BACKGROUND_Y_OFFSET, 
            config.x + letters_count * config.letter_width, 
            config.y + BACKGROUND_Y_HEIGHT,
            config.background_color)

        if config.bubble_depth then
            for i = 1, config.bubble_depth do
            rectfill(
                config.x - background_x_offset - i, 
                config.y - BACKGROUND_Y_OFFSET + i, 
                config.x + letters_count * config.letter_width + i, 
                config.y + BACKGROUND_Y_HEIGHT - i,
                config.background_color)
            rectfill(
                config.x - background_x_offset + i, 
                config.y - BACKGROUND_Y_OFFSET - i,
                config.x + letters_count * config.letter_width - i, 
                config.y + BACKGROUND_Y_HEIGHT + i,
                config.background_color)
            end
        end
    end

    if config.outline_color then
        for i = -1, 1 do
            print_fancy_big(config.text, {config.outline_color}, config.x - i, config.y)
            print_fancy_big(config.text, {config.outline_color}, config.x, config.y + i)
        end
    end

    print_fancy_big(config.text, config.text_colors, config.x, config.y)
end