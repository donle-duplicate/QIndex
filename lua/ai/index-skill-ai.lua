--qiangzhiyongchang
sgs.ai_skill_invoke.qiangzhiyongchang = function(self, data)
	local players = self.room:getOtherPlayers(self.player)
	local leuges = {}
	for _, player in sgs.qlist(players) do	
		if player:getKingdom() == "qingjiao" then table.insert(leuges, player) end
	end
	
	local has_peach
	for _, card in sgs.qlist(self.player:getHandcards()) do
		if card:inherits("Peach") or card:inherits("Analeptic") then has_peach = true end
	end
	return #leuges ~= 0 and not has_peach
end

sgs.ai_skill_choice.qiangzhiyongchang = function(self, choices)
	local lord = self.room:getLord()
	if self:isFriend(lord) then return "yes" end
	
	return "no"
end

--wanquanjiyi
sgs.ai_skill_invoke.wanquanjiyi = true

sgs.ai_skill_playerchosen.wanquanjiyi = function(self, targets)
	for _, target in sgs.qlist(targets) do
		local skills = target:getVisibleSkillList()
		local final_target = true
		for _, skill in sgs.qlist(skills) do
			if self.player:hasSkill(skill:objectName()) then
				final_target = false
				break
			end
		end
		
		if final_target then return target end
	end
	
	return targets[1]
end
	
--huoyanmoshu
sgs.ai_skill_invoke.huoyanmoshu = function(self, data)
	local damage = data:toDamage()
	if damage.to:getArmor() and damage.to:getArmor():objectName() == "vine" and self.player:getHandcardNum() > 0 then return true 
	elseif self.player:getWeapon() and self.player:getWeapon():objectName() == "rune" then return true
	elseif self.player:getHp() >= 3 and self.player:getHandcardNum() > self.player:getHp() then return true
	end
	
	return false
end

sgs.ai_skill_discard.huoyanmoshu = function(self, discard_num, optional, include_equip)
	local flags = "h"
	if include_equip then flags = flags .. "e" end
	local cards = self.player:getCards(flags)
	if cards and cards:length() < discard_num then return {} end
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards, true)
	local discard = {cards[1]:getEffectiveId()}
	
	return discard
end

--linghunranshao
sgs.ai_skill_invoke.linghunranshao = function(self, data)
	local damage = data:toDamage()
	if damage.to:getArmor() and damage.to:getArmor():objectName() == "vine" and self.player:getHp() > 2 then return true
	elseif self.player:getWeapon() and self.player:getWeapon():objectName() == "rune" 
			and self.player:getHp() > 1 and self.player:inMyAttackRange(damage.to) then return true
	elseif damage.to:getHp() == 2 and self.player:getHp() > 1 then return true
	end
	
	return false
end


sgs.ai_skill_choice.chaonenglikaifa = function(self, choices)
	local n = math.random(1, 2)
	if self.player:getRole() == "renegade" then return "routizaisheng"
	else
		return choices:split("+")[n]
	end
end

--beici
local beici_skill={}
beici_skill.name="beicizhiren"
table.insert(sgs.ai_skills,beici_skill)
beici_skill.getTurnUseCard=function(self)
	if self.player:getHandcardNum() <= self.player:getHp() and not self.player:hasUsed("BeiciCard") then
		return sgs.Card_Parse("@BeiciCard=.")
	end
end

sgs.ai_skill_use_func["BeiciCard"]=function(card, use, self)
	local targets = self.room:getOtherPlayers(self.player)
	local target
	local target_num = 0
	for _, player in sgs.qlist(targets) do
		if self:isEnemy(player) then
			if player:getHandcardNum() > target_num then
				target = player
				target_num = player:getHandcardNum()
			end
		end
	end
	
	if target then 
		if use.to then
			use.to:append(target)
		end
		use.card = card
	end
end

sgs.ai_skill_ag.beicizhiren = function(self, card_ids, refusable)
	local cards = {}
	for _, card_id in ipairs(card_ids) do
		local card = sgs.Sanguosha:getCard(card_id)
		table.insert(cards, card)
	end
	
	self:sortByUseValue(cards, true)
	
	return cards[1]:getEffectiveId()
end

--lingnenglizhe
local shangtiao_ai = SmartAI:newSubclass("shangtiaodangma")

function shangtiao_ai:askForCard(pattern, prompt)
	local card = super.askForCard(self, pattern, prompt)
	if card then return card end
	if pattern == "slash" then
		local cards = self.player:getCards("h")
		cards=sgs.QList2Table(cards)
		self:fillSkillCards(cards)
		for _, card in ipairs(cards) do
			if card:inherits("Weapon") then
				local suit = card:getSuitString()
				local number = card:getNumberString()
				local card_id = card:getEffectiveId()
				return ("slash:lingnenglizhe[%s:%s]=%d"):format(suit, number, card_id)
			end
		end
	end
end

--huanxiangshashou
sgs.ai_skill_invoke.huanxiangshashou = function(self, data)
	return not self.player:isKongcheng()
end

sgs.ai_skill_discard.huanxiangshashou = function(self, discard_num, optional, include_equip)
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	local discard = {}
	table.insert(discard, cards[1]:getEffectiveId())
	return discard
end

