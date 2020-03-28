--[[
-- Install script to ~/.local/share/vlc/lua/extensions/dirty-sexual-skipper.lua
-- Profiles saved to: ~/.config/vlc/dirty-sexual-skipper.conf
]]

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

    dialog:add_label("<center><h3>Movie Profile</h3></center>", 1, 1, 2, 1)
    dialog:add_button("Load", populate_profile_fields, 1, 3, 1, 1)
    dialog:add_button("Delete", delete_profile, 2, 3, 1, 1)

    dialog:add_label("", 1, 4, 2, 1)

    dialog:add_label("<center><h3>Settings</h3></center>", 1, 5, 2, 1)

    dialog:add_label("Profile name:", 1, 6, 1, 1)
    profile_name_input = dialog:add_text_input("", 2, 6, 1, 1)

    dialog:add_label("time clips from,to .. (s):", 1, 7, 1, 1)
    time_clips_input = dialog:add_text_input("", 2, 7, 1, 1)

    dialog:add_button("Save", save_profile, 1, 9, 2, 1)

    dialog:add_label("", 1, 10, 2, 1)
    dialog:add_label("<center><strong>Ensure your playlist is queued<br/>before pressing start.</strong></center>", 1, 11, 2, 1)
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
    if start_time_input.get_text() == "" then start_time_input.set_text("0") end

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

    local time_clips = time_clips_input:get_text()
    -- proof of concept

    for _, child in pairs(children) do
        local options = {}

        table.insert(options, "start-time=" .. 0)
        table.insert(options, "stop-time=" .. 15)


        vlc.playlist.enqueue({
            {
                path = child.path,
                name = child.name,
                duration = child.duration,
                options = options
            }
        })

        local options = {}

        table.insert(options, "start-time=" .. 40)
        table.insert(options, "stop-time=" .. 50)

        vlc.playlist.enqueue({
            {
                path = child.path,
                name = child.name,
                duration = child.duration,
                options = options
            }
        })
    end

    dialog:hide()
    vlc.playlist.play()
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
                time_clips = time_clips
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
