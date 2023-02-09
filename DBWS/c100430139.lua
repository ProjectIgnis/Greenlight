--Ｒｅｃｅｔｔｅ ｄｅ Ｐｅｒｓｏｎｎｅｌ～賄いのレシプ
--Recette de Spécialité – Chef’s Specialty Recipe
--scripted by Raye
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--ritual summon
	local e2=Ritual.CreateProc(c,RITPROC_EQUAL,aux.FilterBoolFunction(Card.IsSetCard,SET_NOUVELLEZ),nil,aux.Stringid(id,1),nil,nil,s.matfilter,nil,nil,function(e,tp,g,sc) return not g:IsContains(e:GetHandler()), g:IsContains(e:GetHandler()) end)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,2})
	e2:SetCost(s.rtcost)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NOUVELLEZ}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+100,0,TYPES_TOKEN,50,50,1,RACE_FIEND,ATTRIBUTE_DARK)
		and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsType,TYPE_RITUAL),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsType,TYPE_RITUAL),tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+100,0,TYPES_TOKEN,50,50,1,RACE_FIEND,ATTRIBUTE_DARK) then return false end
	local tc=Duel.GetFirstTarget()
	local token=Duel.CreateToken(tp,id+100)
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end
function s.matfilter(c)
	return c:IsLocation(LOCATION_MZONE+LOCATION_HAND) and c:IsType(TYPE_RITUAL)
end
function s.rtcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
