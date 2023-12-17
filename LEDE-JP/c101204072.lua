--古代の機械競闘
--Ancient Gear Duel
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0)
	c:RegisterEffect(e1)
	--Fusion Summon 1 Fusion Monster that mentions "Ancient Gear Golem"
	local params = {fusfilter=s.fusfilter,
					matfilter=Card.IsAbleToRemove,
					extrafil=s.fmatextra,
					extratg=s.extratarget,
					extraop=Fusion.BanishMaterial,
					stage2=s.stage2}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_BATTLE_START|TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp) Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end)
	e2:SetTarget(Fusion.SummonEffTG(params))
	e2:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e2)
end
s.listed_names={CARD_ANCIENT_GEAR_GOLEM,id}
s.listed_series={SET_ANCIENT_GEAR}
function s.fusfilter(c)
	return c:ListsCode(CARD_ANCIENT_GEAR_GOLEM)
end
function s.aggfilter(c)
	return c:IsCode(CARD_ANCIENT_GEAR_GOLEM) and c:IsLocation(LOCATION_MZONE)
end
function s.fcheck(tp,sg,fc)
	return sg:IsExists(s.aggfilter,1,nil)
end
function s.fmatextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil),s.fcheck
	end
	return nil,s.fcheck
end
function s.extratarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_MZONE|LOCATION_GRAVE)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		--Can make a 2nd and 3rd attack during the Battle Phase
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end