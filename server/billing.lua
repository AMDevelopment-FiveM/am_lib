AM.Billing = AM.Billing or {}
function AM.Billing.Create(source,target,data)
    data=data or {}; local amount=math.floor(tonumber(data.amount) or 0); if amount<=0 then return false,'invalid_amount' end
    local bridge=AM.Bridges.billing or 'standalone'
    if bridge=='esx_billing' then TriggerClientEvent('esx_billing:sendBill',target,source,data.account or 'society_police',data.label or 'Invoice',amount); return true end
    if bridge=='qb_management' then return false,'manual_billing_required' end
    TriggerEvent('am_lib:server:billCreated',source,target,data); return true,'event'
end
