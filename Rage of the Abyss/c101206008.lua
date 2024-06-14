--鋼鉄の幻想師
--Metal Copycat
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Increase Level by 4 during the opponent's turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return Duel.GetTurnPlayer()==1-e:GetHandlerPlayer() end)
	e1:SetValue(4)
	c:RegisterEffect(e1)
	--Set 1 "Metalmorph" Trap from your Deck, then draw 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_SINGLE)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Declare 1 Type to make this card that Type
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,{id,1})
    e4:SetOperation(s.typedeclareop)
    c:RegisterEffect(e4)
end
s.listed_series={SET_METALMORPH}
s.listed_names={CARD_ENHANCED_METALMORPH}
function s.setfilter(c)
	return c:IsTrap() and c:IsSSetable() and not c:IsForbidden() and c:IsSetCard(SET_METALMORPH)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_ENHANCED_METALMORPH) and Duel.IsPlayerCanDraw(tp,1) then
		e:SetCategory(CATEGORY_DRAW)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
		if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_ENHANCED_METALMORPH) and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
function s.typedeclareop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        local race=c:AnnounceAnotherRace(tp)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
        e1:SetCode(EFFECT_CHANGE_RACE)
        e1:SetValue(race)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END|RESET_OPPO_TURN)
        c:RegisterEffect(e1)
    end
end