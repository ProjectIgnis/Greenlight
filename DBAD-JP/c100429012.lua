--Scripted by IanxWaifu
--EXTINGUISH!
local s,id=GetID()
function s.initial_effect(c)
	--Target Effect Monster
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x287}

--Control a "Rescue-ACE" Monster
function s.cfilter(c,rit)
	return c:IsFaceup() and c:IsSetCard(0x287)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

--Target Monster
function s.disfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsDisabled()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.disfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

--Destroy and Apply Effects
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsDisabled() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
		local dg=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsCode,100429004),tp,LOCATION_ONFIELD,0,1,nil)
		if #dg>0 then
		--Cannot be Material
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e4,true)
			local e5=e3:Clone()
			e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
			tc:RegisterEffect(e5,true)
			local e6=e3:Clone()
			e6:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			tc:RegisterEffect(e6,true)
			local e7=e3:Clone()
			e7:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
			tc:RegisterEffect(e7,true)
			tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
		end
	end
end
