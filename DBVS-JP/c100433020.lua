--スタンドアップ・センチュリオン！
--Stand-Up Centurion!
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.reg)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.indcon)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)
	--place in s&t zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,0})
	e3:SetCondition(s.tfcon)
	e3:SetCost(s.tfcost)
	e3:SetTarget(s.tftg)
	e3:SetOperation(s.tfop)
	c:RegisterEffect(e3)
	--synchro summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.syntg)
	e4:SetOperation(s.synop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_CENTURION }
function s.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function s.indfilter(c)
	return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER) and c:IsSetCard(SET_CENTURION)
end
function s.indcon(e)
	return Duel.IsExistingMatchingCard(s.indfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.indval(e,re,tp)
	return e:GetHandlerPlayer()==1-tp
end
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
function s.tfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tffilter(c)
	return c:IsSetCard(SET_CENTURION) and c:IsMonster() and not c:IsForbidden()
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
function s.syncheck(tp,sg,sc)
	return sg:IsExists(Card.IsSetCard,1,nil,SET_CENTURION)
end
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		Synchro.CheckAdditional=s.syncheck
		local res=Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil)
		Synchro.CheckAdditional=nil
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	Synchro.CheckAdditional=s.syncheck
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst())
	end
	Synchro.CheckAdditional=nil
end
