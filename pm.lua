local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'


local version_scr = 1
local version_text = "1.00"

local update = false
local path_update = getWorkingDirectory() .. "/update.ini"
local url_update = "https://raw.githubusercontent.com/Pessera/vary_bad_scripts/main/update.ini"
local url_script = "https://raw.githubusercontent.com/Pessera/vary_bad_scripts/main/pm.lua"
local path = thisScript().path

function download_handler(id, status, p1, p2)
	if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			update_ini = inicfg.load(nil,path_update)
				if tonumber(update_ini.info.version) ~= version_scr then
					sampAddChatMessage('Îáíàðóæåíî îáíîâëåíèå! Òåêóùàÿ âåðñèÿ: '..version_text.. ' | Íîâàÿ âåðñèÿ: '..update_ini.info.version_text,0x57CC41)
					update = true
				end
				if tonumber(update_ini.info.version) == version_scr then
					sampAddChatMessage('Îáíîâëåíèé íå îáíàðóæåíî! Àêòóàëüíàÿ âåðñèÿ: '..version_text,0x57CC41)
				end
				os.remove(path_update)
			end
end

function download_lua()
	if status == dlstatus.STATUS_ENDDOWNLOADDATA then
		sampAddChatMessage('Îáíîâëåíèå óñïåøíî çàâåðøåíî',0x57CC41)
		thisScript():reload()
	end
end

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(0) end
	
	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)

	downloadUrlToFile(url_update, path_update, download_handler)
		
		while true do
			wait(1)
			if update then
				downloadUrlToFile(url_script, path, download_lua)
				break
			end
		end
end
