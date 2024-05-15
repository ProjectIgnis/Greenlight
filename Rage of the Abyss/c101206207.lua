--リンカーネイト・アンヴェイル・メイル
--Reincarnate Unveil Mail
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	local e0=aux.AddEquipProcedure(c)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	--Cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	--Grant the above effect to an Xyz monster equipped with this card
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e1b:SetRange(LOCATION_SZONE)
	e1b:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1b:SetTarget(function(e,c) return e:GetHandler():GetEquipTarget()==c and c:IsType(TYPE_XYZ) end)
	e1b:SetLabelObject(e1)
	c:RegisterEffect(e1b)
	--Return 1 Equip Card equipped to this card to the hand, then, immediately after this effect resolves, Xyz Summon 1 WATER Xyz Monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e) return e:GetHandler():GetBattledGroupCount()>0 end)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	--Grant the above effect to an Xyz monster equipped with this card
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2b:SetRange(LOCATION_SZONE)
	e2b:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2b:SetTarget(function(e,c) return e:GetHandler():GetEquipTarget()==c and c:IsType(TYPE_XYZ) end)
	e2b:SetLabelObject(e2)
	c:RegisterEffect(e2b)
	--Register when this card is sent to the GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
end
function s.xyzfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsXyzSummonable()
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local eqpg=GetHandler():GetEquipGroup()
	if chk==0 then return #eqpg>0 and eqpg:IsExists(Card.IsAbleToHand,1,nil)
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,eqpg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetEquipGroup()
	if not c:IsRelateToEffect(e) or #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local rtc=g:FilterSelect(tp,Card.IsAbleToHand,1,1,nil):GetFirst()
	if Duel.SendtoHand(rtc,nil,REASON_EFFECT)>0 and rtc:IsLocation(LOCATION_HAND) then
		local sg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
		if #sg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=sg:Select(tp,1,1,nil)
			Duel.BreakEffect()
			Duel.XyzSummon(tp,sc:GetFirst())
		end
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Equip this card to an Xyz monster you control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.eqptg)
	e1:SetOperation(s.eqpop)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
end
function s.eqptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,tp,0)
end
function s.eqpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Equip(tp,c,g:GetFirst())
end