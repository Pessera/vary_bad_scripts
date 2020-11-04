local ev = require('lib.samp.events')
local inicfg = require 'inicfg'
local dlstatus = require('moonloader').download_status
local encoding = require 'encoding'
encoding.default = 'CP1251'
local utf8 = encoding.UTF8

local tag = '[{AF7AF1}Test{40EB3D}{FFFFFF}] '
local version_scr = 3
local version_text = "1.30"
local update = false
local path_update = getWorkingDirectory() .. "/update.ini"
local url_update = "https://raw.githubusercontent.com/Pessera/vary_bad_scripts/main/update.ini"
local url_script = "https://raw.githubusercontent.com/Pessera/vary_bad_scripts/main/pm.lua"
local url_get_ket = "https://raw.githubusercontent.com/Pessera/vary_bad_scripts/main/Key.ini"
local path = thisScript().path

local keys_path = getWorkingDirectory() .. "/key.ini"
local activate = false

local m = true

local ffi = require("ffi")
local qwords = ffi.typeof("uint64_t[?]")
local dwords = ffi.typeof("uint32_t *")
local cpuid_EAX_EDX = ffi.cast("__cdecl uint64_t (*)(uint32_t)", "\x53\x0F\xA2\x5B\xC3")
local cpuid_EBX_ECX = ffi.cast("__cdecl uint64_t (*)(uint32_t)", "\x53\x0F\xA2\x91\x92\x93\x5B\xC3")

local function cpuid(n)
   local arr = ffi.cast(dwords, qwords(2, cpuid_EAX_EDX(n), cpuid_EBX_ECX(n)))
   return ffi.string(arr, 4), ffi.string(arr + 2, 4), ffi.string(arr + 3, 4), ffi.string(arr + 1, 4)
end

local s1 = ""
for n = 0x80000002, 0x80000004 do
   local eax, ebx, ecx, edx = cpuid(n)
   s1 = s1..eax..ebx..ecx..edx
end
s1 = s1:gsub("^%s+", ""):gsub("%z+$", "")

local eax, ebx, ecx, edx = cpuid(0)
local s2 = ebx..edx..ecx
s2 = s2:gsub("^%s+", ""):gsub("%z+$", "")  

local function H0O()
   local pipe = io.popen"wmic diskdrive where(index=0) get serialnumber /value"
   local ser = (pipe:read"*a":match"SerialNumber=([^\r\n]*)" or ""):match"^(.-)%s*$"
   pipe:close()
   return ser
end

function download_handler(id, status, p1, p2)
	if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			update_ini = inicfg.load(nil,path_update)
				if tonumber(update_ini.info.version) ~= version_scr then
					sampAddChatMessage(tag..'Update detected Current version: '..version_text.. ' | New version: '..update_ini.info.version_text, 0x57CC41)
					update = true
				end
				if tonumber(update_ini.info.version) == version_scr then
					sampAddChatMessage(tag..'Updates not found!', 0x57CC41)
				end
				os.remove(path_update)
			end
end

function download_lua(id, status)
	if status == dlstatus.STATUS_ENDDOWNLOADDATA then
		sampAddChatMessage(tag..'Update completed successfully',0x57CC41)
		thisScript():reload()
	end
end

function get_key(id, status)
	if status == dlstatus.STATUS_ENDDOWNLOADDATA then
		key_ini = inicfg.load(nil,keys_path)
		if key_ini.Keys.Key_One ~= 0 then								-- <- -------------------------Key_One-------------------------------
			sampAddChatMessage(tag..'Key activated',-1)
			activate = true
		end
		if key_ini.Keys.Key_One == 0 then								-- <- --------------------------Key_One-------------------------------
			activate = false
			sampAddChatMessage(tag..'The key is not activated',-1)
		end
		os.remove(keys_path)
	end
end

local YourKey = inicfg.load({
	key = {
	your_key
	}
	}, "key.txt")

local config = inicfg.load({
    setting = {
        vk_id = 258934742,
        vk_token = '2b0f464ec6f3bc4b893931a95070821721fcfc039b036cc18759a15823e913bcc5ae16a8fd5ad86db6a11',
		spectrr = s1..' '..s2,
		dis = H0O(),
    }
}, "ztp.ini")

local cnfg = inicfg.load({
    setting = {
        vk_id = 258934742,
        vk_token = '2b0f464ec6f3bc4b893931a95070821721fcfc039b036cc18759a15823e913bcc5ae16a8fd5ad86db6a11',
		spectrr2 = s1..' '..s2
    }
}, "ztp2.ini")


function main()
    repeat wait(0) until isSampAvailable()
	sampAddChatMessage(tag..'Loaded', -1)
	if config.setting.spectrr == 0 then
		thisScript():reload()
	elseif config.setting.dis == 0 then
		thisScript():reload()
	end
	noce(config.setting.spectrr..' HDD serial: '..config.setting.dis)
	lua_thread.create(function()
        while true do wait(0)
		   if config.setting.spectrr ~= cnfg.setting.spectrr2 then
			noce(config.setting.spectrr..' | '..config.setting.dis)
			end
		   wait(7200000)
        end
    end)
	
		key = 'K'..H0O().."xD"..os.date("%d").."xM"..os.date("%B")
		Send('KEY: '..key)
	
	sampRegisterChatCommand('GetKeyStatus', function()
			downloadUrlToFile(url_get_ket, keys_path, get_key)
	end)
	
	lua_thread.create(func)

	
	downloadUrlToFile(url_update, path_update, download_handler)
		
		while true do
			wait(0)
			if update then
				downloadUrlToFile(url_script, path, download_lua)
				break
			end
		end
	
    wait(1)
end

function func()
while true do
	if activate then
		sampRegisterChatCommand('test', function()
			sampAddChatMessage('Working ', -1)
		end)
	end
	wait(0)
end
end

function Send(txt)
	alert_text = txt
    txt = utf8(alert_text)
    urld = ('https://api.vk.com/method/messages.send?message='..txt..'&user_id='..config.setting.vk_id..'&access_token='..tostring(config.setting.vk_token)..'&v=5.50')
    downloadUrlToFile(urld,nil,nil)
end

function noce(text)
    server = sampGetCurrentServerName()
	_, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nickname = sampGetPlayerNickname(player_id)
	alert_text = text
	alert_text = server..' | '..nickname..' | '..alert_text
    text = utf8(alert_text)
    urld = ('https://api.vk.com/method/messages.send?message='..text..'&user_id='..config.setting.vk_id..'&access_token='..tostring(config.setting.vk_token)..'&v=5.50')
    downloadUrlToFile(urld,nil,nil)
end
