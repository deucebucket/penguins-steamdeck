//---------------------------------------------------------------------------------------------
/*
	main.js

	Copyright (C) 2006 WildTangent, Inc. 
	All Rights Reserved

	Mike Sorice
	6/21/2006
*/
//---------------------------------------------------------------------------------------------

var _dpName = window.external.GetDPCodeName;
var _orderItemId = window.external.GetProductCodeName;
var _sku = window.external.GetSKU;
var _version = "2.0";

var _canUseWildCoins = window.external.GetCanUseWildCoins;
var _isPurchaseable = window.external.GetIsPurchaseable;
var _isOwned = window.external.GetIsOwned;
var _displayAds = window.external.GetDisplayAds;

// --------------------------------------------------------------------
// Redirector
// --------------------------------------------------------------------
function OpenRedirector( pageName )
{
	var url = "http://rdr.wildtangent.com/wire/" + pageName + "?dp=" + _dpName + "&itemName=" + _orderItemId;
	window.open(url);
}

function OpenRedirectorWire2( pageName )
{
	var url = "http://rdr.wildtangent.com/wire2/" + pageName + "?dp=" + _dpName + "&itemName=" + _orderItemId;
	window.open(url);
}

function ResolutionCheck()
{
	if ( window.external.GetScreenWidth == 800 ) {
		window.external.SetClientSize( 792, 545 );
		document.body.scroll = "yes";
	}
	else {
		window.external.SetClientSize(969, 654);
	}
}

function CancelEvent()
{ 
	window.event.returnValue = false; 
}
