//---------------------------------------------------------------------------------------------
/*
	queryString.js

	Copyright (C) 2006 WildTangent, Inc. 
	All Rights Reserved

	Mike Sorice
	6/21/2006
*/
//---------------------------------------------------------------------------------------------

// --------------------------------------------------------------------
// Returns an object that contains URL parameter names and values.
// Accessed in the following manner:
//		Query string:		?value=5
//		Accessed with:		var urlValues = ReadURLParams();
//							urlValues.value (contains 5)
//
// Dependencies:
//		parseQueryString(queryString)
//
// Returns "" if no query string is present
// --------------------------------------------------------------------
function ReadURLParams()
{
	var URL = window.location.toString();
	if ( URL.indexOf('?') > 0 ) {
		var queryString = URL.substring(URL.indexOf('?')+1, URL.length);
		queryString = queryString.replace(';','&');
		queryString = queryString.replace(';','');
		var tempObject = parseQueryString(queryString);
		return tempObject;
	}
	else {
		return "";
	}
}

// --------------------------------------------------------------------
// Parses the query string and returns an object containing values.
// Generally not called directly by page code.  See ReadURLParams().
// --------------------------------------------------------------------
function parseQueryString(queryString)
{
	var queryObject = new Object();
	queryString = queryString.replace(/^.*\?(.+)$/,'$1');
	
	while ( (pair = queryString.match(/([^=]+)=\'?([^\&\']*)\'?\&?/)) && pair[0].length )	{
		
		queryString = queryString.substring( pair[0].length );

		if ( /^\-?\d+$/.test(pair[2]) ) {
			pair[2] = parseInt(pair[2]);
		}

		queryObject[pair[1]] = pair[2];
	}

	return queryObject;
}