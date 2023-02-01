local PLACEMENT_TAB = "LUA"
local PLACEMENT_SECTION = "B"


local ffi = require('ffi')

--
-- toggle cvar->fnChangeCallback.m_Size to 0, now we can change name 
--
ffi.cdef([[
	struct CUtlVector { 
		void* vtable;
		void* m_Memory[2];
		int m_Size; 
	};
	typedef void*(__thiscall* find_cvar_t)(void*, const char* name);
]])
local cvar_raw = client.create_interface("vstdlib.dll", "VEngineCvar007") or error("Interface not found")
local cvar_real = ffi.cast(ffi.typeof("void***"), cvar_raw) or error("can't cast")
local find_cvar = ffi.cast("find_cvar_t", cvar_real[0][15]) or error("could not find function")

local name_cvar = find_cvar(cvar_raw, "name")
local cvar_raw = ffi.cast("char*", name_cvar)
local fnChangeCallback = ffi.cast("struct CUtlVector*", cvar_raw + 0x44)
local function setName(delay, name)
    client.delay_call(delay, function() 
        client.set_cvar("name", name)
    end)
end

fnChangeCallback.m_Size = 0

--
-- demical to utf8 pasted from https://stackoverflow.com/a/26071044/4973609
--
local bytemarkers = { {0x7FF,192}, {0xFFFF,224}, {0x1FFFFF,240} }
local function utf8(decimal)
  if decimal<128 then return string.char(decimal) end
  local charbytes = {}
  for bytes,vals in ipairs(bytemarkers) do
	if decimal<=vals[1] then
	  for b=bytes+1,2,-1 do
		local mod = decimal%64
		decimal = (decimal-mod)/64
		charbytes[b] = string.char(128+mod)
	  end
	  charbytes[1] = string.char(vals[2]+decimal)
	  break
	end
  end
  return table.concat(charbytes)
end
 
local name_anim = false
local my_name_backup = cvar.name:get_string()

local namespam_type = ui.new_combobox(PLACEMENT_TAB, PLACEMENT_SECTION, "Namse spam type", "Pure spam in chat", "Animations", "Steal")
local steal_from_type = ui.new_combobox(PLACEMENT_TAB, PLACEMENT_SECTION, "Steal from", "Disabled", "Enemies", "Mates", "All")
local system_time_chk = ui.new_checkbox(PLACEMENT_TAB, PLACEMENT_SECTION, "System time")
local twin_towers_chk = ui.new_checkbox(PLACEMENT_TAB, PLACEMENT_SECTION, "Twin Towers")

local use_custom_font_chk = ui.new_checkbox(PLACEMENT_TAB, PLACEMENT_SECTION, "Custom font")

local slide_name_chk = ui.new_checkbox(PLACEMENT_TAB, PLACEMENT_SECTION, "Roll")
local custom_symbol_chk = ui.new_checkbox(PLACEMENT_TAB, PLACEMENT_SECTION, "Custom symbol")
local saved_name = ui.new_string("namespamname", "")
local name_symbol_comb = ui.new_combobox(PLACEMENT_TAB, PLACEMENT_SECTION, "Wrap with", "Empty", "Crown", "Shuriken", "Soviet", "Star", "Random")
local enter_name_lbl = ui.new_label(PLACEMENT_TAB, PLACEMENT_SECTION, "Enter name to spam:")
local namespam_textbox = ui.new_textbox(PLACEMENT_TAB, PLACEMENT_SECTION, "spam_names")
local hint_lbl = ui.new_label(PLACEMENT_TAB, PLACEMENT_SECTION, "blank = current name")
local restore_name_chk = ui.new_checkbox(PLACEMENT_TAB, PLACEMENT_SECTION, "Restore original name")
ui.set(use_custom_font_chk, true)
ui.set(custom_symbol_chk, true)
ui.set(name_symbol_comb, "Shuriken")


local start_animate_btn = ui.new_button(PLACEMENT_TAB, PLACEMENT_SECTION,"< Start Anim>", function() name_anim = true end)
local stop_animate_btn = ui.new_button(PLACEMENT_TAB, PLACEMENT_SECTION, "< Stop Anim>", function() name_anim = false end)
ui.set_visible(stop_animate_btn, false)


