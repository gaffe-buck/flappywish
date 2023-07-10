function _collide(a1, a2)
    if a1.x < a2.x + a2.w and
        a1.x + a1.w > a2.x and 
        a1.y < a2.y + a2.h and
        a1.h + a1.y > a2.y then
            return true
        else
            return false
        end
end

function update_star(star)
    if not star.awake_at then 
        return false
    end    
    if t() > star.awake_at then
        star.x -= objects_speed
    end
    if star.x < 0 - 8 then
        return false
    else
        return true
    end
end

function draw_star(star)
    color(9)
    print("★", star.x+1, star.y)
    print("★", star.x-1, star.y)
    print("★", star.x, star.y+1)
    print("★", star.x, star.y-1)
    color(10)
    print("★", star.x, star.y)
    color()
end

function update_mine(mine)
    if not mine.awake_at then 
        return false
    end
    if t() > mine.awake_at then
        mine.x -= objects_speed + (0.125 * ((t()-start_time)\5))
    end
    if mine.x < 0 - 8 then
        return false
    else
        return true
    end
end

function draw_mine(mine)
    color(0)
    print("☉", mine.x+1, mine.y)
    print("☉", mine.x-1, mine.y)
    print("☉", mine.x, mine.y+1)
    print("☉", mine.x, mine.y-1)
    color(8)
    print("☉", mine.x, mine.y)
    color()
end

function draw_cloud(cloud)
    spr(cloud.frame, cloud.x, cloud.y, 2, 2, cloud.flipx, cloud.flipy) 
end

function draw_wish(x, y, frame)
    local outline_color = 0
    pal({
        [1] = outline_color,
        [2] = outline_color,
        [3] = outline_color,
        [4] = outline_color,
        [5] = outline_color,
        [6] = outline_color,
        [7] = outline_color,
        [8] = outline_color,
        [9] = outline_color,
        [10] = outline_color,
        [11] = outline_color,
        [12] = outline_color,
        [13] = outline_color,
        [14] = outline_color,
        [15] = outline_color,
    })
    spr(frame, x+1, y, 2, 2) 
    spr(frame, x-1, y, 2, 2) 
    spr(frame, x, y+1, 2, 2) 
    spr(frame, x, y-1, 2, 2) 
    pal()
    spr(frame, x, y, 2, 2)
end

function _init()
    wish_alive = true
    wish_animate_after = t() + 0.5
    wish_x = 64 - 8
    wish_y = 64 - 8
    wish_y_velocity = 0
    wish_frame = 0
    flapped = false
    flight_impulse = 3
    gravity = 0.25
    stars = {}
    mines = {}
    clouds = {
        {x = 16, y = 16, frame = 32, flipx = false, flipy = false},
        {x = 64 - 8, y = 64 - 8, frame = 34, flipx = false, flipy = false},
        {x = 128 - 16, y = 128 - 16, frame = 36, flipx = false, flipy = false},
    }
    objects_speed = 1
    juice = {}
    ready = false
    top_score = top_score or 0
    score = 0
    cooldowns = {0.01, 0.1, 0.125, 0.25, 0.33, 0.5, 0.66, 0.75, 1}
    start_time = 0
end

function game_over()
    wish_alive = false 
    add(juice, make_splash(wish_x + 8, wish_y + 8, {5, 7, 10, 9, 12, 13}))
    top_score = top_score > score and top_score or score
end

