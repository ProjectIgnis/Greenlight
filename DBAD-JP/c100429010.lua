--ALERT!
--Scripted by Zefile
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
s.listed_series={0x287}
function s.thfilter(c)
	return c:IsSetCard(0x287) and c:IsAbleToHand()
end
function s.selchk(tp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,100429004),tp,LOCATION_MZONE,0,1,nil)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_GRAVE
	if s.selchk(tp) then loc=loc+LOCATION_DECK end
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,loc,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,loc)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if s.selchk(tp) and not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) then
		loc=LOCATION_DECK
	else
		if s.selchk(tp) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			loc=LOCATION_DECK
		else
			loc=LOCATION_GRAVE
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,loc,0,1,1,nil,e,tp)
	if #g>0 then 
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		if loc==LOCATION_DECK then Duel.ConfirmCards(1-tp,g) end
	end
end