--ロード・オブ・ザ・タキオンギャラクシー
--Lord of the Tachyon Galaxy
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Can be activated from the hand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)
	--Shuffle opponent monsters to the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	e1:SetCondition(function() return Duel.IsBattlePhase() end)
	e1:SetCost(s.tdcost)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_GALAXY_EYES_TACHYON_DRAGON),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.tdcostfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(SET_GALAXY_EYES) and c:IsFaceup()
end
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local xg=Duel.GetMatchingGroup(s.tdcostfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST,xg) end
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST,xg)
end
function s.tdfilter(c)
	return (c:IsStatus(STATUS_SPSUMMON_TURN) or c:IsStatus(STATUS_SUMMON_TURN)) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_NUMBER_C),tp,LOCATION_MZONE,0,1,nil) then
		e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	else
		e:SetProperty(0)
	end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end