--xixueshashou
sgs.ai_skill_invoke.xixueshashou = function(self, data)
	local recover = data:toRecover()
	if self:isEnemy(recover.who) and recover.who:getHp() <= 1 then return true end
	return false
end

sgs.ai_skill_discard.xixueshashou = function(self, discard_num, optional, include_equip)
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	local discard = {}
	table.insert(discard, cards[1]:getEffectiveId())
	return discard
end

--chaodiancipao
sgs.ai_skill_invoke.chaodiancipao = function(self, data)
	local players = self.room:getOtherPlayers(self.player)
	local targets = {}
	for _, player in sgs.qlist(players) do
		if self.player:distanceTo(player) <= 1 and self:isFriend(player) then table.insert(targets, player) end
	end
	
	return #targets ~= 0
end

sgs.ai_skill_playerchosen.chaodiancipao = function(self, targets)
	local target
	local target_num = 0
	for _, t in sgs.qlist(targets) do
		if self:isEnemy(t) and t:getHandcardNum() > target_num then
			target = t
			target_num = t:getHandcardNum()
		end
	end
	
	if target then
		return target
	else 
		return targets:at(0)
	end
end

--xinlingzhangwo
sgs.ai_skill_invoke.xinlingzhangwo = function(self, data)
	local targets = {}
	for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if self.player:distanceTo(player) <= 2 and self:isEnemy(player) then
			table.insert(targets, player)
		end
	end
	
	return #targets ~= 0
end

sgs.ai_skill_playerchosen.xinlingzhangwo = function(self, targets)
	for _, target in sgs.qlist(targets) do
		if self:isEnemy(target) then return target end
	end
	
	return targets:at(0)
end

--kongjianyidong
sgs.ai_skill_invoke.kongjianyidong = function(self, data)
	if self:isFriend(self.player:getNextAlive()) and self.player:getHp() > self.player:getNextAlive():getHp() then return false
	else return true
	end
end

--shiliangcaozong
sgs.ai_skill_invoke.shiliangcaozong = function(self, data)
	local damage = data:toDamage()
	if self:isFriend(damage.from) and damage.from:getHp() <= 2 and self.player:getHp() >= 2 then return false
	else return true end
end

sgs.ai_skill_discard.shiliangcaozong =  function(self, discard_num, optional, include_equip)
	local equips = self.player:getCards("e")
	local cards = self.player:getHandcards()
	local discard = {}
	if equips then table.insert(discard, equips:at(equips:length()-1):getEffectiveId())
	else
		cards = sgs.QList2Table(cards)
		self:sortByUseValue(cards, true)
		table.insert(discard, cards[1]:getEffectiveId())
	end
	return discard
end

sgs.ai_skill_playerchosen.shiliangcaozong = function(self, targets)
	targets = sgs.QList2Table(targets)
	self:sort(targets, "hp")
	for _, target in ipairs(targets) do
		if self:isEnemy(target) then return target end
	end

	return targets[1]
end

--yifangtongxing
sgs.ai_skill_invoke.yifangtongxing = true

sgs.ai_skill_choice.yifangtongxing = function(self, choices)
	local lord = self.room:getLord()
	if self:isFriend(lord) then
		if lord:getHp() == 2 and self.player:getHp() > 2 then return "yes"
		elseif lord:getHp() == 1 and not lord:getWeapon() then return "yes"
		end
	end
	return "no"
end

--dingwenbaocun
local baocun_skill={}
baocun_skill.name="dingwenbaocun"
table.insert(sgs.ai_skills,baocun_skill)
baocun_skill.getTurnUseCard=function(self)
	if self.dingwenbaocun_used then return end
	
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do	
		if not (card:inherits("Jink") or card:inherits("Nullification") or card:getTypeId() == sgs.Card_Equip or card:inherits("DelayedTrick")) then
			if not self.player:isWounded() and card:inherits("Peach") then local shit = nil
			else
				local suit = card:getSuit()
				local number = card:getNumber()
				local card_clone = sgs.Sanguosha:cloneCard(card:objectName(), suit, number)
				card_clone:setSkillName("dingwenbaocun")
				self.dingwenbaocun_used = true
				return card_clone
			end
		end
	end
end

--tianshiduoluo
sgs.ai_skill_discard.tianshiduoluo = function(self, discard_num, optional, include_equip)
	local discard = {}
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	local value = sgs.ai_use_value[cards[1]:className()] or 0
	if value <= 4.8 then
		table.insert(discard, cards[1]:getEffectiveId())
	end
	
	if #discard ~= 0 then return discard end
	
	if self.player:getOffensiveHorse() then 
		table.insert(discard, self.player:getOffensiveHorse():getEffectiveId())
	elseif self.player:getDefensiveHorse() then
		table.insert(discard, self.player:getDefensiveHorse():getEffectiveId())
	elseif self.player:getWeapon() then
		table.insert(discard, self.player:getWeapon():getEffectiveId())
	end
	
	if #discard ~= 0 then return discard end
end

--shouhuzhishen
sgs.ai_skill_invoke.shouhuzhishen = function(self, data)
	return #self.friends_noself ~= 0
end

sgs.ai_skill_playerchosen.shouhuzhishen = function(self, targets)
	self:sort(self.friends_noself, "defense")
	for _, friend in ipairs(self.friends_noself) do
		if friend ~= self.player then return friend end
	end
	
	return targets:at(0)
end