function _update60()
    if btn(❎) and not ready then
        ready = true
        start_time = t()
    end
    if wish_alive then
        if t() > wish_animate_after then
            if wish_frame == 0 then 
                wish_frame = 2
            elseif wish_frame == 2 then 
                wish_frame = 0
            end
            wish_animate_after = t() + 0.5
        end
    end
    if wish_alive and ready then
        if btn(❎) and flapped == false then
            sfx(1)
            wish_y_velocity = -flight_impulse
            flapped = true
        elseif not btn(❎) then
            flapped = false
        end
        wish_y += wish_y_velocity
        wish_y_velocity += gravity
        if wish_x > 16 then
            wish_x -= 1
        end
        if wish_y > 128 or wish_y < - 16 then 
            sfx(0)
            game_over()
        end
        if #mines < (t() - start_time) \ 5 then
            add(mines, {})
        end
        if #stars < 1 then
            add(stars, {x = 128, y = rnd(120), awake_at = t() + rnd(cooldowns)})
            if flr(rnd(2)) > 0 then
                add(stars, {x = 128, y = rnd(120), awake_at = t() + rnd(cooldowns)})
            end
        end
        if #mines < (t()-start_time)\10 + 1 then
            local awake_at = t() + rnd(cooldowns)
            add(mines, {x = 129, y = rnd(120), awake_at = awake_at})
        end
    end
    for mine in all(mines) do
        local alive = update_mine(mine)
        if not alive then 
            del(mines, mine)
        else
            local a1 = {
                x = wish_x + 4, 
                y = wish_y + 4, 
                h = 8, 
                w = 8
            }
            local a2 = {
                x = mine.x + 2, 
                y = mine.y + 2, 
                h = 4, 
                w = 4
            }
            if wish_alive and _collide(a1, a2) then
                sfx(3)
                game_over()
            end
        end
    end
    for star in all(stars) do
        local alive = update_star(star)
        if not alive then 
            del(stars, star) 
        else
            local a1 = {
                x = wish_x, 
                y = wish_y, 
                h = 16, 
                w = 16
            }
            local a2 = {
                x = star.x, 
                y = star.y, 
                h = 8, 
                w = 8
            }
            if wish_alive and _collide(a1, a2) then
                sfx(2)
                score += 1
                del(stars, star)
            end
        end
    end
    for cloud in all(clouds) do
        if cloud.x < -16 then
            cloud.x = 128 + 16
            cloud.y = flr(rnd(128 - 16))
        end
        cloud.x -= 2
    end
    for splash in all(juice) do
        local juice_result = splash:update()
        if juice_result then del(juice, splash) end
    end
    if not wish_alive and btn(🅾️) then
        _init()
    end
end

function _draw()
    cls(12)
    
    for cloud in all(clouds) do
        draw_cloud(cloud)
    end

    fancy_text({
        text = "flappy wish",
        text_colors = { 7 },
        background_color = 13,
        bubble_depth = 2,
        x = 20,
        y = 7,
        outline_color = 12,
        wiggle = {
            amp = 1.25,
            speed = 1.5,
            offset = 0.33
        },
        letter_width = 8,
        big = true
    })
    color(13)
    print("by gaffe for ari - artfight2023", 2, 17 + 8)
    color()

    for splash in all(juice) do
        splash:draw()
    end

    for mine in all(mines) do
        draw_mine(mine)
    end

    for star in all(stars) do
        draw_star(star)
    end

    if wish_alive then 
        color(13)
        print("score: "..score, 2, 128-7)
        color()
        draw_wish(wish_x, wish_y, wish_frame) 
        if not ready then
            local text_y = 64 + 16
            local text_x = 28
            fancy_text({
                text = "press ❎  to start",
                text_colors = { 1 },
                background_color = 7,
                x = text_x,
                y = text_y,
                bubble_depth = 1,
            })
        end
    else
        local text_y = 64
        local text_x = 28
        fancy_text({
            text = "game over!",
            text_colors = { 1 },
            background_color = 7,
            x = text_x,
            y = text_y,
            bubble_depth = 1,
        })
        fancy_text({
            text = "your score: "..score,
            text_colors = { 1 },
            background_color = 7,
            x = text_x + 8,
            y = text_y + 11,
            bubble_depth = 1,
        })
        fancy_text({
            text = "high score: "..top_score,
            text_colors = { 1 },
            background_color = 7,
            x = text_x + 16,
            y = text_y + 22,
            bubble_depth = 1,
        })
        fancy_text({
            text = "press 🅾️  to try again",
            text_colors = { 1 },
            background_color = 7,
            x = text_x,
            y = text_y + 33,
            bubble_depth = 1,
        })
    end
end