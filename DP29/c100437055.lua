--トリックスター・ディフュージョン
--Trickstar Diffusion
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon or Link Summon 1 "Trickstar" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Your opponent's monsters can only attack the targeted monster for atatcks
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,{id,1})
	e2:SetCost(aux.selfbanishcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_TRICKSTAR}
function s.linkfilter(c)
	return c:IsLinkSummonable() and c:IsSetCard(SET_TRICKSTAR)
end
function s.matfilter(c)
	return aux.SpElimFilter(c) and c:IsAbleToRemove()
end
function s.extrafil(c)
	return c:IsMonster() and c:IsAbleToRemove()
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(s.extrafil,tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local params = {fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_TRICKSTAR),
					matfilter=s.matfilter,
					extrafil=s.fextra,
					extraop=Fusion.BanishMaterial,
					extratg=s.extratg}
	local b1=Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_EXTRA,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Fusion Summon 1 "Trickstar" monster
		local params = {fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_TRICKSTAR),
						matfilter=s.matfilter,
						extrafil=s.fextra,
						extraop=Fusion.BanishMaterial,
						extratg=s.extratg}
		if Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0) then
			Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
		end
	elseif op==2 then
		--Link Summon 1 "Trickstar" monster
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.linkfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.LinkSummon(tp,tc)
		end
	end
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsSetCard(SET_TRICKSTAR) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSetCard,SET_TRICKSTAR),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSetCard,SET_TRICKSTAR),tp,LOCATION_MZONE,0,1,1,nil)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local fid=tc:GetRealFieldID()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_ONLY_ATTACK_MONSTER)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetCondition(function(e) return tc:IsFaceup() and tc:GetRealFieldID()==fid end)
		e1:SetValue(function(e,c) return c:GetRealFieldID()==fid end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		aux.RegisterClientHint(e:GetHandler(),0,tp,0,1,aux.Stringid(id,4))
	end
end