local warning_lbl = ui.new_label(PLACEMENT_TAB, PLACEMENT_SECTION, "This prevents to change nickname for 5 min")
local hidenname_btn = ui.new_button(PLACEMENT_TAB, PLACEMENT_SECTION, "Bugged Name", function() 
	client.delay_call(0.1, function () cvar.name:set_string("\n\xAD\xAD\xAD") end)
end)


local save_ref = ui.reference("config", "presets", "Save")
ui.set_callback(save_ref, function()
	ui.set(saved_name, ui.get(namespam_textbox))
end)


local load_ref = ui.reference("config", "presets", "Load")
ui.set_callback(load_ref, function()
	ui.set(namespam_textbox, ui.get(saved_name))
end)
local function make_text_with_font(new_name)
	if ui.get(use_custom_font_chk) == false then return new_name end
	local resulted_name = ""
	for i = 1, #new_name do
		-- check if it's default ascii character convert them
		if string.byte(new_name:sub(i,i)) > 19 and string.byte(new_name:sub(i,i)) < 0x7F then
			resulted_name = resulted_name .. utf8(string.byte(new_name:sub(i,i)) + 0xFEE0)
		else
			resulted_name = resulted_name .. new_name:sub(i,i)
		end
	end
	return resulted_name
end
local nickname_symbols_tbl = {
	Empty = {"", ""}, 
	Crown = {"♛", "♛"},
	Shuriken = {"卐", "卍"},
	Soviet = {"☭", "☭"},
	Star = {"✯", "✯"},
	Random = {"-","-"},
	[1] = "♛",
	[2] = "卐",
	[3] = "✯",
	[4] = "☭",
}


local namespam_btn = ui.new_button(PLACEMENT_TAB, PLACEMENT_SECTION, "Name Spam", function ()
	local oldName = cvar.name:get_string()

	local new_name = ui.get(namespam_textbox)
	if #new_name < 2 then return end
	local converted_name =   ""

	local wrapper = nickname_symbols_tbl[ui.get(name_symbol_comb)][1]
	
	local restore_name = ui.get(restore_name_chk)

	client.delay_call(0.1, function () 
		if ui.get(name_symbol_comb) == "Random" then
			wrapper = nickname_symbols_tbl[client.random_int(1, 4)]
		end
		converted_name = wrapper .. " " .. make_text_with_font(new_name) .. " " .. wrapper
		cvar.name:set_string(converted_name) 
	end)
	client.delay_call(0.25, function () 
		if ui.get(name_symbol_comb) == "Random" then
			wrapper = nickname_symbols_tbl[client.random_int(1, 4)]
		end
		converted_name = wrapper .. " " .. make_text_with_font(new_name) .. " " .. wrapper
		cvar.name:set_string(converted_name.." \x00") 
	end)
	client.delay_call(0.40, function () 
		if ui.get(name_symbol_comb) == "Random" then
			wrapper = nickname_symbols_tbl[client.random_int(1, 4)]
		end
		converted_name = wrapper .. " " .. make_text_with_font(new_name) .. " " .. wrapper
		cvar.name:set_string(converted_name) 
	end)
	client.delay_call(0.55, function () 
		if ui.get(name_symbol_comb) == "Random" then
			wrapper = nickname_symbols_tbl[client.random_int(1, 4)]
		end
		converted_name = wrapper .. " " .. make_text_with_font(new_name) .. " " .. wrapper
		cvar.name:set_string(converted_name.." \x00") 
	end)
	--client.delay_call(0.5, function () cvar.name:set_string("\n\xAD\xAD\xAD") end)
	if restore_name then
		client.delay_call(0.7, function () cvar.name:set_string(oldName) end)
	else
		client.delay_call(0.7, function () 
			if ui.get(name_symbol_comb) == "Random" then
				wrapper = nickname_symbols_tbl[client.random_int(1, 4)]
			end
			converted_name = wrapper .. " " .. make_text_with_font(new_name) .. " " .. wrapper
			cvar.name:set_string(converted_name) 
		end)
	end

	-- setName("\n\xAD\xAD\xAD")
end)
local bugged_name_is_on = false
local twin_towers_scene = 1
local twin_towers_anim = {
	utf8(0x2708) .. "  " .. utf8(0x258C) .. " " .. utf8(0x258C) ,
	" " .. utf8(0x2708) .. " " .. utf8(0x258C) .. " " .. utf8(0x258C),
	"  " .. utf8(0x2708) .. utf8(0x258C) .. " " .. utf8(0x258C),
	"   " .. utf8(0x2620) .. utf8(0x2708) .. utf8(0x258C),
	"   " .. utf8(0x2620) .. " " .. utf8(0x2620)
}

