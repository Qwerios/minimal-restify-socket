moment                  = require "moment"
Q                       = require "q"
datetimeResponseModel   = require "../../models/datetimeResponse"

module.exports = ( server, swagger, logger, implementations ) ->

    # Create the call implementation code
    #
    implementations.datetime = () ->
        deferred = Q.defer()

        logger.info( "[API] Requested server time" )

        # Get date time can't really fail
        #
        now = moment()
        deferred.resolve(
            datetime:       now.format( "X" )
            formatted:      now.format( "YYYY-MM-DDTHH:mm:ssZ" )
        )

        return deferred.promise

    # Setup the server route
    #
    server.get(
        url:                            "/datetime"
        swagger:
            summary:                    "Retrieves the current server time"
            notes:                      "The server time is used for all time registration purposes and should be trusted over the client time."
            nickname:                   "serverDatetime"
            consumes:                   [ "application/json" ]
            produces:                   [ "application/json" ]
            responseMessages: [
                code:                   200
                message:                "Success"
                responseModel:          "datetimeResponse"
            ]

        validation:                     {}
        models:                         datetimeResponseModel
    ,
        ( request, response, next ) =>
            implementations.datetime()
            .then( ( data ) ->
                response.send( 200, data )
            ,   ( error ) ->
                response.send( error.code or 500, error.message or error )
            )
    )