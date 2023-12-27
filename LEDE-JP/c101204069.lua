--共界神淵体
--Metaltronios
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 monster with 2+ properties equal to the target
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,e,tp)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp,c:GetRace(),c:GetAttribute(),c:GetAttack())
end
function s.spfilter(c,e,tp,rac,att,atk)
	local ct=0
	if c:IsRace(rac) then ct=ct+1 end
	if c:IsAttribute(att) then ct=ct+1 end
	if c:IsAttack(atk) then ct=ct+1 end
	return ct>=2 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and ((c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0) 
			or (not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.cfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.cfilter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g:GetFirst(),1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,g,2,tp,0)
	--Your opponent cannot activate the targeted monster's effects in response to this card's activation
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(function(e,tp,p) return e:GetHandler()~=g:GetFirst() end)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetRace(),tc:GetAttribute(),tc:GetAttack()):GetFirst()
		if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			--Its effects are negated
			sc:NegateEffects(c)
			Duel.SpecialSummonComplete()
			--Negate the effects of the target
			tc:NegateEffects(c)
			--If they have the same name, you can banish them
			if sc:IsCode(tc:GetCode()) and sc:IsAbleToRemove(tp,POS_FACEDOWN,REASON_EFFECT)
				and tc:IsAbleToRemove(tp,POS_FACEDOWN,REASON_EFFECT)
				and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
					Duel.BreakEffect()
					Duel.Remove(Group.FromCards(tc,sc),POS_FACEDOWN,REASON_EFFECT)
				end
		end
	end
end
