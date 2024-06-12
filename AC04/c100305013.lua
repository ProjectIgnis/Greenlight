--原石竜インペリアル・ドラゴン
--Imperial Dragon the Primoredial Dragon
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Requires 1 Normal Monster Tribute to Normal Summon face-up.
	local e2=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(s.selfnssumcon)
	e1:SetTarget(s.selfnssumtg)
	e1:SetOperation(s.selfnssumop)
	e1:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e1)
	--Normal Summon 1 "Primoredial" monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.sumcond)
	e2:SetCost(s.sumcost)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
	--Apply effects if it is Tribute Summoned
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_TRIBUTE) end)
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_PRIMOREDIAL}
function s.tributefilter(c,tp)
	return c:IsType(TYPE_NORMAL) and (c:IsControler(tp) or c:IsFaceup())
end
function s.selfnsumcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return aux.SelectUnselectGroup(Duel.GetReleaseGroup(tp),e,tp,1,1,s.rescon,0)
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(s.tributefilter,1,nil,tp)
end
function s.selfnssumtg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=aux.SelectUnselectGroup(Duel.GetReleaseGroup(tp),e,tp,1,1,s.rescon,1,tp,HINTMSG_RELEASE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.selfnssumop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
function s.sumcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and Duel.IsMainPhase()
end
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function s.sumfilter(c)
	return c:IsSetCard(SET_PRIMOREDIAL) and c:IsSummonable(true,nil)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,g,1,tp,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end
function s.rmvfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToRemove()
		and Duel.IsExistingMatchingCard(s.matchfilter,tp,LOCATION_GRAVE,0,1,nil,c:GetRace(),c:GetAttribute())
end
function s.matchfilter(c,race,att)
	return c:IsType(TYPE_NORMAL) and (c:IsRace(race) or c:IsAttribute(att))
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNegatable,tp,0,LOCATION_MZONE,1,nil) end
	local disg=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,disg,#disg,tp,0)
	local rmvg=Duel.GetMatchingGroup(s.rmvfilter,tp,0,LOCATION_MZONE,nil,tp)
	if #rmvg>0 then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rmvg,#rmvg,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp,chk)
	local disg=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_MZONE,nil):Filter(Card.IsCanBeDisabledByEffect,nil,e)
	--if #disg==0 then return end
	local c=e:GetHandler()
	--Negate the effects of all face-up monsters your opponent controls 
	for tc in disg:Iter() do
		tc:NegateEffects(e:GetHandler())
		Duel.AdjustInstantly(tc)
	end
	--Banish monsters with the same Type/Attributes as Normal monsters in your GY
	local rmvg=Duel.GetMatchingGroup(s.rmvfilter,tp,0,LOCATION_MZONE,nil,tp)
	if #rmvg>0 then
		Duel.BreakEffect()
		Duel.Remove(rmvg,nil,REASON_EFFECT)
	end
end