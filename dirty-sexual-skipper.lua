



function descriptor()
    return {
        title = "Dirty Sexual Skipper",
        version = "1.0.0",
        author = "Mohamed Okasha",
        url = "https://github.com/mohamed-okasha/dirty-sexual-skipper.git",
        shortdesc = "Dirty Sexual Skipper",
        description = "Dirty Sexual Skipper",
        capabilities = {}
    }
end

function activate()
    profiles = {}
    config_file = vlc.config.configdir() .. "/ds-skipper.conf"

    if (file_exists(config_file)) then
        load_all_profiles()
    end

    open_dialog()
end

function deactivate()
    dialog:delete()
end

function close()
    vlc.deactivate()
end

function meta_changed()
end

function open_dialog()
    dialog = vlc.dialog(descriptor().title)

    dialog:add_label("<center><h3>Profile</h3></center>", 1, 1, 2, 1)
    dialog:add_button("Load", populate_profile_fields, 1, 3, 1, 1)
    dialog:add_button("Delete", delete_profile, 2, 3, 1, 1)

    dialog:add_label("", 1, 4, 2, 1)

    dialog:add_label("<center><h3>Settings</h3></center>", 1, 5, 2, 1)

    dialog:add_label("Profile name:", 1, 6, 1, 1)
    profile_name_input = dialog:add_text_input("", 2, 6, 1, 1)

    

    dialog:add_label("time clips from,to .. (s):", 1, 7, 1, 1)
    time_clips_input = dialog:add_text_input("", 2, 7, 1, 1)
    dialog:add_label("<center>Example: 00:00:01,00:02:00 01:00:00,01:12:00  </center>", 1, 8, 2, 1)


    dialog:add_button("Save", save_profile, 1, 9, 2, 1)

    dialog:add_label("", 1, 10, 2, 1)
    dialog:add_button("Start Playlist", start_playlist, 1, 12, 2, 1)

    populate_profile_dropdown()
    populate_profile_fields()
end

function populate_profile_dropdown()
    profile_dropdown = dialog:add_dropdown(1, 2, 2, 1)

    for i, profile in pairs(profiles) do
        profile_dropdown:add_value(profile.name, i)
    end
end

function populate_profile_fields()
    local profile = profiles[profile_dropdown:get_value()]

    if profile then
        profile_name_input:set_text(profile.name)
        time_clips_input:set_text(profile.time_clips)
    end
end

function delete_profile()
    local dropdown_value = profile_dropdown:get_value()

    if profiles[dropdown_value] then
        profiles[dropdown_value] = nil
        save_all_profiles()
    end
end

function save_profile()
    if profile_name_input:get_text() == "" then return end
    if time_clips_input:get_text() == "" then time_clips_input:set_text("0") end

    local updated_existing = false

    for _, profile in pairs(profiles) do
        if profile.name == profile_name_input:get_text() then
            profile.time_clips = time_clips_input:get_text()
            updated_existing = true
        end
    end

    if not updated_existing then
        table.insert(profiles, {
            name = profile_name_input:get_text(),
            time_clips = time_clips_input:get_text()
        })
    end

    save_all_profiles()
end

function trimString( s )
    return string.match( s, "^()%s*$" ) and "" or string.match( s, "^%s*(.*%S)" )
end

function split(s, delimiter)
    result = {};
    s= trimString(s);
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function start_playlist()
    if time_clips_input:get_text() == "" then return end

    local playlist = vlc.playlist.get("playlist", false)
    local children = {}
    for _, child in pairs(playlist.children) do
        if child.duration ~= -1 then
            table.insert(children, {
                path = child.path,
                name = child.name,
                duration = child.duration
            })
        end
    end

    vlc.playlist.clear()

    local time_clips_list = time_clips_input:get_text();
        -- proof of concept

    local START_TIME  = 1;
    local END_TIME  = 2;
    
    for _, child in pairs(children) do
            
            time_clips = split(time_clips_list, " +")
    
            start_time = 0;
            for _,clip in pairs(time_clips) do
                start_stop_array = split(clip, ',')
                stop_time = start_stop_array[START_TIME];

                enqueue_in_playlist(child.path, child.name, child.duration, start_time, stop_time);
                
                start_time = start_stop_array[END_TIME];
            end
    
            enqueue_in_playlist(child.path, child.name, child.duration, start_time, child.duration);

    end

    dialog:hide()
    vlc.playlist.play()
end

function enqueue_in_playlist(path, name, duration, from, to)

    local options = {};
    
    from = split(from, ":");
    to = split(to, ":");

    if (table.getn(from) > 1) then
        from_seconds = tonumber(from[1])*60*60 + tonumber(from[2])*60 + tonumber(from[3]);
    else
        from_seconds = tonumber(from[1]);
    end

    if (table.getn(to) > 1) then
        to_seconds = tonumber(to[1])*60*60 + tonumber(to[2])*60 + tonumber(to[3]);
    else
        to_seconds = tonumber(to[1]);
    end
    
    table.insert(options, "start-time=" .. from_seconds);
    table.insert(options, "stop-time=" .. to_seconds);

    vlc.playlist.enqueue({
        {
            path = path,
            name = name,
            duration = duration,
            options = options
        }
    })

end

function save_all_profiles()
    io.output(config_file)
    for _, profile in pairs(profiles) do
        io.write(profile.name)
        io.write("=")
        io.write(profile.time_clips)
        io.write("\n")
    end
    io.close()

    dialog:del_widget(profile_dropdown)
    populate_profile_dropdown()
end

function load_all_profiles()
    local lines = lines_from(config_file)

    for _, line in pairs(lines) do
        for name, time_clips in string.gmatch(line, "(.+)=(.+)") do
            table.insert(profiles, {
                name = name,
                time_clips = time_clips,
            })
        end
    end
end

function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

function lines_from(file)
    local lines = {}

    for line in io.lines(file) do
        lines[#lines + 1] = line
    end

    return lines
end