--huanxiangyushou
sgs.ai_skill_invoke.huanxiangyushou = function(self, data)
	return self.player:isWounded()
end

sgs.ai_skill_playerchosen.huanxiangyushou = function(self, targets)
	for _, target in sgs.qlist(targets) do
		if self:isEnemy(target) then return target end
	end
	
	return targets:at(0)
end

--dakonglishi
sgs.ai_skill_invoke.dakonglishi = function(self, data)
	local effect = data:toSlashEffect()
	if self:isFriend(effect.to) or effect.to:getHp() > 2 then return false
	else return true
	end
end

--nianlibaopo
sgs.ai_skill_invoke.nianlibaopo = function(self, data)
	local damage = data:toDamage()
	return self:isEnemy(damage.to:getNextAlive()) or damage.to:getNextAlive():getHp() > 2
end

--zuobiaoyidong
sgs.ai_skill_invoke.zuobiaoyidong = function(self, data)
	local effect = data:toCardEffect()
	return self:isEnemy(effect.from)
end

--renzaotianshi
sgs.ai_skill_playerchosen.renzaotianshi = function(self, targets)
	targets = sgs.QList2Table(targets)
	self:sort(targets, "defense")
	for _, target in ipairs(targets) do
		if self:isFriend(target) then return target end
	end
	
	return targets[1]
end

--zhengtibuming
sgs.ai_skill_invoke.zhengtibuming = true

