--幻想魔獣キマイラ
--Chimera the Illusion Magical Beast
--Scripted by Eerie Code
local CARD_CHIMERA=4796100 --Chimera the Flying Mythical Beast, to be removed
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PHANTASMA),1,99,CARD_CHIMERA)
	--change name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e1:SetValue(CARD_CHIMERA)
	c:RegisterEffect(e1)
	--multiattack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.matcheck)
	c:RegisterEffect(e2)
	--cannot be destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.indestg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--atk to 0
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.condition)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_CHIMERA}
function s.matcheck(e,c)
	local g=c:GetMaterial()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetValue(#g-1)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE&~RESET_TOFIELD)
	c:RegisterEffect(e1)
end
function s.indestg(e,c)
	return c==e:GetHandler() or c==e:GetHandler():GetBattleTarget()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_OPPO_BATTLE) and c:IsRelateToBattle()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if tc and tc:IsRelateToBattle() and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc:NegateEffects(c)
	end
end