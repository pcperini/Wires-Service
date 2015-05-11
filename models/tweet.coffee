# Imports
htmlEntities = require("html-entities").AllHtmlEntities
Twitter = require "twitter"

class Tweet
    # Class Properties
    @htmlCoder = new htmlEntities()
    @client = new Twitter
        consumer_key: process.env.TWITTER_CONSUMER_KEY
        consumer_secret: process.env.TWITTER_CONSUMER_SECRET
        access_token_key: process.env.TWITTER_ACCESS_TOKEN_KEY
        access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET
        
    # Class Accessors
    @stream: (filterData, handler) ->
        Tweet.client.stream "statuses/filter", filterData, (stream) ->
            stream.on "data", (tweetData) ->
                handler(new Tweet tweetData)

    # Constructors
    constructor: (tweetData) ->
        @user =
            id: tweetData.user.id_str
            name: Tweet.htmlCoder.decode(tweetData.user.name)
        
        @text = Tweet.htmlCoder.decode(tweetData.text)
        @sourceURL = tweetData.entities.urls[-1..]?[0]?.expanded_url
        
    # Accessors
    isValid: () ->
        tweetValid = true
        if @user.id in process.env.TWITTER_GENERAL_ACCOUNTS.split(",") # tweet is from general account
            tweetValid = @text.toLowerCase().lastIndexOf("breaking") == 0 # and therefore must start with "BREAKING"
        
        tweetValid &= (@user.id in process.env.TWITTER_GENERAL_ACCOUNTS.split(",")) || (@user.id in process.env.TWITTER_BREAKING_ACCOUNTS.split(","))
        tweetValid &= @text.lastIndexOf("@") != 0 # doesn't start with @
        tweetValid &= @text.lastIndexOf("RT") != 0 # doesn't start with RT
        
        return tweetValid
    
    description: () ->
        return @user.name + " — " + (if @text.length >= 100 then @text.substring(0, 97) + "..." else @text)
        
module.exports = Tweet