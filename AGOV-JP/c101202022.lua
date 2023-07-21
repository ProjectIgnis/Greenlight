--オオヤツ・ツマムヒメ
--Ooyatsu Tsumamuhime
--Ashaki
local s,id=GetID()
function s.initial_effect(c)
        --Summon Token
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp,eg) return eg:IsContains(e:GetHandler()) end)
        e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	c:RegisterEffect(e2)
        --Negate Summon
        local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_SPSUMMON)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.discon)
	e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,27204312,TYPES_TOKEN,800,800,1,RACE_PLANT,ATTRIBUTE_LIGHT,POS_FACEUP) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
        if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,27204312,TYPES_TOKEN,800,800,1,RACE_PLANT,ATTRIBUTE_LIGHT,POS_FACEUP) then return end
	local token=Duel.CreateToken(tp,27204312)
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=ep and Duel.GetCurrentChain()==0
end
function s.cfilter(c)
	return c:IsType(TYPE_NORMAL)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,c:IsType(TYPE_NORMAL),1,false,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil)
	Duel.Release(g,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end