sgs.ai_skill_choice.zhengtibuming = function(self, choices)
	local choice = choices:split("+")
	local n = math.random(1, #choice)
	return choice[n]
end

--cilixuji
sgs.ai_skill_invoke.cilixuji = function(self, data)
	local effect = data:toSlashEffect()
	return self:getJinkNumber(effect.to) == 0 
end

--jinxingguangxian
local jinxing_skill={}
jinxing_skill.name="jinxingguangxian"
table.insert(sgs.ai_skills, jinxing_skill)
jinxing_skill.getTurnUseCard=function(self)
	local has_weapon 
	local card_str
	if self.player:getWeapon() then has_weapon = true end
	local cards = self.player:getHandcards()
	for _, card in sgs.qlist(cards) do
		if card:inherits("Weapon") then
			card_str = "@JinxingCard=" .. card:getEffectiveId() 
			break
		end
	end
	if card_str then
		return sgs.Card_Parse(card_str)
	elseif has_weapon and self.player:getOffensiveHorse() then
		return sgs.Card_Parse("@JinxingCard=" .. self.player:getWeapon():getEffectiveId())
	end
end

sgs.ai_skill_use_func["JinxingCard"] = function(card, use, self)
	local target
	for _, enemy in ipairs(self.enemies) do	
		if not enemy:getCards("hej") then
			target = enemy
			break
		elseif enemy:getHp() >= enemy:getCards("hej"):length() then
			if not target then
				target = enemy
			else
				if target:getCards("hej"):length() > enemy:getCards("hej"):length() then
					target = enemy
				end
			end
		end
	end
	
	if not target then 
		for _, friend in ipairs(self.friends_noself) do
			if friend:getCards("j") then
				if not target then target = friend 
				else	
					if target:getCards("j") and target:getCards("j"):length() < friend:getCards("j"):length() then
						target = friend
					end
				end
			elseif not friend:getCards("e") then 
				if not friend then target = friend
				else
					if target:getHandcardNum() < friend:getHandcardNum() then
						target = friend
					end
				end
			end
		end
	end
	
	if target then
		if use.to then	
			use.to:append(target)
		end
		use.card = card
	end
end

--tuolizhiqiang
sgs.ai_skill_invoke.kewutuolizhiqiang = true

sgs.ai_skill_playerchosen.kewutuolizhiqiang = function(self, targets)
	local target
	local target_hp = 0
	for _, player in sgs.qlist(targets) do	
		if self:isEnemy(player) and player:getHp() > target_hp then
			target = player
			target_hp = player:getHp()
		end
	end
	return target
end

--diwuyuansu
sgs.ai_get_cardType=function(card)
	if card:inherits("Weapon") then return 1 end
	if card:inherits("Armor") then return 2 end 
	if card:inherits("OffensiveHorse")then return 3 end 
	if card:inherits("DefensiveHorse") then return 4 end 
end

local five_skill={}
five_skill.name="diwuyuansu"
table.insert(sgs.ai_skills, five_skill)
five_skill.getTurnUseCard=function(self)
	local equips = {}
	
	local eCard
	local hasCard={0, 0, 0, 0}
	for _, card in sgs.qlist(self.player:getCards("he")) do
		if card:inherits("EquipCard") then 
			hasCard[sgs.ai_get_cardType(card)] = hasCard[sgs.ai_get_cardType(card)]+1
			table.insert(equips, card)
		end		
	end
	
	for _, card in ipairs(equips) do
		if hasCard[sgs.ai_get_cardType(card)]>1 or sgs.ai_get_cardType(card)>3 then 
			eCard = card 
			break
		end
		if not eCard and not card:inherits("Armor") then eCard = card end
	end
	if not eCard then return end
	
	local suit = eCard:getSuitString()
	local number = eCard:getNumberString()
	local card_id = eCard:getEffectiveId()
	local card_str = ("duel:diwuyuansu[%s:%s]=%d"):format(suit, number, card_id)
	local skillcard = sgs.Card_Parse(card_str)
	
    assert(skillcard)
    return skillcard
end

--baiyi
local baiyi_skill={}
baiyi_skill.name="baiyi"
table.insert(sgs.ai_skills, baiyi_skill)
baiyi_skill.getTurnUseCard=function(self)
	if self.player:getMark("@wings") <= 0 or not self:slashIsAvailable() then return end
	
	local players = self.room:getOtherPlayers(self.player)
	local targets = {}
	for _, player in sgs.qlist(players) do
		if self:isEnemy(player) and not self.player:inMyAttackRange(player) and self:getJinkNumber(player) == 0 then
			table.insert(targets, player)
		end
	end
	if #targets == 0 or self:getSlashNumber(self.player) == 0 then return end
	return sgs.Card_Parse("@BaiyiCard=" .. self:getSlash():getEffectiveId())	
end

sgs.ai_skill_use_func["BaiyiCard"] = function(card, use, self)
	local players = self.room:getOtherPlayers(self.player)
	local targets = {}
	for _, player in sgs.qlist(players) do
		if self:isEnemy(player) and not self.player:inMyAttackRange(player) and self:getJinkNumber(player) == 0 then
			table.insert(targets, player)
		end
	end
	
	self:sort(targets, "hp")
	for _, target in ipairs(targets) do
		if self:getJinkNumber(target) == 0 and self:slashIsEffective(self:getSlash(), target) then
			if use.to then use.to:append(target) end
			use.card = card
			return
		end
	end
	
	if use.to then use.to:append(targets[1]) end
	use.card = card
end

--weiyuanwuzhi
sgs.ai_skill_choice.weiyuanwuzhi = function(self, choices)
	if self.player:getMark("@wings") <= 2 then return "getmark" end
	if self.player:getHp() >= self.player:getHandcardNum() then return "exnihilo" end
	
	return "getmark"
end	

--yuanzibenghuai
sgs.ai_skill_invoke.yuanzibenghuai = function(self, data)
	local effect = data:toCardEffect()
	return self:isEnemy(effect.from)
end

--lizishexian
sgs.ai_skill_invoke.liziboxinggaosupao = function(self, data)
	local damage = data:toDamage()
	return self:isEnemy(damage.to)
end

--danqizhuangjia
sgs.ai_skill_invoke.danqizhuangjia = function(self, data)
	local damage = data:toDamage()
	if damage.to == self.player then 
		if damage.damage == 1 and (self:getPeachNum() > 0 or self.player:getHp() > 2) then return false
		else
			return true
		end
	elseif damage.from == self.player then
		if self:isFriend(damage.to) then return false
		elseif (damage.card:inherits("FireAttack") or damage.card:inherits("FireSlash")) and damage.to:getArmor() and damage.to:getArmor():objectName() == "vine" then
			return true
		elseif damage.damage > 1 then return true
		elseif self.player:getPile("nitro") and self.player:getPile("nitro"):length() > 2 then return true
		else
			return false
		end
	end
	
	return true
end

--shenyin
local shenyin_skill={}
shenyin_skill.name="shenyin"
table.insert(sgs.ai_skills, shenyin_skill)
shenyin_skill.getTurnUseCard=function(self)
	if self.player:hasUsed("ShenyinCard") then return end
	
	self:forCard("shenyinshushi", "slash_id", -1)
	local cards = self.player:getHandcards()
	local slash = self:getSlash()
	if slash then 
		self:forCard("shenyinshushi", "slash_id", slash:getEffectiveId())
		return sgs.Card_Parse("@ShenyinCard=.") 
	end
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards, true)
	
	local class_name = cards[1]:className()
	local value = sgs.ai_keep_value[class_name] or 0
	if value <= 5.6 or cards[1]:inherits("Weapon") then 
		self:forCard("shenyinshushi", "slash_id", cards[1]:getEffectiveId())
		return sgs.Card_Parse("@ShenyinCard=.") 
	end
end

sgs.ai_skill_discard.shenyin = function(self, discard_num, optional, include_equip)
	if self:forCard("shenyinshushi", "slash_id") and self:forCard("shenyinshushi", "slash_id") ~= -1 then
		return {self:forCard("shenyinshushi", "slash_id")}
	end
end

sgs.ai_skill_use_func["ShenyinCard"] = function(card, use, self)
	use.card = card
end

--shushi
sgs.ai_skill_invoke.shushi = function(self, data)
	return self.player:getPile("guess")
end

sgs.ai_skill_ag.shushi = function(self, card_ids, refusable)
	self:forCard("shenyinshushi", "Slash", false)
	
	for _, card_id in ipairs(card_ids) do
		local card = sgs.Sanguosha:getCard(card_id)
		local value = sgs.ai_use_value[card:className()] or 0
		if card:inherits("Slash") or value <= 5.6 then
			self:forCard("shenyinshushi", "Slash", true)
			return card_id
		end
	end
	
	for _, card_id in ipairs(card_ids) do
		local card = sgs.Sanguosha:getCard(card_id)
		if not card:inherits("Slash") then
			self:forCard("shenyinshushi", "Slash", true)
			return card_id
		end
	end
end

