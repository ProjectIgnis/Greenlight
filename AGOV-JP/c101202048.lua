--光翼の竜
--The Light-Winged Dragon
--Scripted by Marbele 
local s,id=GetID()
function s.initial_effect(c)
	--Activate 
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SUPREME_KING_DRAGON,SET_SUPREME_KING_GATE}
s.listed_names={13331639}

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()&PHASE_MAIN1+PHASE_MAIN2>0
end
function s.filter(c,z,e,tp)
	return c:IsMonster() and (c:IsSetCard(SET_SUPREME_KING_DRAGON) or c:IsSetCard(SET_SUPREME_KING_GATE)) and c:IsType(TYPE_PENDULUM) and (c:IsAbleToHand() or 
	(z and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zarc=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,13331639)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,zarc,e,tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
		local zarc=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,13331639)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,zarc,e,tp):GetFirst()
	if not g then return end
	aux.ToHandOrElse(g,tp,
		function(g)
			return zarc and g:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function(g)
			return Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end, aux.Stringid(id,0))
	end