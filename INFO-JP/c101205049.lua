--ヴァルモニカの神奏－ヴァーラル
--Valar, Vaalmonican Hallow Hymn
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2 monsters, including a "Vaalmonica" Link Monster
	Link.AddProcedure(c,nil,2,2,s.matcheck)
	--Unaffected by non-"Vaalmonica" cards' effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.immcon)
	e1:SetValue(function(e,te) return not te:GetOwner():IsSetCard(SET_VALMONICA) end)
	c:RegisterEffect(e1)
	--Gains additional attack for each Level 4 "Vaalmonica" monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function(e) return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil) end)
	c:RegisterEffect(e2)
	--Negate Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_SPSUMMON)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_VALMONICA}
s.counter_place_list={COUNTER_RESONANCE}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(SET_VALMONICA,lc,sumtype,tp) and c:IsType(TYPE_LINK,lc,sumtype,tp)
end
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(s.matfilter,1,nil,lc,sumtype,tp)
end
function s.immcon(e)
	return Duel.GetCounter(e:GetHandlerPlayer(),1,0,COUNTER_RESONANCE)>=6
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.atkfilter(c)
	return c:IsLevel(4) and c:IsSetCard(SET_VALMONICA) and c:IsFaceup()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,COUNTER_RESONANCE,3,REASON_EFFECT) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	if Duel.Destroy(eg,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.RemoveCounter(tp,1,0,COUNTER_RESONANCE,3,REASON_EFFECT)
	end
end