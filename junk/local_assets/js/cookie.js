// --------------------------------------------------------------------
// Sets a cookie in the user's browser
//
// Parameters:
//		name		Name of the cookie
//		value		Value of the cookie
//		[expires]	Expiration date of the cookie (expires at end of 
//					session by default)
//		[path]		Path where the cookie may be accessed (path of calling 
//					document by default)
//		[domain]	Domain where the cookie may be accessed (domain of 
//					calling document by default)
//		[secure]	Boolean indicating if cookie requires secure connection
// --------------------------------------------------------------------
function SetCookie(name, value, expires, path, domain, secure)
{
    document.cookie = name + "=" + escape(value) +
        ((expires) ? "; expires=" + expires.toUTCString() : "") +
        ((path) ? "; path=" + path : "") +
        ((domain) ? "; domain=" + domain : "") +
        ((secure) ? "; secure" : "");
}


// --------------------------------------------------------------------
// Gets the value of the cookie
//
// Parameters:
//		name	Name of the cookie
//
// Returns a string containing the value of the cookie, or null if
// cookie does not exist in user's browser
// --------------------------------------------------------------------
function GetCookie(name)
{
    var dc = document.cookie;
    var prefix = name + "=";
    var begin = dc.indexOf("; " + prefix);
    
    if ( begin == -1 ) {
        begin = dc.indexOf(prefix);
        if (begin != 0) {
			return "";
		}
    }
    else {
        begin += 2;
    }
    
    var end = document.cookie.indexOf(";", begin);
    
    if ( end == -1 ) {
        end = dc.length;
    }
    
    return unescape(dc.substring(begin + prefix.length, end));
}


// --------------------------------------------------------------------
// Deletes a cookie from the user's browser
//
// Parameters:
//		name		Name of the cookie
//		[path]		Path of the cookie
//		[domain]	Domain of the cookie
// --------------------------------------------------------------------
function DeleteCookie(name, path, domain)
{
    if ( GetCookie(name) ) {
        document.cookie = name + "=" +
            ((path) ? "; path=" + path : "") +
            ((domain) ? "; domain=" + domain : "") +
            "; expires=Sun, 01-Jan-06 00:00:01 GMT";
    }
}