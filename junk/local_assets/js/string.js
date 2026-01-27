//---------------------------------------------------------------------------------------------
/*
	string.js

	Copyright (C) 2006 WildTangent, Inc. 
	All Rights Reserved

	Mike Sorice
	6/21/2006
*/
//---------------------------------------------------------------------------------------------

// --------------------------------------------------------------------
// Returns the value of the string as a number
// 
// EXTENDS JS String Object
//
// Useful for cookie values which are generally treated as strings, 
// i.e. 2 is greater than 10 unless you use this function.
//
// Returns a number value
// --------------------------------------------------------------------
String.prototype.toInt = function()
{
    var returnNum = 0;
    
    for (var i = 0; i < this.length; i++) {
        returnNum = returnNum + ((this.charCodeAt(i) - 48)*Math.pow(10,this.length - 1 - i));
    }

    return returnNum;
}

// --------------------------------------------------------------------
// Converts the string to a Boolean
//
// EXTENDS JS String Object
//
// Returns true if the string equals (not case-sensitive), otherwise false:
//		"true"
//		"1"
//		"yes"
// --------------------------------------------------------------------
String.prototype.toBool = function()
{
    if ( this.toLower() == "true" || this == "1" || this.toLower() == "yes" ) {
		return true;
    }
    else {
		return false;
    }
}