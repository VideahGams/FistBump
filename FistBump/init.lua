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
local http = require("socket.http")
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
	api-challenge-v4.1 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, RU, TR]
--]]---------------------------------------------------------

function riot:getIDList(beginDate, raw)

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v4.1/game/ids?beginDate=${beginDate}&${key}" % {beginDate = beginDate})

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
		end

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

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
		end

		return final, c, h
	else
		return nil, c, h
	end

end

function riot:getChampionByID(id, raw)

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v1.2/champion/${id}?${key}" % {id = id})

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
		end

		return final, c, h
	else
		return nil, c, h
	end

end

--[[---------------------------------------------------------
	current-game-v1.0 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, PBE, RU, TR]
--]]---------------------------------------------------------

function riot:gameInfoFromID(id, raw)

	local b, c, h = self:_request("${endpoint}/observer-mode/rest/consumer/getSpectatorGameInfo/${platform}/${id}?${key}" % {id = id})

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
		end

		return final, c, h
	else
		return nil, c, h
	end

end

--[[---------------------------------------------------------
	featured-games-v1.0 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, PBE, RU, TR]
--]]---------------------------------------------------------

function riot:getFeaturedGameList(raw)

	local b, c, h = self:_request("${endpoint}/observer-mode/rest/featured/?${key}")

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
		end

		return final, c, h
	else
		return nil, c, h
	end

end

--[[---------------------------------------------------------
	game-v1.3 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, RU, TR]
--]]---------------------------------------------------------

function riot:getRecentGames(id, raw)

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v1.3/game/by-summoner/${id}/recent?${key}" % {id = id})

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
		end

		return final, c, h
	else
		return nil, c, h
	end

end

--[[---------------------------------------------------------
	league-v2.5 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, RU, TR]
--]]---------------------------------------------------------

function riot:getLeagueBySummonerID(id, raw)

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v2.5/league/by-summoner/${id}?${key}" % {id = id})

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
			final = final[tostring(id)][1]
		end

		return final, c, h
	else
		return nil, c, h
	end

end

function riot:getLeagueEntriesBySummonerID(id, raw)

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v2.5/league/by-summoner/${id}/entry?${key}" % {id = id})

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
			final = final[tostring(id)][1]
		end

		return final, c, h
	else
		return nil, c, h
	end

end

function riot:getLeagueByTeamID(id, raw)

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v2.5/league/by-team/${id}?${key}" % {id = id})

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
			final = final[tostring(id)][1]
		end

		return final, c, h
	else
		return nil, c, h
	end

end

function riot:getLeagueEntriesByTeamID(id, raw)

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v2.5/league/by-team/${id}/entry?${key}" % {id = id})

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
			final = final[tostring(id)][1]
		end

		return final, c, h
	else
		return nil, c, h
	end

end

function riot:getChallengerLeague(queue, raw)

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v2.5/league/challenger/?type=${queue}&${key}" % {queue = queue})

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
		end

		return final, c, h
	else
		return nil, c, h
	end

end

--[[---------------------------------------------------------
	lol-static-data-v1.2 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, RU, TR] 
--]]---------------------------------------------------------

--TODO--

--[[---------------------------------------------------------
	lol-status-v1.0 [BR, EUNE, EUW, LAN, LAS, NA, OCE, PBE, RU, TR] 
--]]---------------------------------------------------------
function riot:getShardList(raw)

	local b, c, h = http.request("http://status.leagueoflegends.com/shards") -- HTTPS does not work.

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
		end

		return final, c, h
	else
		return nil, c, h
	end

end

function riot:getShardStatus(region, raw)

	local b, c, h = http.request("http://status.leagueoflegends.com/shards/${region}" % {region = region}) -- HTTPS does not work.

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
		end

		return final, c, h
	else
		return nil, c, h
	end

end

--[[---------------------------------------------------------
	match-v2.2 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, RU, TR] 
--]]---------------------------------------------------------

function riot:getMatchByID(id, includeTimeline, raw)

	includeTimeline = includeTimeline or false

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v2.2/match/${id}?includeTimeline=false&${key}" % {id = id, includeTimeline = includeTimeline})

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
		end

		return final, c, h
	else
		return nil, c, h
	end

end

--[[---------------------------------------------------------
	matchhistory-v2.2 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, RU, TR] 
--]]---------------------------------------------------------

function riot:matchHistoryByID(id, championIds, rankedQueues, beginIndex, endIndex, raw)

	championIds = championIds or ""
	rankedQueues = rankedQueues or ""
	beginIndex = beginIndex or ""
	endIndex = endIndex or ""

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v2.2/matchhistory/${id}?championIds=${championIds}&rankedQueues=${rankedQueues}&beginIndex=${beginIndex}&endIndex=${endIndex}&${key}" % {
		id = id,
		championIds = championIds,
		rankedQueues = rankedQueues,
		beginIndex = beginIndex,
		endIndex = endIndex})

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
			final = final['matches']
		end

		return final, c, h
	else
		return nil, c, h
	end

end

--[[---------------------------------------------------------
	stats-v1.3 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, RU, TR] 
--]]---------------------------------------------------------

function riot:getRankedStats(id, season, raw)

	season = season or ""

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v1.3/stats/by-summoner/${id}/ranked?season=${season}&${key}" % {id = id, season = season})

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
		end

		return final, c, h
	else
		return nil, c, h
	end

end

--[[---------------------------------------------------------
	summoner-v1.4 [BR, EUNE, EUW, KR, LAN, LAS, NA, OCE, RU, TR]
--]]---------------------------------------------------------

function riot:summonerInfoByName(summoner, raw)

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v1.4/summoner/by-name/${name}?${key}" % {name = summoner})

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
			final = final[string.lower(summoner)]
		end

		return final, c, h
	else
		return nil, c, h
	end

end

function riot:summonerInfoByID(id, raw)

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v1.4/summoner/${id}?${key}" % {id = id})

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
			final = final[tostring(id)]
		end

		return final, c, h
	else
		return nil, c, h
	end

end

function riot:summonerName(id, raw)

	local b, c, h = self:_request("${endpoint}/api/lol/${region}/v1.4/summoner/${id}/name?${key}" % {id = id})

	if handleCode(c) then

		local final = nil

		if raw then
			final = b
		else
			final = decode(b)
			final = final[tostring(id)]
		end

		return final, c, h
	else
		return nil, c, h
	end

end

return riot