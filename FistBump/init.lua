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

local function request(endpoint, region, url, key)

	local final = "https://" .. endpoints[endpoint] .. "/api/lol/" .. region .. "/" .. url .. "api_key=" .. key

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

	local b, c, h = request(self.endpoint, self.region, "v1.4/summoner/by-name/" .. summoner .. "?", self.key)

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

	local b, c, h = request(self.endpoint, self.region, "v1.4/summoner/" .. tostring(id) .. "?", self.key)

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

	local b, c, h = request(self.endpoint, self.region, "v1.4/summoner/" .. tostring(id) .. "/name" .. "?", self.key)

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
	api-challenge-v4.1 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, RU, TR]
--]]---------------------------------------------------------

function riot:getIDList(beginDate, raw)

	local b, c, h = request(self.endpoint, self.region, "v4.1/game/ids" .. "?beginDate=" .. tostring(beginDate) .. "&", self.key)

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