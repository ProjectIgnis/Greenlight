--japanese name
--Flame Swordsdance
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 monster from your Extra Deck and change the position of a monster on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetHintTiming(0,TIMING_BATTLE_PHASE+TIMING_END_PHASE)
	e1:SetCondition(s.spcond1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	--Special Summon 1 "Flame Swordsman" or 1 monster that mentions it from your Deck or Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_BATTLE_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(_,tp) return Duel.IsBattlePhase() and Duel.IsTurnPlayer(1-tp) end)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
s.listed_names={45231177} --Flame Swordsman
function s.spcond1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_SPECIAL)
end
function s.spfilter1(c,e,tp)
	return c:IsLevelBelow(7) and c:IsType(TYPE_FUSION) and (c:IsCode(45231177) or c:ListsCode(45231177))
		and Duel.GetLocationCountFromEx(tp,tp,nil,c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local pg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanTurnSet),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if #pg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
			local tc=pg:Select(tp,1,1,nil)
			Duel.HintSelection(tc,true)
			Duel.BreakEffect()
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
end
function s.costfilter(c,e,tp)
	return c:IsPosition(POS_FACEDOWN_DEFENSE)
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.spfilter2(c,e,tp,exc)
	if c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp,exc)<=0 then return false end
	if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,exc,c)<=0 then return false end
	return (c:IsCode(45231177) or c:ListsCode(45231177)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() and Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil,e,tp) end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	local g=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil,e,tp)
	Duel.Release(g,REASON_COST)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end