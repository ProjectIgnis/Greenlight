--コード・オブ・ソウル
--Code of Soul
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--apply sanctuary effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetOperation(s.ssop)
	c:RegisterEffect(e2)
	--link summon	
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function(_,tp) return Duel.IsTurnPlayer(1-tp) and Duel.IsMainPhase() end)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.lktg)
	e3:SetOperation(s.lkop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_SALAMANGREAT }
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsType,TYPE_LINK),tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()	
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.linkcon)
	e1:SetTarget(s.linktg)
	e1:SetOperation(s.linkop)
	e1:SetValue(SUMMON_TYPE_LINK)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2:SetTargetRange(LOCATION_EXTRA,0)
	e2:SetTarget(s.mattg)
	e2:SetLabelObject(e1)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.lmfilter(c,lc,tp)
	return c:IsFaceup() and c:IsLinkMonster()
		and c:IsSummonCode(lc,SUMMON_TYPE_LINK,tp,lc:GetCode()) and c:IsCanBeLinkMaterial(lc,tp)
		and Duel.GetLocationCountFromEx(tp,tp,c,lc)>0
end
function s.linkcon(e,c,must,g,min,max)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.lmfilter,tp,LOCATION_MZONE,0,nil,c,tp)
	local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,g,REASON_LINK)
	if must then mustg:Merge(must) end
	return ((#mustg==1 and s.lmfilter(mustg:GetFirst(),c,tp)) or (#mustg==0 and #g>0))
		and Duel.GetFlagEffect(tp,id)==0
end
function s.linktg(e,tp,eg,ep,ev,re,r,rp,chk,c,must,g,min,max)
	local g=Duel.GetMatchingGroup(s.lmfilter,tp,LOCATION_MZONE,0,nil,c,tp)
	local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,g,REASON_LINK)
	if must then mustg:Merge(must) end
	if #mustg>0 then
		if #mustg>1 then
			return false
		end
		mustg:KeepAlive()
		e:SetLabelObject(mustg)
		return true
	end
	local tc=g:SelectUnselect(Group.CreateGroup(),tp,false,true)
	if tc then
		local sg=Group.FromCards(tc)
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.linkop(e,tp,eg,ep,ev,re,r,rp,c,must,g,min,max)
	local mg=e:GetLabelObject()
	c:SetMaterial(mg)
	Duel.SendtoGrave(mg,REASON_MATERIAL+REASON_LINK)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.mattg(e,c)
	return c:IsSetCard(SET_SALAMANGREAT) and c:IsLinkMonster()
end
function s.lkfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsLinkAbove(3) and c:IsLinkSummonable()
end
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.LinkSummon(tp,tc)
	end
end
