local discord = require "@antiraid/discord"
local promise = require "@antiraid/promise"
local global = require "@antiraid-ext/global" 
local Primitives = require "@antiraid-core/primitives"
local Message = require "@antiraid-ext/events/discord/Message"
local onStartup = require "@antiraid-ext/events/antiraid/onStartup"
local array = require "@antiraid-ext/array"
local serde = require "@lune/serde" 

local evt: Primitives.Event, ctx: Primitives.TemplateContext = ...
 
local count = global.update("count", function() return 1 end, function(v: number) return v + 1 end)

Message(evt, function(msg)
    local time = task.wait(0)

    local channelId = msg.channel_id
    if channelId == nil 
    then
        return
    end

    local stdout = global.get("stdout")

    if msg.content == "A" then
        print("ABC")

        local discord_executor = discord.new(ctx);

        local lazyresp = promise.yield(
            discord_executor:create_message(
                {
                    channel_id = channelId,
                    data = { 
                        content = serde.encode("json", array.array( {a = 3}, {c = 2}, {count = count, stdout = stdout, loadstring = tostring(loadstring), time = time, executorType = type(discord_executor), executorTypeOf = typeof(discord_executor)} )) :: string?,
                    }
                }
            ))
      
        promise.yield(discord_executor:create_message({
            channel_id = channelId,
            data = { 
                content = ("0 " .. typeof(lazyresp)) :: string?
            }
        }))
      end 
      
    if msg.content == "AC" then
        stdout = {} 
    end    
end)    

local resp = nil; -- To use later
onStartup(evt, function()
    local pagesExt = require"@antiraid-ext/pages"
    local executor = require"@antiraid-ext/executor".NewGlobalExecutor(ctx)
    executor.pages:set({
        title = "Welcome Staff!",
        description = "This is a test page!",
        settings = array.toArray({
            {
                id = "test",
                name = "Test",
                description = "This is a test setting!",
                primary_key = "test",
                title_template = "Test",
                columns = array.toArray({
                    {
                        id = "test",
                        name = "Test",
                        description = "This is a test column!",
                        nullable = false,
                        suggestions = pagesExt.staticSuggestions({"testA", "testB"}),
                        secret = true,
                        column_type = pagesExt.stringColumnType("Scalar", 0, nil, {"testA", "testB"}, "textarea"),
                        ignored_for = pagesExt.ignoredFor({}),
                    },
                }),
                supported_operations = pagesExt.supportedOperations(true, true, true, true),
            },
        })
    })
end)

return resp