--ЯＲＵＭ－レイド・ラプターズ・フォース
--Rise-Rank-Up-Magic Raidraptor’s Force
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)	
end
s.listed_series={SET_RAIDRAPTOR }
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() or (Duel.IsTurnPlayer(1-tp) and Duel.IsBattlePhase())
end
function s.filter(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(SET_RAIDRAPTOR) and (c:IsFaceup() or not c:IsOnField())
end
function s.check(sg,e,tp,mg)
	if not sg:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) then return false end
	local rk=sg:GetSum(Card.GetRank)
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg)
end
function s.spfilter(c,e,tp,g,rk)
	if not (c:IsType(TYPE_XYZ) and c:IsSetCard(SET_RAIDRAPTOR) and c:IsRank(rk) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)) then return false end
	return not c.rum_limit or g:IsExists(function(mc) return c.rum_limit(mc,e) end,1,nil) and Duel.GetLocationCountFromEx(tp,tp,g,c)>0	
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,99,s.check,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,99,s.check,1,tp,HINTMSG_XMATERIAL)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local rk=tg:GetSum(Card.GetRank)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tg,rk):GetFirst()
	if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
		local mg=Group.CreateGroup()
		tg:ForEach( function(tc)
						mg=mg+tc:GetOverlayCount()
					end)
		mg=mg+tg
		Duel.Overlay(sc,tg)
	end
end
