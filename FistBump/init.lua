-- This code is licensed under the MIT Open Source License.
--
-- Copyright (c) 2015 Ruairidh Carmichael - ruairidhcarmichael@live.co.uk
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

local function interp(s, tab)
  return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end

getmetatable("").__mod = interp

local path = ... .. "."
local https = require(path .. "https")
local class = require(path .. "middleclass")
local json = require(path .. "json")

local riot = class("Riot")

local endpoints = {
	['br'] = "br.api.pvp.net",
	['eune'] = "eune.api.pvp.net",
	['euw'] = "euw.api.pvp.net",
	['kr'] = "kr.api.pvp.net",
	['lan'] = "lan.api.pvp.net",
	['las'] = "las.api.pvp.net",
	['na'] = "na.api.pvp.net",
	['oce'] = "oce.api.pvp.net",
	['tr'] = "tr.api.pvp.net",
	['ru'] = "ru.api.pvp.net",
	['pbe'] = "pbe.api.pvp.net",
	['global'] = "global.api.pvp.net"
}

local platformIDs = {
	['br'] = "BR1",
	['eune'] = "EUN1",
	['euw'] = "EUW1",
	['kr'] = "KR",
	['lan'] = "LA1",
	['las'] = "LA2",
	['na'] = "NA1",
	['oce'] = "OC1",
	['tr'] = "TR1",
	['ru'] = "RU",
	['pbe'] = "PBE1",
}

local function handleCode(c)

	c = tostring(c)

	if c == "400" then
		print("Error: 400 (Bad Request)")
	elseif c == "401" then
		print("Error: 401 (Unauthorized)")
	elseif c == "404" then
		print("Error: 404 (Not Found)")
	elseif c == "500" then
		print("Error: 500 (Internal Server Error)")
	elseif c == "503" then
		print("Error: 503 (Service Unavailable)")
	elseif c == "timeout" then
		print("Error: Could not connect (Timeout)")
	else
		return true
	end

end

function riot:_request(url)

	local final = "https://" .. url % {
	endpoint = endpoints[self.endpoint],
	region = self.region,
	key = "api_key=" .. self.key,
	platform = platformIDs[self.region]

	}

	print(final)

	local b, c, h = https.request(final)

	return b, c, h

end

local function decode(tbl)

	local jtbl = "[" .. tbl .. "]"

	local decoded = json.decode(jtbl)

	return decoded[1]

end

function riot:initialize(key, endpoint, region)

	self.key = key
	self.endpoint = endpoint
	self.region = region

	print("Loaded Riot API Watcher")

end

function riot:setEndpoint(endpoint)

	self.endpoint = endpoint

end

function riot:setRegion(region)

	self.region = region

end

function riot:setKey(key)

	self.key = key

end

--[[---------------------------------------------------------
	summoner-v1.4 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, RU, TR]
--]]---------------------------------------------------------

function riot:summonerInfoByName(summoner, raw)

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v1.4/summoner/by-name/${name}?${key}" % {name = summoner})

	local final = nil

	if raw then
		final = b
	else

		final = decode(b)
		final = final[string.lower(summoner)]

	end

	if handleCode(c) then
		return final, c, h
	else
		return nil, c, h
	end

end

function riot:summonerInfoByID(id, raw)

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v1.4/summoner/${id}?${key}" % {id = id})

	local final = nil

	if raw then
		final = b
	else

		final = decode(b)
		final = final[tostring(id)]

	end

	if handleCode(c) then
		return final, c, h
	else
		return nil, c, h
	end

end

function riot:summonerName(id, raw)

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v1.4/summoner/${id}/name?${key}" % {id = id})

	local final = nil

	if raw then
		final = b
	else

		final = decode(b)
		final = final[tostring(id)]

	end

	if handleCode(c) then
		return final, c, h
	else
		return nil, c, h
	end

end

--[[---------------------------------------------------------
	champion-v1.2 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, RU, TR]
--]]---------------------------------------------------------

function riot:getAllChampions(freeToPlay, raw)

	freeToPlay = freeToPlay or false

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v1.2/champion/?${freeToPlay}&${key}" % {freeToPlay = freeToPlay})

	local final = nil

	if raw then
		final = b
	else

		final = decode(b)

	end

	if handleCode(c) then
		return final, c, h
	else
		return nil, c, h
	end

end

function riot:getChampionByID(id, raw)

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v1.2/champion/${id}?${key}" % {id = id})

	local final = nil

	if raw then
		final = b
	else

		final = decode(b)

	end

	if handleCode(c) then
		return final, c, h
	else
		return nil, c, h
	end

end

--[[---------------------------------------------------------
	current-game-v1.0 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, PBE, RU, TR]
--]]---------------------------------------------------------

function riot:gameInfoFromID(id, raw)

	--local b, c, h = request(self.endpoint, self.region, "observer-mode/rest/consumer/getSpectatorGameInfo/" .. platformIDs[self.region] .. tostring(id) .. "?", self.key)

	local b, c, h = self:_request("${endpoint}/observer-mode/rest/consumer/getSpectatorGameInfo/${platform}/${id}?${key}" % {id = id})

	local final = nil

	if handleCode(c) then

		if raw then
			final = b
		else

			final = decode(b)

		end

		if tostring(c) == 404 then
			print("Error: Could not load game (No current game with this Summoner ID)")
			return
		end

		return final, c, h
	else
		return nil, c, h
	end

end

--[[---------------------------------------------------------
	api-challenge-v4.1 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, RU, TR]
--]]---------------------------------------------------------

function riot:getIDList(beginDate, raw)

	--local b, c, h = request(self.endpoint, self.region, "v4.1/game/ids" .. "?beginDate=" .. tostring(beginDate) .. "&", self.key)

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v4.1/game/ids?beginDate=${beginDate}&${key}" % {beginDate = beginDate})

	local final = nil

	if raw then
		final = b
	else

		final = decode(b)

	end

	if handleCode(c) then
		return final, c, h
	else
		return nil, c, h
	end

end

return riot