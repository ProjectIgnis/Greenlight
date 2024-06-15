--ユニオン・パイロット
--Union Pilot
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Union Procedure
	aux.AddUnionProcedure(c)
	--Equip 1 appropriate Union monster that is banished and Special Summon this card from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():GetEquipTarget() end)
	e1:SetCost(s.eqcost)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
end
s.listed_card_types={TYPE_UNION}
function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHandAsCost() end
	Duel.SendtoHand(c,nil,REASON_COST)
	Duel.ShuffleHand(tp)
end
function s.eqpunionfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_UNION)
		and Duel.IsExistingMatchingCard(s.eqtargetfilter,tp,LOCATION_MZONE,0,1,nil,c)
end
function s.eqtargetfilter(c,ec)
	return ec:CheckUnionTarget(c) and aux.CheckUnionEquip(ec,c)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.eqpunionfilter,tp,LOCATION_REMOVED,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) --will pass if Masked Chameleon/Silent Angler-like effects are applying
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_EFFECT,2100,1000,5,RACE_MACHINE,ATTRIBUTE_LIGHT) --uncertain
		--and Duel.IsPlayerCanSpecialSummonMonster(tp,id,c:SetCode(),c:GetType(),c:GetTexAttack(),
		--c:GetTextDefense(),c:GetOriginalLevel(),c:GetOriginalRace(),c:GetOriginalAttribute())
	end
	c:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_REMOVED,0,1,1,nil,tp):GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local tc=Duel.SelectMatchingCard(tp,s.eqtargetfilter,tp,LOCATION_MZONE,0,1,1,nil,ec):GetFirst()
		if ec and tc and Duel.Equip(tp,ec,tc) then
			aux.SetUnionState(ec)
			if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0  and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
				Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
			end
		end
	end
	c:ReleaseEffectRelation(e)
end