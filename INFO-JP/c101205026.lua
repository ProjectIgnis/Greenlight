--無孔砲塔－ディセイブラスター
--Deceiveblaster the Matchless Turret
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--Negate effects activated in this card's column
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_ACTIVATING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e2)
	--Special Summon this card
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetRange(LOCATION_HAND)
	e3:SetValue(s.hspval)
	c:RegisterEffect(e3)
	--Place this card in the Pendulum Zone
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.pencon)
	e4:SetTarget(s.pentg)
	e4:SetOperation(s.penop)
	c:RegisterEffect(e4)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local seq,p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_SEQUENCE,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	if loc&LOCATION_MZONE>0 then
		if seq==5 then seq=1 elseif seq==6 then seq=3 end
	elseif loc&LOCATION_SZONE==0 then return end
	if p==1-tp then seq=4-seq end
	if c:GetSequence()==seq then
		Duel.NegateEffect(ev)
	end
end
function s.hspval(e,c)
	local tp=c:GetControler()
	local oz=0
	local fg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	for tc in fg:Iter() do
		oz=oz|tc:GetColumnZone(LOCATION_MZONE,0,0,tp)
	end
	return 0,ZONES_MMZ&~oz
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end