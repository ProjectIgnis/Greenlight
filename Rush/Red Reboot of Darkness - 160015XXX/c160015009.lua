-- ダークネス・パパラッチ
-- Darkness Paparazzi

local s,id=GetID()
function s.initial_effect(c)
	--Send the top 3 cards of deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.confilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(5)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=10 and Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,c,tp,c) end
end
function s.tdfilter(c,tp,sc)
	return c:IsMonster() and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToDeckOrExtraAsCost()
		and Duel.IsExistingMatchingCard(s.tdfilter2,tp,LOCATION_GRAVE,0,2,Group.FromCards(c,sc),c:GetAttribute())
end
function s.tdfilter2(c,att)
	return c:IsMonster() and c:IsAttribute(att) and c:IsAbleToDeckOrExtraAsCost()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCountRush(Card.IsLevelAbove,tp,LOCATION_GRAVE,0,nil,7)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.filter(c)
	return c:IsMonster() and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToDeckOrExtraAsCost()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
	local td=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_SELECT)
	Duel.HintSelection(td,true)
	if Duel.SendtoDeck(td,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		local ct=Duel.GetMatchingGroupCountRush(Card.IsLevelAbove,tp,LOCATION_GRAVE,0,nil,7)
		if ct>0 then
			Duel.Draw(tp,ct,REASON_EFFECT)
		end
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetAttribute)==1 and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,sg,e,tp)
end