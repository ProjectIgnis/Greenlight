-- 七皇覚醒
-- Seventh Force
-- Scripted by Satella
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon 1 "Number C" monster from your Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil) and Duel.IsBattlePhase()
end
function s.targetfilter(c,e,tp)
	return c:IsSetCard(SET_NUMBER) and c:IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.spfilter(c,e,tp,xc)
	return c:IsSetCard(SET_NUMBER_C) and c:IsRace(xc:GetRace()) and c:IsRank(xc:GetRank()+1)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thfilter(c)
	return (c:IsSetCard({SET_BARIANS,SET_SEVENTH}) and c:IsSpellTrap() 
		or c:IsSetCard(SET_RANK_UP_MAGIC) and c:IsQuickPlaySpell()) and not c:IsCode(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.targetfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.targetfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.targetfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc):GetFirst()
		if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) then
			Duel.Overlay(sc,tc,true)
			local no=sc.xyz_number
			local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
			if no and no>=101 and no<=107 and sc:IsSetCard(SET_NUMBER_C) 
				and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local sg=g:Select(tp,1,1,nil)
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
end