--フュージョンキャンセル
--Fusion Cancel
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DELAY)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_BATTLE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp)
end
function s.tdfilter(c)
	return c:IsAbleToDeck() and c:IsType(TYPE_FUSION) and not c:IsMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.sumfilter(c,e,tp,fc)
	return c:IsCode(table.unpack(fc.material)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local dg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #dg==0 then return end
	dg=dg:AddMaximumCheck()
	Duel.HintSelection(dg,true)
	if Duel.SendtoDeck(dg,nil,0,REASON_EFFECT)==0 then return end
	local tc=dg:GetFirst()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<tc.min_material_count then return end
	local sp=tc:GetOwner()
	local sg=Duel.GetMatchingGroup(s.sumfilter,sp,LOCATION_GRAVE,0,nil,e,sp,tc)
	if aux.SelectUnselectGroup(sg,1,tp,tc.min_material_count,tc.max_material_count,s.rescon(tc),0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local spg=aux.SelectUnselectGroup(sg,1,tp,tc.min_material_count,tc.max_material_count,s.rescon(tc),1,sp)
		if #spg>0 then
			Duel.SpecialSummon(spg,0,sp,sp,false,false,POS_FACEUP)
		end
	end
end
function s.rescon(tc)
	return function(sg,e,tp,mg)
		return sg:GetClassCount(Card.GetCode)==#tc.material
	end
end