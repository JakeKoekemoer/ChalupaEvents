function TwitchIntegration:new (o, integration_url){
    o = o or {}
    setmetatable(o, self)

    self._integration_url = integration_url
    self._websocket = nil
    self._connected = false
    self._log = {}

    return o
}

function TwitchIntegration:setStateConnected(){
    self._connected = true
}

function TwitchIntegration:setStateDisconnected(){
    self._connected = false
}

function TwitchIntegration:getLog(){
    return self:_log
}

function TwitchIntegration:logMessage(messageType, message){
	table.insert(self:getLog(), messageType + ": " + message)
}

function TwitchIntegration:openConnectToChat(){
    local websocket = require'websocket'
    local client = websocket.client.copas({timeout=2})
    local ok,err = client:connect(self:_integration_url,'echo')

    if not ok then
        print('Could not connect to twitch chat! ',err)
        self:logMessage('Error','Could not connect to twitch chat!')
        self:setStateDisconnected()
    end

    local helloTwitch = self:sendClientHello()

    if helloTwitch then
        local message,opcode = client:receive()
        if message then
            print('Twitch Responded to hello with: ',message,opcode)
        else
            self:logMessage('Error','Twitch told us to get lost')
            self:setStateDisconnected()
        end
    end 
    else if not helloTwitch
        print('Twitch Connection was closed before the hello was properly sent!')
        self:logMessage('Error','Twitch Connection was closed before the hello was properly sent!')
        self:setStateDisconnected()
    end
}

function TwitchIntegration:sendClientHello(){
    local ok = client:send('hello')
    if ok then
        return true
    else
        return false
    end
}

function TwitchIntegration:closeConnection(){
    local close_was_clean,close_code,close_reason = client:close(4001,'lost interest')
}

twitch = TwitchIntegration:new(nil, 'ws://irc-ws.chat.twitch.tv:80')
twitch:openConnectToChat()
twitch:closeConnection();