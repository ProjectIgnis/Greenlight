--時の機械－タイム・エンジン
--Time Engine
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 monster destroyed by an opponent's card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_SINGLE)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_METALMORPH}
function s.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and c:IsCanBeEffectTarget(e)
end
function s.metalmorphfilter(c)
	return c:IsSetCard(SET_METALMORPH) and c:IsFaceup() and c:IsTrap()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return eg:IsContains(chkc) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and eg and eg:IsExists(s.spfilter,1,nil,e,tp) end
    local g=eg:Filter(s.spfilter,nil,e,tp)
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,LOCATION_GRAVE)
	if Duel.IsExistingMatchingCard(s.metalmorphfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil) then
		local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetBaseAttack())
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		if not tc:IsRace(RACE_MACHINE) or not tc:IsLevelAbove(5) then return end
		if Duel.IsExistingMatchingCard(s.metalmorphfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
			Duel.Destroy(sg,REASON_EFFECT)
			if tc:GetBaseAttack()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
			end
		end
	end
end