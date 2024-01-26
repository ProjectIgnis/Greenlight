--雪沓の 跡追うひとつ またひとつ
--One by One We Walk, Frosty Forest Frolicking, Treading in the Tracks
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Banish up to 5 cards from your GY face-down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(aux.NOT(Card.IsCode),1,nil,id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,nil,tp,POS_FACEDOWN,REASON_EFFECT) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,5,nil,tp,POS_FACEDOWN,REASON_EFFECT)
	if Duel.Remove(g1,POS_FACEDOWN,REASON_EFFECT)>0 and Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)>=7
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil,1-tp,POS_FACEDOWN,REASON_EFFECT) then
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil,1-tp,POS_FACEDOWN,REASON_EFFECT)
		if #g>5 then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
			g=g:FilterSelect(tp,Card.IsAbleToRemove,5,5,nil,1-tp,POS_FACEDOWN,REASON_EFFECT)
		end
		Duel.BreakEffect()
		Duel.Remove(g2,POS_FACEDOWN,REASON_EFFECT,nil,1-tp)
	end
end