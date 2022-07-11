--RESCUE!
--Scripted by Zefile
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e3=Effect.CreateEffect(c)
	e3:SetCode(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={0x287}
function s.spfilter(c,e,tp,ex)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ((c:IsSetCard(0x287) and c:IsControler(tp)) or (ex and c:IsControler(1-tp)))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ex=Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,100429004),tp,LOCATION_MZONE,0,1,nil)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp,ex) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,ex) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,ex)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end