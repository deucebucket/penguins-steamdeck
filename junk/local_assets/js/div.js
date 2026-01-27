// --------------------------------------------------------------------
// Hides a DIV tag.
// --------------------------------------------------------------------
function HideDiv( divId )
{
	document.getElementById(divId).style.visibility = "hidden";
	document.getElementById(divId).style.display = "none";
}


// --------------------------------------------------------------------
// Shows a DIV tag.
// --------------------------------------------------------------------
function ShowDiv( divId )
{
	document.getElementById(divId).style.visibility = "visible";
	document.getElementById(divId).style.display = "block";
}