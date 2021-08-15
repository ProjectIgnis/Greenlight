--メタリオン・エーラクレスター 
--Metallion Eraclestar
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_IMAGINARY_ACTOR,160204010)
	--Shuffle 2 monsters from opponent's GY to deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tdtg1)
	e1:SetOperation(s.tdop1)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsLevelBelow(5) and c:IsRace(RACE_DRAGON) and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
--shuffle from grave to deck
function s.filter(c)
	return c:IsAbleToDeck()
end
function s.tdtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.tdop1(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(tg)
	if Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_COST)==1 then
		--Effect
		Duel.SendtoGrave(g,REASON_COST)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,3,nil)
		Duel.HintSelection(g)
		if #g>0 then
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
--shuffle up to 2 spellcaster to the deck
function s.tdtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
end
function s.tdfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsFaceup() and c:IsAbleToDeck()
end
function s.tdop2(e,tp,eg,ep,ev,re,r,rp)
	--requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(tg)
	if Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_COST)==1 then
		--Effect
		--Effect
		Duel.SendtoGrave(g,REASON_COST)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.tdfilter(),tp,0,LOCATION_MZONE,1,2,nil)
		Duel.HintSelection(g)
		if #g>0 then
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end