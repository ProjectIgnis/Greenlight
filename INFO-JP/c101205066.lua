--亜空間物質回送装置
--Interdimensional Matter Translocator
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Banish a monster and return it to the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.rmvtg(s.rmvfilter1))
	e2:SetOperation(s.rmvop)
	c:RegisterEffect(e2)
	--Banish a monster that has its effects negated and return it to the field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	--e3:SetCondition(function(_,tp,_,ep) return ep==1-tp end)
	e3:SetTarget(s.rmvtg(s.rmvfilter2))
	e3:SetOperation(s.rmvop)
	c:RegisterEffect(e3)
	--Banish this card until the End Phase Before resolving an opponent's card effect that targets it
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetCountLimit(1,{id,2})
	e4:SetOperation(s.selfrmvop)
	c:RegisterEffect(e4)
end
function s.rmvfilter1(c)
	return c:IsAbleToRemove() and Duel.GetMZoneCount(c:GetControler(),c)>0
end
function s.rmvfilter2(c)
	return c:IsDisabled() and c:IsAbleToRemove() and Duel.GetMZoneCount(c:GetControler(),c)>0
end
function s.rmvtg(filter)
	return function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then return chkc:IsLocation(LOCATION_MZONE) and filter(chkc) end
		if chk==0 then return Duel.IsExistingTarget(filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectTarget(tp,filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Debug.Message(g:GetFirst())
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
	end
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT|REASON_TEMPORARY)>0 and tc:IsLocation(LOCATION_REMOVED) then
		Duel.BreakEffect()
		Duel.ReturnToField(tc)
	end
end
function s.selfrmvop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return end
	local c=e:GetHandler()
	if not (re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and c:IsAbleToRemove()) then return end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if g:IsContains(c) then
		Duel.Hint(HINT_CARD,1-tp,id)
		local ct=Duel.GetTurnCount()
		aux.RemoveUntil(c,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp,function() return Duel.GetTurnCount()==ct+1 end,nil,2)
	end
end