--ディーヴジャン
--Division
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon "Machine Tokens"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.tkncost)
	e1:SetTarget(s.tkntg)
	e1:SetOperation(s.tknop)
	c:RegisterEffect(e1)
	--Destroy any number of Tokens you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_names={id,id+100} --"Division", "Machine Token"
function s.tkncost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,id),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g==g:FilterCount(Card.IsReleasable,nil) and Duel.GetMZoneCount(tp,g)>0 end
	g:Filter(Card.IsReleasable,nil)
	Duel.Release(g,REASON_COST)
	e:SetLabel(#g*2)
end
--NOTE: the level of the token is unknown at the moment. I am using 4
function s.tkntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,id+100,0,TYPES_TOKEN,200,2000,4,RACE_MACHINE,ATTRIBUTE_FIRE,POS_FACEUP) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id+100,0,TYPES_TOKEN,200,2000,4,RACE_MACHINE,ATTRIBUTE_FIRE,POS_FACEUP) then return end
	local ft=math.min(e:GetLabel(),Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ft==0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local ct=Duel.AnnounceNumberRange(tp,1,ft)
	for i=1,ct do
		local token=Duel.CreateToken(tp,id+100)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			--Inflict 800 damage when the tokens are destroyed
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EVENT_LEAVE_FIELD)
			e1:SetOperation(s.damop)
			token:RegisterEffect(e1,true)
		end
	end
	Duel.SpecialSummonComplete()
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		Duel.Damage(1-e:GetHandlerPlayer(),800,REASON_EFFECT)
	end
	e:Reset()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsType(TYPES_TOKEN) end
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPES_TOKEN),LOCATION_MZONE,0,nil)
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsType,TYPES_TOKEN),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsType,TYPES_TOKEN),tp,LOCATION_MZONE,0,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end