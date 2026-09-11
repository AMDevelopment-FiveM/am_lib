AM.Log = function(category,message,data)
    local payload=('[%s] %s%s'):format(category or 'general',message or '',data and (' | '..json.encode(data)) or '')
    if AMConfig.Logging.printToConsole then print('^5[AM_LIB]^7 '..payload) end
    if AMConfig.Logging.enabled and AMConfig.Logging.webhook~='' then
        PerformHttpRequest(AMConfig.Logging.webhook,function() end,'POST',json.encode({username='AM Lib',embeds={{title=category or 'AM Lib',description=message or '',fields=data and {{name='Data',value='```json\n'..json.encode(data)..'\n```'}} or nil}}}),{['Content-Type']='application/json'})
    end
end
exports('Log',AM.Log)
