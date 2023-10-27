--バーサーク・デーモン
--Berserk Archfiend
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself from the hand and destroy 2 monsters you control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Gain ATK equal to the total original ATK of your opponent's monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsRace,1,nil,RACE_FIEND)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanBeEffectTarget,e),tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and #g>0 and aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,0)
	end
	local dg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(dg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		local g=Duel.GetTargetCards(e)
		if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
			local evg=Duel.GetOperatedGroup()
			Duel.RaiseEvent(evg,id,re,r,tp,tp,0) --Raise an event to be detected by its second effect
		end
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.cfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,0,LOCATION_MZONE,#eg,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.cfilter,tp,0,LOCATION_MZONE,#eg,#eg,nil)
	local atk=g:GetSum(Card.GetBaseAttack)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,tp,atk)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	local g=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	if #g==0 then return end
	local atk=g:GetSum(Card.GetBaseAttack)
	--Gains ATK equal to those monsters' total original ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END|RESET_SELF_TURN,2)
	c:RegisterEffect(e1)
end
--[[

You can target up to 2 face-up monsters you control, including a Fiend monster; Special Summon this card from your hand, and if you do, destroy those monsters. You can only use this effect of "Berserk Archfiend" once per turn. When a monster(s) is destroyed by this card's previous effect: You can target an equal number of face-up monsters your opponent controls; this card gains ATK equal to those monsters' total original ATK until the end of your next turn.
]]--