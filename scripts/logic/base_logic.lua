-- this is the file to put all your custom logic functions into.
-- if you dont want to use the json based logic you can switch to a graph-based logic method.
-- the needed functions for that are in `/scripts/logic/graph_logic/logic_main.lua`.



-- function <name> (<parameters if needed>)
--     <actual code>
--     <indentations are just for readability>
-- end
--

local SECTION_CODE_LOOKUP = nil

local function trim(s)
	if not s then
		return ""
	end
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function normalize_ref(ref)
	ref = trim(ref)
	if ref:sub(1, 1) == "@" then
		ref = trim(ref:sub(2))
	end
	return ref
end

local function build_section_lookup()
	if SECTION_CODE_LOOKUP then
		return
	end

	SECTION_CODE_LOOKUP = {}
	pcall(function()
		require("scripts.autotracking.location_mapping")
	end)

	if not LOCATION_MAPPING then
		return
	end

	for _, codes in pairs(LOCATION_MAPPING) do
		for _, code in ipairs(codes) do
			local nested = code:match("/([^/]+)/$")
			if nested then
				SECTION_CODE_LOOKUP[nested:lower()] = code
			end

			local top_level = code:match("^@([^/]+)/$")
			if top_level then
				SECTION_CODE_LOOKUP[top_level:lower()] = code
			end
		end
	end
end

local function find_section(ref)
	build_section_lookup()

	ref = normalize_ref(ref)
	if ref == "" then
		return nil
	end

	local candidates = {}

	if ref:find("/") then
		table.insert(candidates, "@" .. ref .. "/")
		table.insert(candidates, "@" .. ref)
	else
		local mapped = SECTION_CODE_LOOKUP[ref:lower()]
		if mapped then
			table.insert(candidates, mapped)
		end
		table.insert(candidates, "@" .. ref .. "/")
		table.insert(candidates, "@" .. ref)
	end

	for _, code in ipairs(candidates) do
		local section = Tracker:FindObjectForCode(code)
		if section and section.AvailableChestCount ~= nil then
			return section
		end
	end

	return nil
end

--- Returns true when every chest in the referenced location section has been checked off.
---@param ref string location name or @location path from access rules
---@return boolean
function location_cleared(ref)
	local section = find_section(ref)
	if not section then
		return false
	end

	return section.AvailableChestCount == 0
end

--- Access rule helper used as `$locationcheck|@Some Location`.
--- Checks whether another map location has been cleared (checked off).
---@param location_name string
---@param section_name? string
---@return boolean
function locationcheck(location_name, section_name)
	if not location_name then
		return false
	end

	if section_name and trim(section_name) ~= "" then
		local loc = normalize_ref(location_name)
		local sec = normalize_ref(section_name)

		local combined = "@" .. loc .. "/" .. sec
		local section = Tracker:FindObjectForCode(combined)
		if section and section.AvailableChestCount ~= nil then
			return section.AvailableChestCount == 0
		end

		return location_cleared(sec)
	end

	return location_cleared(location_name)
end
