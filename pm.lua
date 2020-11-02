local ev = require('lib.samp.events')
local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'


local version_scr = 2
local version_text = "2.00"
local update = false
local path_update = getWorkingDirectory() .. "/update.ini"
local url_update = "https://raw.githubusercontent.com/Pessera/vary_bad_scripts/main/update.ini"
local url_script = "https://raw.githubusercontent.com/Pessera/vary_bad_scripts/main/pm.lua"
local path = thisScript().path

function download_handler(id, status, p1, p2)
	if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			update_ini = inicfg.load(nil,path_update)
				if tonumber(update_ini.info.version) ~= version_scr then
					sampAddChatMessage('Найдено обновление! Текущая версия: '..version_text.. ' | Актуальная версия: '..update_ini.info.version_text, 0x57CC41)
					update = true
				end
				if tonumber(update_ini.info.version) == version_scr then
					sampAddChatMessage('Обновлений не найдено! Текущая версия: '..version_text, 0x57CC41)
				end
				os.remove(path_update)
			end
end

function download_lua(id, status)
	if status == dlstatus.STATUS_ENDDOWNLOADDATA then
		sampAddChatMessage('Обновление успешно завершено',0x57CC41)
		thisScript():reload()
	end
end

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(0) end
	sampRegisterChatCommand('test', function()
			sampAddChatMessage('Test',0x57CC41)
   	 end)
	downloadUrlToFile(url_update, path_update, download_handler)
		
		while true do
			wait(0)
			if update then
				downloadUrlToFile(url_script, path, download_lua)
				break
			end
		end
end
