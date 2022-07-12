--Scripted by IanxWaifu
--CONTAIN!
local s,id=GetID()
function s.initial_effect(c)
	--Target Effect Monster
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
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
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

--Destroy and Apply Limit
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local dg=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsCode,100429004),tp,LOCATION_ONFIELD,0,1,nil)
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and #dg>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_EVENT+RESET_TODECK+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(0,1)
		e2:SetValue(s.aclimit2)
		e2:SetLabel(tc:GetOriginalCode())
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
end

--Opponent Cannot Activate That Copy
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end

--Opponent Cannot Activate With Same Original Name
function s.aclimit2(e,re,tp)
	return re:GetHandler():IsOriginalCode(e:GetLabel()) and re:IsActiveType(TYPE_MONSTER)
end