local prev_update_time = client.timestamp()
local anim_was_enabled = false
local last_stealed_name_indx = 0
local last_anim_name_len = 0

client.set_event_callback("net_update_end", function()
	local system_time, twin_towers, custom_symbol, name_symbol, slide_name, steal_from = ui.get(system_time_chk), ui.get(twin_towers_chk), ui.get(custom_symbol_chk), ui.get(name_symbol_comb), ui.get(slide_name_chk), ui.get(steal_from_type)
	if system_time or twin_towers or name_anim or steal_from ~= "Disabled" then

		-- speed control
		-- @todo: make configurable with slider
		if prev_update_time+450 < client.timestamp() then
			prev_update_time = client.timestamp()
		else
			return
		end

		if not bugged_name_is_on then 
			client.delay_call(0.2, function () if system_time or twin_towers or name_anim or steal_from ~= "Disabled"  then cvar.name:set_string("\n\xAD\xAD\xAD") end end)
			bugged_name_is_on = true
			return
		end

	else
		-- set original nickname if animation currently disabled
		if anim_was_enabled then
			anim_was_enabled = false
			client.delay_call(0.3, function () cvar.name:set_string(my_name_backup) end)
		end
	end
	
	local name_to_scroll = #ui.get(namespam_textbox) > 1 and ui.get(namespam_textbox) or my_name_backup
	if steal_from ~= "Disabled" then
		slide_name = false
		name_anim = false
		local players_steal_from = {}

		if steal_from == "Enemies" then
			for player=1, globals.maxplayers() do
				if entity.get_classname(player) == "CCSPlayer" and entity.is_enemy(player) then
					table.insert(players_steal_from, player)
				end
			end
		elseif steal_from == "Mates" then
			local local_player = entity.get_local_player()
			for player=1, globals.maxplayers() do
				if entity.get_classname(player) == "CCSPlayer" and not entity.is_enemy(player) and player ~= local_player then
					table.insert(players_steal_from, player)
				end
			end
		elseif steal_from == "All" then
			local local_player = entity.get_local_player()
			for player=1, globals.maxplayers() do
				if entity.get_classname(player) == "CCSPlayer" and player ~= local_player then
					table.insert(players_steal_from, player)
				end
			end
		end

		

		local current_index = last_stealed_name_indx + 1
		if current_index > #players_steal_from then
			current_index = 1
		end

		local prefix, sufix = "♛", "♛"
		if custom_symbol then
			if name_symbol == "Random" then
				local random_num = client.random_int(1, 4)
				prefix, sufix = nickname_symbols_tbl[random_num], nickname_symbols_tbl[random_num]
			else
				prefix, sufix = nickname_symbols_tbl[name_symbol][(current_index%2)+1], nickname_symbols_tbl[name_symbol][(current_index%2)+1]
			end
		end

		name_to_scroll = prefix .. " " .. entity.get_player_name(players_steal_from[current_index]) .. " " .. sufix 


		last_stealed_name_indx = current_index

	end
	if name_anim then

		if last_anim_name_len < 1 or last_anim_name_len > #name_to_scroll then
			last_anim_name_len = #name_to_scroll
		end

		local prefix, sufix = "♛", "♛"
		if custom_symbol then
			if name_symbol == "Random" then
				local random_num = client.random_int(1, 4)
				prefix, sufix = nickname_symbols_tbl[random_num], nickname_symbols_tbl[random_num]
			else
				prefix, sufix = nickname_symbols_tbl[name_symbol][(last_anim_name_len%2)+1], nickname_symbols_tbl[name_symbol][(last_anim_name_len%2)+1]
			end
		end
		if slide_name then
			name_to_scroll = prefix .. " " .. make_text_with_font(name_to_scroll:sub(1, last_anim_name_len )) .. " " .. sufix
		else
			name_to_scroll = prefix .. " " .. make_text_with_font(name_to_scroll) .. " " .. sufix
		end
		last_anim_name_len = last_anim_name_len - 1
	end

	if system_time then
		local hours, minutes, seconds, milliseconds = client.system_time()
		name_to_scroll = string.format("[%02d:%02d:%02d] ", hours, minutes, seconds) .. name_to_scroll
		-- client.delay_call(0.1, function () cvar.name:set_string( "[" ..hours..":"..minutes..":"..seconds .. "] " .. name_to_scroll) end)
	end
	if twin_towers then
		name_to_scroll =  name_to_scroll .. " " .. twin_towers_anim[twin_towers_scene]
		--client.delay_call(0.1, function () cvar.name:set_string( name_to_scroll .. " " .. twin_towers_anim[twin_towers_scene]) end)
		twin_towers_scene = twin_towers_scene == 5 and 1 or twin_towers_scene + 1
	end	


	if system_time or twin_towers or name_anim or steal_from ~= "Disabled" then 
		anim_was_enabled = true
		client.delay_call(0.1, function () cvar.name:set_string(name_to_scroll) end)
	end
end)

