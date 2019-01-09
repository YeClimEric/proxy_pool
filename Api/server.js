"use strict";
const app = require( "express" )();
// const cluster = require( 'cluster' );
const querystring = require( "querystring" );
const redis = require( "redis" ).createClient( {
    host: "127.0.0.1"
} );

redis.on( 'connect', () => {
    console.log( 'redis connect success' );
} );

redis.on( 'error', () => {
    console.log( 'redis connect error' );
} );

const sourceHashKey = "useful_proxy";
const rawListKey = "raw_proxy";

//缓存数据
let usefulDataCache = [];
let rawDataCache = 0;

function choice( list ) {
    try {
        let index = Math.floor( Math.random() * list.length );
        return list[ index ];

    } catch ( e ) {
        return null;
    }
}

//定时刷新数据，请求直接获取缓存数据
( function refreshData() {
    setInterval( () => {
        redis.HGETALL( sourceHashKey, ( err, res ) => {
            console.log( res );
            usefulDataCache = [];
            if ( res ) {
                for ( var key in res ) {
                    usefulDataCache.push( key );
                }
            }
        } );

        redis.LLEN( rawListKey, ( err, res ) => {
            rawDataCache = res || 0;
        } )
    }, 5 * 1000 );
} )()

app.all( "/", ( req, res ) => {
    res.writeHead( 200, {
        'Content-Type': 'text/json'
    } );

    res.end( JSON.stringify( {
        "delete?proxy=127.0.0.1:8080": "delete an unable proxy",
        "get": "get an usable proxy",
        "get_all": "get all proxy from proxy pool",
        "get_status": "proxy statistics"
    } ) );
} )

app.get( "/get", ( req, res ) => {
    let p = choice( usefulDataCache );
    if ( !p ) {
        p = "no proxy";
    }

    res.end( p );
} );

app.get( "/get_all", ( req, res ) => {
    res.end( JSON.stringify( usefulDataCache ) );
} );

app.get( "/get_status", ( req, res ) => {
    res.end( JSON.stringify( {
        raw_proxy: rawDataCache,
        useful_proxy: usefulDataCache.length
    } ) );
} );

app.get( "/delete", ( req, res ) => {
    let proxy = req.query[ 'proxy' ];
    redis.HDEL( sourceHashKey, proxy, ( err, res ) => {} );
} )

app.listen( 5010, () => {
    console.log( "server start." );
} );