sgs.ai_skill_playerchosen.shushi = function(self, targets)
	self:sort(self.enemies, "defense")
	self:sort(self.friends_noself, "hp")
	
	local to_slash = false
	if self.player:getPile("guess"):length() == 1 then
		local card_id = self.player:getPile("guess"):at(0)
		local card = sgs.Sanguosha:getCard(card_id)
		
		local value = sgs.ai_use_value[card:className()] or 0
		if card:inherits("Slash") or value <= 5.6 then
			to_slash = true
		end
	end
	
	if self:forCard("shenyinshushi", "Slash") or to_slash then
		return self.enemies[1]
	else
		return self.friends_noself[1]
	end
end

sgs.ai_skill_choice.shushi = function(self, choices)
	local player = self.room:getCurrent()
	if self:isFriend(player) then return "yes"
	else
		if self:getJinkNumber(self.player) > 0 then
			return "no"
		else
			local choice = choices:split("+")
			local n = math.random(1, 2)
			return choice[n]
		end
	end
end

--shendian
local shendian_skill={}
shendian_skill.name="shouhushendian"
table.insert(sgs.ai_skills, shendian_skill)
shendian_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("ShendianCard") then return end
	
	for _, friend in ipairs(self.friends) do	
		if friend:getMark("@temple") == 0 then 
			return sgs.Card_Parse("@ShendianCard=.")
		end
	end
end

sgs.ai_skill_use_func["ShendianCard"] = function(card, use, self)
	self:sort(self.friends, "hp")
	local target 
	for _, friend in ipairs(self.friends) do	
		if friend:containsTrick("indulgence") and friend:getMark("@temple") == 0 then 
			target = friend
			break
		end
	end
	
	if not target then target = self.friends[1] end
	if use.to then
		use.to:append(target)
	end
	use.card = card
end

--yizhi
sgs.ai_skill_invoke.jitiyizhi = function(self, data)
	local cards = self.player:getHandcards()
	for _, card in sgs.qlist(cards) do
		if card:inherits("Peach") or card:inherits("Analeptic") then return false end
	end
	
	return true
end

--lengdongshuimian
sgs.ai_skill_invoke.lengdongshuimian = function(self, data)
	local cards = self.player:getHandcards()
	for _, card in sgs.qlist(cards) do
		if self.player:getHp() > 1 then
			if card:inherits("Peach") then return true end
		else
			if card:inherits("Peach") or card:inherits("Analeptic") then return true end
		end
	end
	
	return self.player:getHp() > self.player:getHandcardNum() or self.player:getHp() > 2
end

--nenglitijiejin
sgs.ai_skill_invoke.nenglitijiejing = true

--nenglihunluan
local hunluan_skill={}
hunluan_skill.name="nenglihunluan"
table.insert(sgs.ai_skills, hunluan_skill)
hunluan_skill.getTurnUseCard = function(self)
	if not self.player:getWeapon() or self.player:hasUsed("HunluanCard")
		or not self:slashIsAvailable() or not self:getSlash() then return end
	local trigger 
	if self.player:getHandcardNum() > self.player:getHp() then trigger = true
	else
		for _, card in sgs.qlist(self.player:getHandcards()) do
			local v = sgs.ai_use_value[card:className()] or 0
			if v < 3.7 then trigger = true end
		end
	end
	
	if trigger then 
		local cards = self.player:getHandcards()
		cards = sgs.QList2Table(cards)
		self:sortByUseValue(cards)
		return sgs.Card_Parse("@HunluanCard=" .. cards[1]:getEffectiveId())
	end
end

sgs.ai_skill_use_func["HunluanCard"] = function(card, use, self)
	use.card = card
end

sgs.ai_skill_invoke.nenglihunluan = function(self, data)
	local effect = data:toSlashEffect()
	return self:isEnemy(effect.to)
end

--nenglibuming
sgs.ai_skill_discard.nenglibuming = function(self, discard_num, optional, include_equip)
	local cards = self.player:getHandcards()
	local discard = {}
	
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	for _, card in ipairs(cards) do	
		table.insert(discard, card:getEffectiveId())
		discard_num = discard_num - 1
		if discard_num == 0 then break end
	end
	
	return discard
end

--qianglitoushi
sgs.ai_skill_ag.qianglitoushi = function(self, card_ids, refusable)
	for _, card_id in ipairs(card_ids) do
		local card = sgs.Sanguosha:getCard(card_id)
		if not sgs.ai_use_value[card:className()] then return card_id end
		
		if sgs.ai_use_value[card:className()] >= 3.7 then
			if card:inherits("Jink") then
				if self:getJinkNumber(self.player) == 0 then return card_id
				else
					return -1
				end
			elseif card:inherits("Slash") then
				if not self:getSlash() then return card_id
				else
					return -1
				end
			else
				return card_id
			end
		end
	end
	
	return -1
end

