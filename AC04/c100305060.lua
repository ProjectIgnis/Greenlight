--原石の穿光
--Primoredial Schiller
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Negate the effects of 1 card on the field and if you do, banish it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Set itself if you control a "Primoredial" monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.setcond)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_PRIMOREDIAL}
function s.nocostfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
		and (c:IsType(TYPE_NORMAL) or (c:IsSetCard(SET_ASHENED) and c:IsLevelAbove(5)))
end
function s.costfilter(c)
	return (c:IsSetCard(SET_PRIMOREDIAL) or (c:IsMonster() and c:IsType(TYPE_NORMAL)))
		and not (c:IsPublic() and c:IsCode(id))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local nocost=Duel.IsExistingMatchingCard(s.nocostfilter,tp,LOCATION_MZONE,0,1,nil)
	local canpaycost=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler())
	if chk==0 then return nocost or canpaycost end
	if nocost and not (Duel.SelectYesNo(tp,aux.Stringid(id,0)) and canpaycost ) then--"reveal a card"?
		return
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
end
function s.disfilter(c)
	return c:IsFaceup() and c:IsNegatable() and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsNegatable() end
	if chk==0 then return Duel.IsExistingTarget(s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) and tc:IsRelateToEffect(e) then
		--Negate its effects until the end of this turn
		tc:NegateEffects(e:GetHandler(),RESET_PHASE|PHASE_END)
		Duel.AdjustInstantly(tc)
		if tc:IsDisabled() then
			Duel.Remove(tc,nil,REASON_EFFECT)
		end
	end
end
function s.setcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_PRIMOREDIAL),tp,LOCATION_MZONE,0,1,nil)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end