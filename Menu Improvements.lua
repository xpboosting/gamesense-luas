local ui_new_button , ui_set_visible, ui_reference, ui_set, ui_new_label, unpack = ui.new_button, ui.set_visible, ui.reference, ui.set, ui.new_label




--Button without confirmation
local function recreate_button(tab, container, name, new_name,callback, callback_pre)
	local reference = ui_reference(tab, container, name)
	ui_set_visible(reference, false)
	local new_reference = ui_new_button(tab, container, new_name, function()
		if callback_pre ~= nil then
			callback_pre(reference)
		end
		ui_set(reference, true)
		if callback ~= nil then
			callback(reference)
		end
	end)
	return new_reference
end

--Button with confirmation
local function recreate_button_confirm(tab, container, name, new_name,callback, callback_pre)
	local reference = ui_reference(tab, container, name)
	ui_set_visible(reference, false)

    --disable all other buttons
    function disable_button(button, bool)
        local buttono = ui_reference("CONFIG", "Presets", button)
        ui_set_visible(buttono, bool)
    end
    function new_buttons(bool)
        disable_button("LOAD CFG", bool)
        disable_button("SAVE CFG", bool)
        disable_button("DELETE CFG", bool)
        disable_button("RESET CFG", bool)
        disable_button("Import CFG from clipboard", bool)
        disable_button("Export CFG to clipboard", bool)
    end
    --


	local pending_action, confirm_reference, cancel_reference, new_reference

    --LABEL
    local label = ui_new_label("CONFIG", "Presets", "--------------- ARE YOU SURE? ---------------")

	

	--CONFIRM
	confirm_reference = ui_new_button(tab, container, "YES, " .. name, function()
		ui_set_visible(confirm_reference, false)
		ui_set_visible(cancel_reference, false)
        ui_set_visible(label, false)
        new_buttons(true)
		ui_set_visible(new_reference, true)
		if callback_pre ~= nil then
			callback_pre(reference)
		end
		ui_set(reference, true)
		if callback ~= nil then
			callback(reference)
		end
	end)

    --CANCEL
	cancel_reference = ui_new_button(tab, container, "NO, CANCEL", function()
		ui_set_visible(confirm_reference, false)
		ui_set_visible(cancel_reference, false)
        ui_set_visible(label, false)
		ui_set_visible(new_reference, true)
        new_buttons(true)
	end)

	--The Button itself
	new_reference = ui_new_button(tab, container, new_name, function()
		ui_set_visible(new_reference, false)
		ui_set_visible(confirm_reference, true)
		ui_set_visible(cancel_reference, true)
        ui_set_visible(label, true)

        new_buttons(false)
	end)


	ui_set_visible(confirm_reference, false)
	ui_set_visible(cancel_reference, false)
    ui_set_visible(label, false)
end



recreate_button("CONFIG", "Presets", "LOAD", "LOAD CFG")
recreate_button_confirm("CONFIG", "Presets", "SAVE", "SAVE CFG")
recreate_button_confirm("CONFIG", "Presets", "DELETE", "DELETE CFG")
recreate_button("CONFIG", "Presets", "RESET", "RESET CFG")
recreate_button("CONFIG", "Presets", "Import from clipboard", "Import CFG from clipboard")
recreate_button("CONFIG", "Presets", "Export to clipboard", "Export CFG to clipboard")



