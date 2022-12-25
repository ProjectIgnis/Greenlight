--Japanese name
--Sweet Dreams Nemrelia
--scripted by Naim
local SET_NEMRELIA=0x28f
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Nemrelia" monster to the hand and prevent the opponent's effects when a "Nemrelia" is Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Place 1 "Dreaming Nemrelia" in the Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(s.tedcost)
	e2:SetTarget(s.tedtg)
	e2:SetOperation(s.tedop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NEMRELIA}
s.listed_names={101112015}
function s.thfilter(c)
	return c:IsSetCard(SET_NEMRELIA) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	--Prevent activations when a "Nemrelia" monster is Normal or Special Summoned
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(s.sumop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	Duel.RegisterEffect(e2,tp)
end
function s.sumfilter(c)
	return c:IsSetCard(SET_NEMRELIA) and c:IsControler(tp) 
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.sumfilter,1,nil,tp) then
		Duel.SetChainLimitTillChainEnd(function(e,rp,tp) return tp==rp end)
	end
end
function s.tedcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() end
	Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
end
function s.tedfilter(c)
	return c:IsCode(101112015) and c:IsFaceup() and not c:IsForbidden()
end
function s.tedtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.tedfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tedfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.tedfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,tp,0)
end
function s.tedop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.SendtoExtraP(tc,tp,REASON_EFFECT)
	end
end