--神光の龍
--Enlightenment Dragon
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.fusfilter(57774843),s.fusfilter(19959563))
	Fusion.AddContactProc(c,s.contactfil,s.contactop,true)
	--banish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.rmcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--discard deck
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.gycon)
	e3:SetTarget(s.gytg)
	e3:SetOperation(s.gyop)
	c:RegisterEffect(e3)
end
s.listed_names={57774843,19959563}
s.material={57774843,19959563}
s.material_count=2
s.min_material_count=2
s.max_material_count=2
function s.fusfilter(cd)
	return  function(c,fc,sumtype,tp,sub,mg,sg)
				return c:IsSummonCode(fc,sumtype,tp,cd) and (not sg or not sg:IsExists(Card.IsLocation,1,c,c:GetLocation()))
			end
end
function s.contactfil(tp)
	local loc=LOCATION_ONFIELD|LOCATION_GRAVE 
	if Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then return false end
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,loc,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_MATERIAL)
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	Duel.PayLPCost(tp,2000)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,e:GetHandler())
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,e:GetHandler())
	if #g>0 then Duel.Remove(g,POS_FACEUP,REASON_EFFECT) end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsCode(57774843,19959563) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_REMOVED,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=2 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_REMOVED,0,nil)
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	if #tg==2 and Duel.SendtoHand(tg,nil,REASON_EFFECT)==2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and tg:FilterCount(s.spfilter,nil,e,tp)==2 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.SpecialSummon(tg,0,tp,tp,true,false,REASON_EFFECT)
	end
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,4)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,4,REASON_EFFECT)
end
