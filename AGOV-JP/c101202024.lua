--陀羅威
--Tarai
--Ashaki
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --Register a flag on monster that activate effects on the field
    aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_CONTROLER)
	local tc=re:GetHandler()
	if re:IsActiveType(TYPE_MONSTER) and tc:IsRelateToEffect(re) and loc==LOCATION_MZONE then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
function s.tfilter(c)
	return c:IsFaceup() and c:GetFlagEffect(id)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local tg=Duel.GetMatchingGroup(s.tfilter,tp,LOCATION_MMZONE,LOCATION_MMZONE,nil)
	if chkc then return chkc:IsLocation(LOCATION_MMZONE) end
	if chk==0 then return Duel.IsExistingTarget(s.tfilter,tp,LOCATION_MMZONE,LOCATION_MMZONE,1,nil,c,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (Duel.GetMZoneCount(tp,tg)>0 or Duel.GetMZoneCount(1-tp,tg)>0) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_MMZONE,LOCATION_MMZONE,1,1,nil,c,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local zone=1<<tc:GetSequence()
		local p=tc:IsControler(tp) and tp or (1-tp)
		local c=e:GetHandler()
		if Duel.Destroy(tc,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
			Duel.SpecialSummon(c,0,tp,p,false,false,POS_FACEUP,zone)
		end
	end
end