sgs.ai_skill_playerchosen.qianglitoushi = function(self, targets)
	local enemies = {}
	for _, target in sgs.qlist(targets) do
		if self:isEnemy(target) then
			table.insert(enemies, target)
		end
	end
	
	if #enemies == 0 then return targets[1] end
	
	self:sort(enemies, "handcard")
	return enemies[#enemies]
end

--danqibaoqiang
sgs.ai_skill_invoke.danqibaoqiang = function(self, data)
	local effect = data:toSlashEffect()
	return self:getJinkNumber(effect.to) == 0 and self:isEnemy(effect.to)
end

--nenglizhuiji
local zhuiji_skill={}
zhuiji_skill.name="nenglizhuiji"
table.insert(sgs.ai_skills, zhuiji_skill)
zhuiji_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("ZhuijiCard") or (self.player:isWounded() and self.player:getMark("control_follow") >= 2) then return end
	return sgs.Card_Parse("@ZhuijiCard=.")
end

sgs.ai_skill_use_func["ZhuijiCard"] = function(card, use, self)
	self:sort(self.enemies, "expect")
	if use.to then
		use.to:append(self.enemies[1])
	end
	use.card = card
end

--xinlidinggui
local dinggui_skill={}
dinggui_skill.name="xinlidinggui"
table.insert(sgs.ai_skills, dinggui_skill)
dinggui_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("DingguiCard") then return end
	if self.player:getHp() > 2 then 
		if #self.friends < #self.enemies then return end
	end
	return sgs.Card_Parse("@DingguiCard=.")
end

sgs.ai_skill_use_func["DingguiCard"] = function(card, use, self)
	if self.player:getHp() > 2 then
		self:sort(self.friends, "defense")
		self:sort(self.enemies, "handcard")
		if use.to then
			use.to:append(self.friends[#self.friends])
			use.to:append(self.enemies[1])
		end
	else
		self:sort(self.friends, "defense")
		self:sort(self.enemies, "expect")
		if use.to then
			use.to:append(self.friends[1])
			use.to:append(self.enemies[#self.enemies])
		end
	end
	use.card = card
end

--mofashufu
local shufu_skill={}
shufu_skill.name="mofashufu"
table.insert(sgs.ai_skills, shufu_skill)
shufu_skill.getTurnUseCard = function(self)
	local cards = self.player:getHandcards()
	local tricks = {}
	for _, card in sgs.qlist(cards) do	
		if card:getTypeId() == sgs.Card_Trick then
			table.insert(tricks, card)
		end
	end
	
	if #tricks == 0 or self.player:hasUsed("ShufuCard") then return end
	self:sortByUseValue(tricks, true)
	
	local card_str = "@ShufuCard="
	for _, friend in pairs(self.friends_noself) do
		if friend:getCards("j") then
			card_str = card_str .. tricks[1]:getEffectiveId()
			return sgs.Card_Parse(card_str)
		end
	end
	
	local v = sgs.ai_use_value[tricks[1]:className()] or 0
	if v > 3.6 then return end
	card_str = card_str .. tricks[1]:getEffectiveId()
	return sgs.Card_Parse(card_str)
end

sgs.ai_skill_use_func["ShufuCard"] = function(card, use, self)
	for _, friend in pairs(self.friends_noself) do
		if friend:getCards("j") then
			if use.to then
				use.to:append(friend)
			end
			use.card = card
			return
		end
	end
	
	self:sort(self.enemies)
	if use.to then use.to:append(self.enemies[#self.enemies]) end
	use.card = card
end

sgs.ai_skill_invoke.mofajiejin = function(self, data)
	for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if player:getKingdom() == "qingjiao" and self:isFriend(player) then
			return true
		end
	end
	
	return false
end

sgs.ai_skill_choice.mofajiejin = function(self, choices)
	local lord = self.room:getLord()
	if lord:getHandcardNum() >= lord:getHp() then return "no"
	elseif self.player:isKongcheng() then return "no"
	elseif self:isEnemy(lord) then return "no"
	end
	
	return "yes"
end

--liangzijiuchan
sgs.ai_skill_invoke.liangzijiuchan = function(self, data)
	local damage = data:toDamage()
	return self:isEnemy(damage.to) and self:getSlash()
end

--xushuxingshi
sgs.ai_skill_invoke.xushuxingshi = true

sgs.ai_skill_playerchosen.xushuxingshi = function(self, targets)
	if self.room:getCurrent() ~= self.player then
		return self.room:getCurrent():getNextAlive()
	else
		for _, player in sgs.qlist(targets) do
			if self:isEnemy(player) then return player end
		end
	end
	
	return targets:at(0)
end

--wuzhengshijie
local wuzheng_skill={}
wuzheng_skill.name="wuzhengshijie"
table.insert(sgs.ai_skills, wuzheng_skill)
wuzheng_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("WuzhengCard") then return end
	
	self:forCard("wuzhengshijie", "given", -1)
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	for _, card in ipairs(cards) do
		if not card:inherits("Slash") then
			self:forCard("wuzhengshijie", "given", card:getEffectiveId())
			return sgs.Card_Parse("@WuzhengCard=.")
		end
	end
end

sgs.ai_skill_use_func["WuzhengCard"] = function(card, use, self)
	self:sort(self.enemies, "expect")
	if use.to then use.to:append(self.enemies[1]) end
	use.card = card
end

--shitujushu
sgs.ai_skill_invoke.shiershitujushushi = function(self, data)
	local damage = data:toDamage()
	if self:isFriend(damage.from) then return false end
	
	return true
end

sgs.ai_skill_choice.shiershitujushushi = function(self, choices)
	local player = self.room:getCurrent()
	if player:getHandcardNum() > player:getHp() then return "phasechange"
	elseif player:getCards("e") and player:getCards("e"):length() >= 2 then return "discard"
	end
	
	return "phasechange"
end

--tianfashushi
sgs.ai_skill_discard.tianfashushi = function(self, discard_num, optional, include_equip)
	local cards = self.player:getCards("he")
	if not cards or self.player:getHp() > 3 or cards:length() < 2 then return {} end
	
	local discard = {}
	for _, card in sgs.qlist(cards) do
		if card:getTypeId() == sgs.Card_Equip then
			if self:hasSameEquip(card) and self.room:getCardPlace(card:getEffectiveId()) ~= sgs.Player_Equip then
				table.insert(discard, card:getEffectiveId())
			end
		elseif not sgs.ai_keep_value[card:className()] or sgs.ai_keep_value[card:className()] <= 5 then
			table.insert(discard, card:getEffectiveId())
		end
		
		if #discard > 1 then break end
	end
	
	local index = 1
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	while #discard < 2 do
		if self:getPeachNum() > 0 then return {} end
		table.insert(discard, cards[index])
		index = index + 1
	end
	
	return discard
end

--yuanzuizhiyuan
local jiushu_skill={}
jiushu_skill.name="cibeidejiushu"
table.insert(sgs.ai_skills, jiushu_skill)
jiushu_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("JiushuCard") then return end
	
	self:sort(self.friends, "hp")
	if self.player:getHp() <= 2 or not self.friends[1]:isWounded() then return end
	
	local slash = {}
	local duel
	local cards = self.player:getHandcards()
	for _, card in sgs.qlist(cards) do
		if card:inherits("Slash") then
			table.insert(slash, card)
		elseif card:inherits("Duel") then
			duel = card
		end
	end
	
	if #slash > 0 then
		self:sort(self.enemies, "handcard")
		for _, enemy in ipairs(self.enemies) do
			if self:getJinkNumber(enemy) == 0 then
				for _, hit in ipairs(slash) do
					if self:slashIsEffective(hit, enemy) then
						return "@JiushuCard=."
					end
				end
			end
		end
	end
	
	if duel then
		for _, enemy in ipairs(self.enemies) do
			if self:getSlashNumber(self.player) > self:getSlashNumber(enemy) then
				return "@JiushuCard=."
			end
		end
	end
end

sgs.ai_skill_use_func["JiushuCard"] = function(card, use, self)
	self:sort(self.friends, "hp")
	for _, friend in ipairs(self.friends) do
		if self.player:getHp() + self:getPeachNum() > friend:getHp() then
			if use.to then
				use.to:append(friend)
			end
			use.card = card
			return
		end
	end
	
	if use.to then use.to:append(self.friends_noself[1])
	use.card = card
end

--shenshengzhiyou
sgs.ai_skill_playerchosen(self, targets)
	for _, target in sgs.qlist(targets) do
		if self:isEnemy(target) then return target end
	end
	
	for _, target in sgs.qlist(targets) do
		if self:getJinkNumber(target) > 0 then return target end
	end
	
	return targets:at(0)
end

--guangzhichuxing
sgs.ai_skill_invoke.guangzhichuxing = true

sgs.ai_skill_choice.guangzhichuxing = sgs.ai_skill_choice.zhengtibuming

--jinseyanshu
--waiting 4 change skill

--anyujiedu
sgs.ai_skill_choice.fazhishuanyu = sgs.ai_skill_choice.zhengtibuming

--shenzhisuqing
local suqing_skill={}
suqing_skill.name="shenzhisuqing"
table.insert(sgs.ai_skills, suqing_skill)
suqing_skill.getTurnUseCard = function(self)
	if self.player:getMark("@annihilate") == 0 or self.player:getHandcardNum() ~= 1 then return end
	for _, friend in ipairs(self.friends_noself) do
		if friend:getHp() == 1 then return end
	end
	
	local card = self.player:getHandcards()
	local number = card:at(0):getNumber()
	if number >= 8 and self:isFriend(self.player:getNextAlive()) then 
		return sgs.Card_Parse("@SuqingCard=.")
	end
end

sgs.ai_skill_use_func["SuqingCard"] = function(card, use, self)
	use.card = card
end

--yubanwangluo
local wangluo_skill={}
wangluo_skill.name="yubanwangluo"
table.insert(sgs.ai_skills, wangluo_skill)
wangluo_skill.getTurnUseCard = function(self)
	if self.player:usedTimes("WangluoCard") > 1 then return end
	
	local cards = self.player:getHandcards()
	for _, card in sgs.qlist(cards) do
		if card:getTypeId() == sgs.Card_Equip and self:hasSameEquip(card) then
			return sgs.Card_Parse("@WangluoCard=.")
		end
	end
	
	if self.player:getHp() < self.player:getMark("net_hp") then 
		return sgs.Card_Parse("@WangluoCard=.")
	end
end

sgs.ai_skill_use_func["WangluoCard"] = function(card, use, self)
	use.card = card
end

--chaonaoli
sgs.ai_skill_invoke.chaonaoli = function(self, data)
	return self.player:getHandcardNum() > self.player:getHp()
end

sgs.ai_skill_ag.chaonaoli = function(self, card_ids, refusable)
	local cards = {}
	for _, card_id in ipairs(card_ids) do
		local card = sgs.Sanguosha:getCard(card_id)
		table.insert(cards, card)
	end
	
	self:sortByUseValue(cards, true)
	return cards[1]:getEffectiveId()
end

sgs.ai_skill_playerchosen.chaonaoli = function(self, targets)
	targets = sgs.QList2Table(targets)
	self:sort(targets, "hp")
	for _, target in ipairs(targets) do
		if self:isEnemy(target) then return target end
	end
	
	for _, target in ipairs(targets) do
		if self:isFriend(target) then return target end
	end
end

sgs.ai_skill_choice.chaonaoli = function(self, choices)
	local target
	for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if p:getMark("@brain") > 0 then target = p end
	end
	
	if self:isEnemy(target) then
		if target:getHandcardNum() > target:getHp() then return "play"
		else return "draw"
		end
	else
		if target:getCards("j") then return "judge"
		else return "discard"
		end
	end
	
	return "draw"
end

--muyuanshenquan
sgs.ai_skill_invoke.muyuanshenquan = true

sgs.ai_skill_choice.muyuanshenquan = function(self, choices)
	self:sort(self.enemies)
	if self.player:getHandcardNum() < self.player:getHp() then return "drawone" end
	for _, enemy in ipairs(self.enemies) do
		if enemy:getWeapon() then return "weapon" end
	end
	
	return "drawone"
end

sgs.ai_skill_playerchosen.muyuanshenquan = function(self, targets)
	target = sgs.QList2Table(targets)
	self:sort(targets, "expect")
	for _, target in ipairs(targets) do
		if self:isEnemy(target) then return target end
	end
	return targets[1]
end

--shangweigeti
local geti_skill={}
geti_skill.name="shangweigeti"
table.insert(sgs.ai_skills, geti_skill)
geti_skill.getTurnUseCard = function(self)
	self:sort(self.friends_noself, "hp")
	if self.player:hasUsed("GetiCard") 
		or self.player:getHandcardNum() <= self.player:getHp()
		or not self.friends[1]:isWounded() then
		return 
	end
	
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards, true)
	return sgs.Card_Parse("@GetiCard=" .. cards[1]:getId() .."+".. cards[2]:getId())
end

sgs.ai_skill_use_func["GetiCard"] = function(card, use, self)
	self:sort(self.friends, "hp")
	if use.to then use.to:append(self.friends[1]) end
	use.card = card
end

--shengrenbenghuai
local benghuai_skill={}
benghuai_skill.name="shengrenbenghuai"
table.insert(sgs.ai_skills, benghuai_skill)
benghuai_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("BenghuaiCard") then return end
	
	if self.player:getMark("@gun") > 0 then
		return sgs.Card_Parse("@BenghuaiCard=.")
	else
		if self.player:getHandcardNum() < self.player:getHp() then return 
		elseif self.player:getHandcardNum() <= 2 then return 
		else
			local cards = self.player:getHandcards()
			cards = sgs.QList2Table(cards)
			self:sortByKeepValue(cards, true)
			return sgs.Card_Parse("@BenghuaiCard=" .. cards[1]:getId() .."+".. cards[2]:getId())
		end
	end
end

sgs.ai_skill_use_func["BenghuaiCard"] = function(card, use, self)
	if self.player:getMark("@gun") == 0 then
		if use.to then use.to:append(self.player) end
	else
		self:sort(self.friends, "handcard")
		if use.to then use.to:append(self.friends[1]) end
	end
	
	use.card = card
end

--qijiaoqizui
local qizui_skill={}
qizui_skill.name="qijiaoqizui"
table.insert(sgs.ai_skills, qizui_skill)
qizui_skill.getTurnUseCard = function(self)
	if not self.player:isWounded() or self.player:hasUsed("QizuiCard") then return end
	for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if self.player:inMyAttackRange(player) and self:isEnemy(player) then 
			return sgs.Card_Parse("@QizuiCard=.")
		end
	end
end

sgs.ai_skill_use_func["QizuiCard"] = function(card, use, self)
	local targets = {}
	local enemies = self.enemies
	for _, enemy in ipairs(enemies) do
		if self.player:inMyAttackRange(enemy) then 
			table.insert(targets, enemy)
			table.remove(enemies, enemy)
			break
		end
	end
	
	self:sort(enemies, "hp")
	local n = 1
	for _, enemy in ipairs(enemies) do
		table.insert(targets, enemy)
		n = n + 1
		if n > self.player:getLostHp() then break end
	end
	
	for _, target in ipairs(targets) do
		if use.to then use.to:append(target) end
	end
	
	if #targets == 1 then
		for _, friend in ipairs(self.friends_noself) do
			if self:getSlashNumber(friend) >= self:getSlashNumber(targets[1]) then
				if use.to then use.to:append(friend) break end
			end
		end
	end
	
	use.card = card
end

--nixishouhu
sgs.ai_skill_invoke.nixishouhu = function(self ,data)
	if not self.player:hasFlag("nixi_start") then return true 
	elseif self.room:getTag("nixi_suit"):toString() then
		local suit = self.room:getTag("nixi_suit"):toString()
		local card_ids = self.player:getPile("nixi")
		local length = card_ids:length()
		local n = 0
		for _, card_id in sgs.qlist(card_ids) do
			local card = sgs.Sanguosha:getCard(card_id)
			if card:getSuitString() ~= suit then n = n + 1 end
		end
		if n <= length/3 then return true end
	elseif self.room:getTag("nixi_number"):toInt() ~= 0 then
		return true
	end
	
	return false
end