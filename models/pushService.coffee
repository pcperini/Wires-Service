class PushService
    # Class Properties
    @options =
        dev:
            key: "keys/dev_key.pem"
            cert: "keys/dev_cert.pem"
            production: true
            maxConnections: Infinity
            
        prod:
            key: "keys/prod_key.pem"
            cert: "keys/prod_cert.pem"
            production: false
            maxConnections: Infinity
        
        inDev: true
        
    # Class Accessors
    @validToken: (token) ->
        return token.match(/^[A-Fa-f0-9]{64}$/)?
        
    # Push Handlers
    push: (type, text, sourceURL, devices) ->
        notification = new apn.Notification
        
        notification.expiry = Math.floor(Date.now() / 1000) + 3600; # 1h
        notification.alert = text
        notification.payload =
            notificationType: type
            sourceURL: sourceURL
            
        options = if Device.options.inDev then Device.options.dev else Device.options.prod        
        connection = new apn.Connection(options)
        
        connection.sendNotification(notification, (device.token for token in devices))
        connection.on "transmissionError", (err, notification, device) ->
            console.error "Error " + err + " Failed to send notification " + JSON.stringify(notification) + " to device " + device + "."
        
module.exports = PushService