--
-- disable all active stuff when we connected to new server
--
client.set_event_callback("player_connect_full", function(e) 
	if client.userid_to_entindex(e.userid) == entity.get_local_player() and globals.mapname() ~= nil then
		cvar.name:set_string(my_name_backup)
		prev_update_time = client.timestamp()
		ui.set(steal_from_type, "Disabled")
		ui.set(system_time_chk, false)
		ui.set(twin_towers_chk, false)
		anim_was_enabled = false
		name_anim = false
		bugged_name_is_on = false
		
	end
end)


client.set_event_callback("shutdown", function()
	-- set original nickname when lua shutdown 
	cvar.name:set_string(my_name_backup)
end)


client.set_event_callback("paint_ui", function()
	ui.set_visible(system_time_chk, ui.get(namespam_type) == "Animations" or ui.get(namespam_type) == "Steal")
	ui.set_visible(twin_towers_chk, ui.get(namespam_type) == "Animations" or ui.get(namespam_type) == "Steal")

	ui.set_visible(name_symbol_comb, true)
	ui.set_visible(custom_symbol_chk, ui.get(namespam_type) == "Animations")
	ui.set_visible(slide_name_chk, ui.get(namespam_type) == "Animations")
	
	ui.set_visible(start_animate_btn, ui.get(namespam_type) == "Animations")
	ui.set_visible(hint_lbl, ui.get(namespam_type) == "Animations")
	ui.set_visible(stop_animate_btn, ui.get(namespam_type) == "Animations" and name_anim == true)
	ui.set_visible(start_animate_btn,ui.get(namespam_type) == "Animations" and name_anim == false)
	ui.set_visible(hidenname_btn, ui.get(namespam_type) == "Steal")
	ui.set_visible(steal_from_type, ui.get(namespam_type) == "Steal")
	ui.set_visible(use_custom_font_chk, ui.get(namespam_type) == "Pure spam in chat" or ui.get(namespam_type) == "Animations")
	ui.set_visible(namespam_textbox, ui.get(namespam_type) == "Pure spam in chat" or ui.get(namespam_type) == "Animations")
	ui.set_visible(namespam_btn, ui.get(namespam_type) == "Pure spam in chat")
	ui.set_visible(enter_name_lbl, ui.get(namespam_type) == "Pure spam in chat" or ui.get(namespam_type) == "Animations")
	ui.set_visible(warning_lbl, ui.get(namespam_type) == "Pure spam in chat")
	ui.set_visible(restore_name_chk, ui.get(namespam_type) == "Pure spam in chat")
	

end)
