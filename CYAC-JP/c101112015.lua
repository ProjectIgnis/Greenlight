--夢見るネムレリア
--Dreaming Nemurelia
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	Pendulum.AddProcedure(c)
	--to field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.tfcost)
	e1:SetTarget(s.tftg)
	e1:SetOperation(s.tfop)
	c:RegisterEffect(e1)
	--spsummon condition
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCondition(s.spcon)
	c:RegisterEffect(e3)
	--banish
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.listed_series={SET_NEMURELIA }
function s.counterfilter(c)
	return not c:IsCode(id)
end
function s.tfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,1),nil)
	--lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp)
end
function s.tffilter(c)
	return c:IsSetCard(SET_NEMURELIA) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and not c:IsForbidden()
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
		and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tffilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		Duel.SendtoExtraP(c,tp,REASON_EFFECT)
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsCode(id)
end
function s.condition(e)
	return Duel.GetMatchingGroupCount(aux.NOT(Card.IsCode),e:GetHandlerPlayer(),LOCATION_EXTRA,0,nil,id)==0
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return s.condition(e) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.rmfilter(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local gc=Duel.GetMatchingGroupCount(s.rmfilter,tp,LOCATION_REMOVED,0,nil)
	if chk==0 then return gc>2 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,gc/3,1-tp,LOCATION_ONFIELD+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,gc/3,tp,LOCATION_REMOVED)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local gc=Duel.GetMatchingGroupCount(s.rmfilter,tp,LOCATION_REMOVED,0,nil)/3
	if gc>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,gc,nil)
		if #g>0 and Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)>0 then
			local oc=#(Duel.GetOperatedGroup())
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local dg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_REMOVED,0,oc,oc,nil)
			if #dg>0 then
				Duel.BreakEffect()
				Duel.SendtoDeck(dg,nil,2,REASON_EFFECT)
			end
		end
	end
end
