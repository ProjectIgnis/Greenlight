--メタル化・強化反射装甲
--Enhanced Metalmorph
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 monster that cannot be Normal Summoned/Set and mentions "Enhanced Metalmorph" from your hand/Deck/GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_ENHANCED_METALMORPH}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.costfilter(c,e,tp)
	return c:IsFaceup() and Duel.GetMZoneCount(tp,c,tp)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,c)
end
function s.spfilter(c,e,tp,mc)
	return not c:IsSummonableCard() and c:ListsCode(CARD_ENHANCED_METALMORPH)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		and c.enhacement_metalmorph_filter
		and c.enhacement_metalmorph_filter(mc)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil,e,tp)
	end
	local rg=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil,e,tp)
	Duel.Release(rg,REASON_COST)
	e:SetLabelObject(rg:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local mc=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,mc):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)>0 and c:IsRelateToEffect(e)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		c:CancelToGrave(true)
		Duel.BreakEffect()
		s.equipop(tc,e,tp,c)
	end
end
function s.equipop(eqptarget,e,tp,eqpcard)
	if not eqptarget:EquipByEffectAndLimitRegister(e,tp,eqpcard,nil,true) then return end
	--Equip limit
	local e0=Effect.CreateEffect(eqpcard)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_EQUIP_LIMIT)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetValue(function(e,c) return c==eqptarget end)
	e0:SetReset(RESET_EVENT|RESETS_STANDARD)
	eqpcard:RegisterEffect(e0)
	--The equipped monster gains 400 ATK/DEF
	local e1=Effect.CreateEffect(eqpcard)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(400)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	eqpcard:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	eqpcard:RegisterEffect(e2)
	--The equipped monster cannot be destroyed by monster and Spell effects
	local e3=Effect.CreateEffect(eqpcard)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(function(e,re,rc,c) return re:IsMonsterEffect() or re:IsSpellEffect() end)
	e3:SetReset(RESET_EVENT|RESETS_STANDARD)
	eqpcard:RegisterEffect(e3)
	--Your opponent cannot target the monster with ith monster and Spell effects
	local e4=e3:Clone()
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	eqpcard:RegisterEffect(e4)
end