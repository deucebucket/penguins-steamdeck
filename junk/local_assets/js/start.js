//---------------------------------------------------------------------------------------------
/*
	start.js
*/
//---------------------------------------------------------------------------------------------

// resolution check
var urlParams = ReadURLParams();

var _gameCostString = "$19.95";
var _gameDisplayName = "Penguins!";
var _gameDescription = "Visit the most adorable animals in the zoo any time of the day or night! Join 'Ace' the penguin, on his escape through&#160;80+ levels of penguin-puzzle fun! Ace and fellow penguin friends need your help to elude zoo keepers by using their 'cool' gadgets to continue through 8 different zoo zones! Visit the gift shop to buy your penguins new outfits or pick up a hot new soundtrack and thaw that frigid air! Track your progress with zoo maps and play on into any season of the year. You can even download penguin soundtracks, wallpaper, and gorgeous story art. This kind of fun is all-year-round ... for everyone in the clan!";

var _location = "start";
var _isSponsored = false;
var _sponsorCampaign = "";
var _sponsorName = "";
var _sponsorCode = "";
var _sponsorUrl = "";
var _isTimedOut = true;
var _onlineCheck = false;
var _swapSponsorCoin = false;
var _onlineCheckAction = "";
var _isInterstitialScheduled = false;
var _interstitialUrl = "http://www.wildgames.com/ecs/htdocs/wire/Interstitial.aspx";
var _sponsorInterstitialUrl = "";
var _isRightFrameRedirected = false;

var _isPlayClicked = false;
var _isOfflinePlayClicked = false;
var _doorsOpened = false;
 
// auto login if credentials are in memory
if ( ( window.external.Get( "email" ) != "" ) ) {
	window.external.SubmitLogin( window.external.Get( "email" ), window.external.Get( "password" ), true, "LoginComplete" );
	window.external.ClearValues();
}

//---------------------------------------------------------------------------------------------
function Initialize()
{
	window.onClose = function(){ window.external.ExitProcess() };
	
	ResolutionCheck();
	
	// block tab key
	document.getElementById( "tabBlockInput" ).focus();
	
	// set text
	document.getElementById( "gameText" ).innerHTML = "<span class=\"white\"><span class=\"toolTipTitle\">" + _gameDisplayName + "</span><br /><br />" + _gameDescription + "</span>";
	window.external.Set( "gameDisplayName", _gameDisplayName );
	
	// required for game info scrolling
	scrollingSetup();
	
	// set initial session cost
	SetWildCoinCostDisplay( window.external.GetWildCoinSessionCost );

	//set up right frame content
	window.frames.content_right_iframe.ShowDiv( "contentTrial" );
	
	if ( window.external.IsOnline ) {
		setTimeout( "LoadingTimeout()", 6000 );
		setTimeout( "document.getElementById( \"configFrame\" ).src = \"http://wire2.wildgames.com/config.aspx?dpName=" + _dpName + "&orderItemId=" + _orderItemId + "&location=" + _location + "&sku=" + _sku + "&version=" + _version + "\";", 300 );
	}
	else {
		setTimeout( "LoadingTimeout()", 1000 );
	}
	
	// set leaderboard links
	document.getElementById( "leaderboardLink" ).href = "http://wildboards.wildtangent.com/communities/" + _dpName + "/highscores.aspx?g=" + _orderItemId;
	
	// if logged in, display welcome message
	SetLoginDisplay();
	
	// hide trials, show WildCoins if no trials remain
	if ( !_isOwned && ( window.external.GetTrialSessionLeft < 1 ) )	{
		window.frames.content_right_iframe.HideAllContent();
		
		if ( _canUseWildCoins ) {
			if ( !window.external.IsLoggedIn ) {
				window.frames.content_right_iframe.ShowDiv( "contentWildCoins" );
			}
			else {
				if ( ( window.external.GetOfflineWildCoins >= window.external.GetWildCoinSessionCost ) && ( !window.external.IsOnline ) ) {
					ShowDiv( "using_local_coins" );
					document.getElementById( "using_local_coins" ).innerHTML = "You are currently offline. Using local WildCoins to play.  You currently have <b>" + window.external.GetOfflineWildCoins + "</b>.";
				}
				window.frames.content_right_iframe.ShowDiv( "contentWildCoinsSignedIn" );
			}
			HideDiv( "playTrial" );
			HideDiv( "sessionsRemaining" );
			ShowDiv( "playTokensDiv" );
			HideDiv( "quickPlay" );
			ShowDiv( "sessionCost2" );
			ShowDiv( "quickPlayPh" );
			ShowDiv( "exit_button" );
			HideDiv( "sessionCost" );
			HideDiv( "sessionCostShadow" );
		}
	}
	
	// display logic
	if ( document.getElementById( "playTrial" ).style.visibility == "visible" ) {
		HideDiv( "playTokensDiv" );
		HideDiv( "playSponsored" );
	}
	
	if ( document.getElementById( "playTokensDiv" ).style.visibility == "visible" ) {
		HideDiv( "playTrial" );
		HideDiv( "playSponsored" );
	}
	
	if ( document.getElementById( "playSponsored" ).style.visibility == "visible" ) {
		HideDiv( "playTrial" );
		HideDiv( "playTokensDiv" );
	}
	
	// if owned, hide token options, allow users to play directly
	if ( _isOwned )	{
		window.frames.content_right_iframe.HideAllContent();
		HideDiv( "playTokensDiv" );
		HideDiv( "playTrial" );
		HideDiv( "playSponsored" );
		HideDiv( "sessionCost" );
		HideDiv( "sessionCostShadow" );
		HideDiv( "sessionCost2" );
		HideDiv( "sessionsRemaining" );
		HideDiv( "quickPlay" );
		HideDiv( "quickPlayPh" );
		ShowDiv( "exit_button" );
		HideDiv( "config_banner" );
		ShowDiv( "offline_banner" );
		ShowDiv( "playOwned" );
		CenterInterface();
	}
	else if ( !_canUseWildCoins ) { 
		HideDiv( "quickPlay" );
		HideDiv( "sessionCost" );
		HideDiv( "sessionCostShadow" );
		HideDiv( "quickPlayPh" );
		ShowDiv( "exit_button" );
		ShowDiv( "playNoWildCoins" );
		HideDiv( "playTokensDiv" );
		HideDiv( "playTrial" );
		HideDiv( "playSponsored" );
		HideDiv( "playFree" );
		if ( !_isPurchaseable ) { // free game
			window.frames.content_right_iframe.HideAllContent();
			HideDiv( "playTokensDiv" );
			HideDiv( "playTrial" );
			HideDiv( "playSponsored" );
			HideDiv( "sessionCost" );
			HideDiv( "sessionCostShadow" );
			HideDiv( "sessionCost2" );
			HideDiv( "sessionsRemaining" );
			HideDiv( "quickPlay" );
			HideDiv( "quickPlayPh" );
			HideDiv( "config_banner" );
			ShowDiv( "offline_banner" );
			HideDiv( "playNoWildCoins" );
			ShowDiv( "playFree" );
			ShowDiv( "exit_button" );
			CenterInterface();
		}
	}
	
	if ( !_displayAds ) {
		HideDiv( "config_banner" );
		HideDiv( "offline_banner" );
	}
	
	// free license type logic
	if ( window.external.GetLicenseType == 7 && !_isOwned ) {
		HideDiv( "playTokensDiv" );
		HideDiv( "playSponsored" );
		HideDiv( "config_banner" );
		HideDiv( "playNoWildCoins" );
		HideDiv( "playFree" );
		ShowDiv( "playTrial" );
		HideDiv( "quickPlay" );
		ShowDiv( "quickPlayPh" );
		ShowDiv( "exit_button" );
		HideDiv( "sessionCost" );
		HideDiv( "sessionCostShadow" );
	}
	
	// pre-load online assets
	var loadImg_1 = new Image();
	loadImg_1.src = "http://www.wildgames.com/ecs/htdocs/wire/img/wire2_content_bg.jpg";
	
	var loadImg_2 = new Image();
	loadImg_2.src = "http://www.wildgames.com/ecs/htdocs/wire/img/WIRE_brand.jpg";
	
	var loadImg_3 = new Image();
	loadImg_3.src = "http://www.wildgames.com/ecs/htdocs/wire/img/wire2_footer.jpg";
}

//---------------------------------------------------------------------------------------------
// Protector interface
//---------------------------------------------------------------------------------------------
function LoginComplete( errorType, errorCode, errorMsg )
{

}

function RedirectPage( url )
{
	window.location = url;
}

//---------------------------------------------------------------------------------------------
function SetWildCoinCostDisplay( coinCost )
{
	var wildCoinsText = "INSERT";
	var costText = "x" + coinCost;
	
	document.getElementById( "sessionCost" ).innerHTML = costText;
	document.getElementById( "sessionCostShadow" ).innerHTML = costText;
	document.getElementById( "sessionCost2" ).innerHTML = costText;
}

//---------------------------------------------------------------------------------------------
function SetGameCostDisplay( gameCost )
{
	_gameCostString = gameCost;
}

//---------------------------------------------------------------------------------------------
function SetInterstitialUrl( interstitialUrl )
{
	_interstitialUrl = interstitialUrl;
	ActivateInterstitial();
}

//---------------------------------------------------------------------------------------------
function SetSponsor( sponsorName, sponsorCampaign, sponsorCode, sponsorImageUrl, coinImageUrl, sponsorInterstitialUrl, sponsorCount )
{
	var cookieDate = new Date();
	cookieDate.setYear( cookieDate.getYear() + 1 );
	
	var configureSponsor = true;
	
	var sessionsPlayed = GetCookie( sponsorCampaign + "_" + window.external.GetProductCodeName );
	if ( sessionsPlayed == "" ) {
		sessionsPlayed = 0;
		SetCookie( sponsorCampaign + "_" + window.external.GetProductCodeName, sessionsPlayed, cookieDate );
	}
	
	if ( ( sessionsPlayed >= sponsorCount ) || ( !_canUseWildCoins ) || ( _isOwned ) ) {
		configureSponsor = false;
	}
	
	if ( configureSponsor ) {
		// set values
		_isSponsored = true;
		_sponsorName = sponsorName;
		_sponsorCampaign = sponsorCampaign;
		_sponsorCode = sponsorCode;
		_sponsorUrl = coinImageUrl;
		_sponsorInterstitialUrl = sponsorInterstitialUrl;
		
		// show sponsored session
		window.frames.content_right_iframe.HideAllContent();
		window.frames.content_right_iframe.ShowDiv( "contentSponsored" );
		window.frames.content_right_iframe.ChangeImage( "sponsorImage", sponsorImageUrl );
		if ( coinImageUrl != "" ) {
			document.getElementById( "sponsorCoinAnim" ).src = coinImageUrl;
			_swapSponsorCoin = true;
		}
		HideDiv( "playTokensDiv" );
		HideDiv( "sessionCost2" );
		HideDiv( "playTrial" );
		HideDiv( "playNoWildCoins" );
		HideDiv( "playFree" );
		ShowDiv( "playSponsored" );
		ShowDiv( "quickPlay" );
		HideDiv( "quickPlayPh" );
		HideDiv( "exit_button" );
		HideDiv( "exit_button" );
		HideDiv( "sessionCost2" );
		ShowDiv( "sessionCost" );
		ShowDiv( "sessionCostShadow" );
	}
}

//---------------------------------------------------------------------------------------------
function EnableUpdate( updateAction, updateUrl )
{
	EnableUpdateButton();
	switch ( updateAction )
	{
		case "browserUrl":
		{
			document.getElementById( "updateActionHref" ).href = updateUrl;
			document.getElementById( "updateActionHref" ).target = "_blank";
			break;
		}
		case "fileDownload":
		{
			document.getElementById( "updateActionHref" ).href = "javascript:window.external.DownloadFile( '" + updateUrl + "', '' )";
			break;
		}
		case "internalNavigate":
		{
			document.getElementById( "updateActionHref" ).href = "javascript:window.location = '" + updateUrl + "'";
			break;
		}
		default:	break;
	}
}

//---------------------------------------------------------------------------------------------
function EnableUpdateButton()
{
	ShowDiv( "updateButton" );
}

//---------------------------------------------------------------------------------------------
function SetRightFrameUrl( url )
{
	_isRightFrameRedirected = true;
	window.frames.content_right_iframe.RedirectRightPage( url );
}

//---------------------------------------------------------------------------------------------
// End protector interface
//---------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------
// OAS Interface
//---------------------------------------------------------------------------------------------
function ActivateInterstitial()
{
	_isInterstitialScheduled = true;
}

//---------------------------------------------------------------------------------------------
function ResetRightFrame()
{
	if (!_isRightFrameRedirected) {
		window.frames.content_right_iframe.RefreshState();
	}
}

//---------------------------------------------------------------------------------------------
function ResetTabFocus()
{
	try {
		document.getElementById('tabBlockInput').focus();
	}
	catch(e) {
		return false;
	}
}

//---------------------------------------------------------------------------------------------
function PlayOutOfTrialsNoWildCoins()
{
	window.location = "going_online.html?url=http://www.wildgames.com/ecs/htdocs/wire/OutOfPlay.aspx&alt=start_no_trials.html";
}

//---------------------------------------------------------------------------------------------
function CloseLocalWildCoinsPopup()
{
	_isPlayClicked = false;
	
	if ( window.external.IsOnline ) {
		ShowDiv( "config_banner" );
	}
	
	HideDiv( "screen_blackout" );
	HideDiv( "local_wildcoin_firewall" );
	HideDiv( "local_wildcoin_out" );
	HideDiv( "local_balance_and_cost" );
}

//---------------------------------------------------------------------------------------------
function CenterInterface()
{
	document.getElementById( "mainPanel" ).style.left = "240px";
	document.getElementById( "tooltip_gameinfo_bg" ).style.left = "263px";
	document.getElementById( "tooltip_gameinfo" ).style.left = "268px";
	document.getElementById( "gameInfoCover" ).style.left = "268px";
	document.getElementById( "tooltip_leaderboards_bg" ).style.left = "357px";
	document.getElementById( "tooltip_leaderboards" ).style.left = "357px";
	document.getElementById( "tooltip_community_bg" ).style.left = "470px";
	document.getElementById( "tooltip_community" ).style.left = "470px";
	document.getElementById( "exit_button" ).style.left = "565px";
}

//---------------------------------------------------------------------------------------------
function SetLoginDisplay()
{
	var displayName = "";
	if ( window.external.GetFirstName != "" ) {
		displayName = window.external.GetFirstName;
	}
	else if ( window.external.GetDisplayName != "" ) {
		displayName = window.external.GetDisplayName;
	}
	else if ( window.external.GetAccountName != "" ) {
		displayName = window.external.GetAccountName;
	}
	
	if ( window.external.IsLoggedIn ) {
		document.getElementById( "signedIn" ).innerHTML = "<b>Hello, " + displayName + "</b><br />(<a href=\"javascript:window.external.Logout();SetLoginDisplay();ResetRightFrame();\" class=\"welcomeTextSm\">Log out</a>)";
		
		HideDiv( "notSignedIn" );
		ShowDiv( "signedIn" );

	} else {
		ShowDiv( "notSignedIn" );
		HideDiv( "signedIn" );
	}
}

//---------------------------------------------------------------------------------------------
function PlayTrial()
{
	//set play type
	window.external.Set( "playType", "trial" );
	
	if ( _isPlayClicked == false) {
		_isPlayClicked = true;
		
		document.getElementById( "tokenSlotImgTrial" ).src = "local_assets/img/wire2_home_token_demo_anim.gif";
		setTimeout("document.coinSound.Play();", 1500);

		if ( _isInterstitialScheduled && _displayAds && window.external.IsOnline ) {
			setTimeout( "window.location = \"" +_interstitialUrl + "\"", 3200 );
		}
		else {
			setTimeout( "PlayTrialCheck()", 3200 );
		}
	}
}

//---------------------------------------------------------------------------------------------
function PlayTrialCheck()
{
	var trialCode = window.external.PlayGame();

	if ( trialCode != "success" ) {
		window.location = "error.html?errorcode=WIRE_trialerror";
	}			
}

//---------------------------------------------------------------------------------------------
function PlaySponsored()
{
	//set play type
	window.external.Set( "playType", "sponsored" );
	window.external.Set( "sponsorName", _sponsorName  );
	
	if ( !_isPlayClicked ) {
		_isPlayClicked = true;

		if ( window.external.IsOnline ) {
			window.external.Set( "sponsorCode", _sponsorCode );
			OnlineCheck( "sponsoredSession" );
		}
		else {
			ShowDiv( "firewall_warning_bg" );
			ShowDiv( "offline_warning" );
		}
	}
}

//---------------------------------------------------------------------------------------------
function PlayOwnedGame()
{
	window.external.PlayGame();
}

//---------------------------------------------------------------------------------------------
function PlayFree()
{
	if ( _isInterstitialScheduled && window.external.IsOnline ) {
		window.location = "going_online.html?url=" + _interstitialUrl;
	}
	else {
		window.external.PlayGame();
	}
}

function PlayWithOfflineCoins()
{
	if ( !_isOfflinePlayClicked ) {
		_isOfflinePlayClicked = true;
		window.external.SubmitOfflineWildCoins();
		SubmitWildCoinsComplete( "success" , "" , "" );
	}
}

function PlayWithOfflineCoinsFast()
{
	if ( !_isOfflinePlayClicked ) {
		_isOfflinePlayClicked = true;
		window.external.SubmitOfflineWildCoins();
		window.external.PlayGame();
	}
}

//---------------------------------------------------------------------------------------------
function SubmitWildCoins()
{
	if ( _isPlayClicked == false ) {
		_isPlayClicked = true;
		if ( window.external.IsLoggedIn ) {
			if ( window.external.IsOnline ) {
				window.external.SubmitWildCoins( "transient_unlock", "SubmitWildCoinsComplete" );
				OnlineCheck( "wildcoin_submission" );
			}
			else {
				if ( window.external.GetOfflineWildCoins >= window.external.GetWildCoinSessionCost ) {
					HideDiv( "config_banner" );
					ShowDiv( "screen_blackout" );
					ShowDiv( "local_wildcoin_firewall" );
					ShowDiv( "local_balance_and_cost" );
					document.getElementById( "local_balance_and_cost" ).innerHTML = "Your Local Balance: <b>" + window.external.GetOfflineWildCoins + "</b>&nbsp;&nbsp;&nbsp;&nbsp;Local WildCoin Cost: <b>" + window.external.GetWildCoinSessionCost + "</b>";
				}
				else {
					window.location = "going_online.html?url=http://www.wildgames.com/ecs/htdocs/wire/navigate.aspx&nextUrl=start.html&nextUrlType=offline";
				}
			}
		}
		else {
			if ( window.external.GetTrialSessionLeft < 1 ) {
				if ( window.external.IsOnline ) {
					window.location = "going_online.html?url=http://www.wildgames.com/ecs/htdocs/wire/OutOfPlay.aspx&alt=start_no_trials.html";
				}
				else {
					window.location = "going_online.html?url=http://www.wildgames.com/ecs/htdocs/wire/Navigate.aspx&nextUrl=start.html&nextUrlType=offline";
				}
			}
			else {
				NagivateToLogin();
			}
		}
	}
}

//---------------------------------------------------------------------------------------------
function SubmitWildCoinsComplete( errorType, errorCode, errorMsg )
{
	if ( errorType == "success" ) {
		//set play type
		window.external.Set( "playType", "wildcoins" );
		//block all UI elements
		ShowDiv( "UI_block" );
		ShowDiv( "sessionCost2" );
		document.getElementById( "tokenSlotImgTrial" ).src = "local_assets/img/wire2_home_token_usertoken_anim.gif";
		document.getElementById( "tokenSlotImg" ).src = "local_assets/img/wire2_home_token_usertoken_anim.gif";
		document.getElementById( "sponsorCoinAnim" ).src = "local_assets/img/wire2_home_token_usertoken_anim.gif";
		document.getElementById( "sponsorCoinAnim" ).src = "local_assets/img/wire2_home_token_usertoken_anim.gif";
		setTimeout( "document.coinSound.Play();", 1500 );
		setTimeout( "window.external.PlayGame()", 3200 );
	}
	else {
		
		_isPlayClicked = false;
		
		if ( errorType == "http" ) {
			document.getElementById( "feedback" ).innerHTML = "We have encountered a problem. You may need to go online.  Please try again.";
			if ( window.external.GetOfflineWildCoins >= window.external.GetWildCoinSessionCost ) {
				HideDiv( "config_banner" );
				ShowDiv( "screen_blackout" );
				ShowDiv( "local_wildcoin_firewall" );
				ShowDiv( "local_balance_and_cost" );
				document.getElementById( "local_balance_and_cost" ).innerHTML = "Your Local Balance: <b>" + window.external.GetOfflineWildCoins + "</b>&nbsp;&nbsp;&nbsp;&nbsp;WildCoin Session Cost: <b>" + window.external.GetWildCoinSessionCost + "</b>";
			}
		}
		else if ( errorType == "client" ) {
			document.getElementById( "feedback" ).innerHTML = "We have encountered a WildCoin server error. Please try again later.";
			if ( window.external.GetOfflineWildCoins >= window.external.GetWildCoinSessionCost ) {
				HideDiv( "config_banner" );
				ShowDiv( "screen_blackout" );
				ShowDiv( "local_wildcoin_firewall" );
				ShowDiv( "local_balance_and_cost" );
				document.getElementById( "local_balance_and_cost" ).innerHTML = "Your Local Balance: <b>" + window.external.GetOfflineWildCoins + "</b>&nbsp;&nbsp;&nbsp;&nbsp;WildCoin Session Cost: <b>" + window.external.GetWildCoinSessionCost + "</b>";
			}
		}
		else if ( errorType == "server" ) {
			if (errorCode.indexOf("client.token.insufficient_funds") != -1) {
					if ( window.external.GetOfflineWildCoins >= window.external.GetWildCoinSessionCost ) {
						HideDiv( "config_banner" );
						ShowDiv( "screen_blackout" );
						ShowDiv( "local_wildcoin_out" );
						ShowDiv( "local_balance_and_cost" );
						document.getElementById( "local_balance_and_cost" ).innerHTML = "Your Local Balance: <b>" + window.external.GetOfflineWildCoins + "</b>&nbsp;&nbsp;&nbsp;&nbsp;Local WildCoin Cost: <b>" + window.external.GetWildCoinSessionCost + "</b>";
					}
					else {
						if ( window.external.IsOnline ) {
							window.location = "going_online.html?url=http://www.wildgames.com/ecs/htdocs/wire/OutOfPlay.aspx&alt=start_no_trials.html";
						}
						else {
							window.location = "going_online.html?url=http://www.wildgames.com/ecs/htdocs/wire/OutOfPlay.aspx";
						}
					}			
			} else if (errorCode.indexOf("client.req_invalid") != -1) {
					if ( window.external.IsOnline ) {
						window.location = "going_online.html?url=http://www.wildgames.com/ecs/htdocs/wire/OutOfPlay.aspx&alt=start_no_trials.html";
					}
					else {
						window.location = "start_no_trials.html";
					}
			} else {
				document.getElementById( "feedback" ).innerHTML = "We have encountered a problem. <a href=\"javascript:NavigateMyAccount();\">Click here to access your account</a>.";
			}
		}
	}
}

//---------------------------------------------------------------------------------------------
function QuickPlay()
{
	if ( window.external.IsLoggedIn ) {
		SubmitWildCoins();
	}
	else {
		window.location = "going_online.html?url=http://www.wildgames.com/ecs/htdocs/wire/HowItWorks.aspx&backUrl=start.html&backUrlType=offline";
	}
}

//---------------------------------------------------------------------------------------------
function LoadingComplete()
{
	_isTimedOut = false;
	if ( !_doorsOpened ) {
		setTimeout( "document.doorSound.Play()", 80 );
	}
	HideDiv( "firewall_warning" );
	HideDiv( "firewall_warning_bg" );
	
	setTimeout( "OpenDoors()", 350 );
}

//---------------------------------------------------------------------------------------------
function LoadingTimeout()
{
	if ( _isTimedOut && window.external.IsOnline ) {
		// display firewall notifications
		ShowDiv( "firewall_warning" );
		ShowDiv( "firewall_warning_bg" );
		if ( !_doorsOpened ) {
			setTimeout( "document.doorSound.Play()", 80 );
		}
	}
	else if ( _isTimedOut ) {
		ShowDiv( "offline_banner" );
		ShowDiv( "firewall_warning_bg" );
		if ( !_doorsOpened ) {
			setTimeout( "document.doorSound.Play()", 80 );
		}
	}
	
	setTimeout( "OpenDoors()", 350 );
}

//---------------------------------------------------------------------------------------------
function CommunicationSuccessful()
{
	_onlineCheck = true;
}

function StartSponsoredSession()
{
	var cookieDate = new Date();
	cookieDate.setYear( cookieDate.getYear() + 1 );
	var sessionsPlayed = GetCookie( _sponsorCampaign + "_" + window.external.GetProductCodeName );
	sessionsPlayed++;
	SetCookie( _sponsorCampaign + "_" + window.external.GetProductCodeName, sessionsPlayed, cookieDate );
	window.location =  "going_online.html?url=" + _sponsorInterstitialUrl + "&sponsorOnlineError=1";
}

//---------------------------------------------------------------------------------------------
function CommunicationTimeout()
{
	if ( _onlineCheckAction == "sponsoredSession" && _onlineCheck == false ) {
		window.location = "error.html?errorcode=WIRE_sponsorErrorOffline";
	}
	else if ( _onlineCheck == false ) {
		if ( _onlineCheckAction == "wildcoin_submission" ) {
			if ( window.external.GetOfflineWildCoins >= window.external.GetWildCoinSessionCost ) {
				HideDiv( "config_banner" );
				ShowDiv( "screen_blackout" );
				ShowDiv( "local_wildcoin_firewall" );
				ShowDiv( "local_balance_and_cost" );
				document.getElementById( "local_balance_and_cost" ).innerHTML = "Your Local Balance: <b>" + window.external.GetOfflineWildCoins + "</b>&nbsp;&nbsp;&nbsp;&nbsp;Local WildCoin Cost: <b>" + window.external.GetWildCoinSessionCost + "</b>";
			}
			ShowDiv( "firewall_warning" );
			ShowDiv( "firewall_warning_bg" );
		}
		else {
			ShowDiv( "firewall_warning" );
			ShowDiv( "firewall_warning_bg" );
		}
	}
}

//---------------------------------------------------------------------------------------------
function OnlineCheck( onlineCheckAction )
{
	_onlineCheck = false;
	_onlineCheckAction = onlineCheckAction;
	
	if ( _onlineCheckAction == "sponsoredSession" ) {
		var coinElement = document.getElementById( "sponsorCoinAnim" );
		coinElement.src = coinElement.src.replace( ".gif", "_anim.gif" );
		setTimeout( "document.coinSound.Play();", 1500 );
		setTimeout( "StartSponsoredSession()", 3200 );
	}
	else {
		document.getElementById( "onlineCheck" ).src = "";
		document.getElementById( "onlineCheck" ).src = "http://wire2.wildgames.com/online_test.html";
		setTimeout( "CommunicationTimeout()", 6000 );
	}
}

//---------------------------------------------------------------------------------------------
function NavigateMyAccount()
{
	if ( window.external.IsLoggedIn ) {
		window.location = "going_online.html?url=http://www.wildgames.com/ecs/htdocs/wire/MyAccount.aspx";
	}
	else {
		window.location = "going_online.html?url=http://www.wildgames.com/ecs/htdocs/wire/LoginRegister.aspx&nextUrl=MyAccount.aspx&nextUrlType=online";
	}
}

//---------------------------------------------------------------------------------------------
function NavigateLogin()
{
	if ( window.external.IsOnline ) {
		window.location = "going_online.html?url=http://www.wildgames.com/ecs/htdocs/wire/LoginRegister.aspx&nextUrl=start.html&nextUrlType=offline&alt=login.html";
	}
	else {
		window.location = "login.html";
	}
}

function NavigateOnlineNew( address )
{
	window.open( address + "?dp=" + window.external.GetDPCodeName, "new", "" );
}

//---------------------------------------------------------------------------------------------
// Animations
//---------------------------------------------------------------------------------------------

var defaultPosition = 27;
var position = "up";
var speed = 3;
var scrollDownControl = "";
var scrollUpControl = "";
var tipAnim = new TipAnimationStates();
TipAnimationStates.prototype.SetAnimState = SetAnimState;
TipAnimationStates.prototype.GetAnimState = GetAnimState;
TipAnimationStates.prototype.SetMenuState = SetMenuState;
TipAnimationStates.prototype.GetMenuState = GetMenuState;

//---------------------------------------------------------------------------------------------
function stopScrolling()
{
	clearTimeout( scrollDownControl );
	clearTimeout( scrollUpControl );
}

//---------------------------------------------------------------------------------------------
function scrollDown()
{
	clearTimeout(scrollUpControl);
	moveDown();
	scrollDownControl = setTimeout( "scrollDown()", 10 );
}

//---------------------------------------------------------------------------------------------
function moveDown()
{
	if ( parseInt( crossobj.style.top ) >= ( (-1) * (contentheight - 175)) ) {
		crossobj.style.top = parseInt( crossobj.style.top ) - speed + "px";
	}
}

//---------------------------------------------------------------------------------------------
function scrollUp()
{
	clearTimeout(scrollDownControl);
	moveUp();
	scrollUpControl = setTimeout( "scrollUp()", 10 );
}

//---------------------------------------------------------------------------------------------
function moveUp()
{
	if (parseInt( crossobj.style.top ) <= 0) {
		crossobj.style.top = parseInt( crossobj.style.top ) + speed + "px";
	}
}

//---------------------------------------------------------------------------------------------
function scrollingSetup()
{
	contentheight = crossobj.offsetHeight;
	if ( ! (parseInt( crossobj.style.top ) >= ( (-1) * ( contentheight - 175 ) ) ) ) {
		document.getElementById( "scrollUp" ).style.visibility = "hidden";
		document.getElementById( "scrollDown" ).style.visibility = "hidden";
	}
}

//---------------------------------------------------------------------------------------------
function ToggleMenu( menuDivName, initialPosition, restPosition, divHeight )
{
	if ( position == "up" )	{
		ShowDropDown( menuDivName, restPosition, divHeight );
	}
	else {
		HideDropDown( menuDivName, initialPosition, restPosition, divHeight );
	}
}

//---------------------------------------------------------------------------------------------
function ShowDropDown( menuDivName, initialPosition, divHeight )
{
	position = "down";
	document.getElementById( menuDivName ).style.top = initialPosition + "px";
	var currentPosition = initialPosition;
	var timeout = 0;
	
	for ( var i = 1; i <= 60; i++) {
		currentPosition += (divHeight/60);
		timeout += i/5;
		setTimeout( "MoveMenu(\'" + menuDivName + "\', " + currentPosition + ")", timeout );
	}
}

//---------------------------------------------------------------------------------------------
function HideDropDown( menuDivName, initialPosition, restPosition, divHeight )
{
	position = "up";
	var currentPosition = initialPosition.toInt();
	var timeout = 0;
	
	for ( var i = ((Math.abs( initialPosition - restPosition ))/100)*60; i >= 0; i--) {
		currentPosition -= (divHeight/60);
		timeout += i/5;
		setTimeout( "MoveMenu(\'" + menuDivName + "\', " + currentPosition + ")", timeout );
	}
}

//---------------------------------------------------------------------------------------------
function MoveMenu( menuDivName, currentPosition )
{
	document.getElementById( menuDivName ).style.top = currentPosition + "px";
}

//---------------------------------------------------------------------------------------------
function ParseDivPosition( stringValue )
{
	return stringValue.substr( 0, stringValue.length - 2 );
}

//---------------------------------------------------------------------------------------------
function OpenDoors()
{
	if ( !_doorsOpened ) {
	
		_doorsOpened = true;
		
		document.getElementById( "loadingicon" ).style.visibility = "hidden";
		
		var currentPositionLeft = ParseDivPosition( document.getElementById( "loadingDoorLeft" ).style.left ).toInt();
		var currentPositionRight = ParseDivPosition( document.getElementById( "loadingDoorRight" ).style.left ).toInt();
		var timeout = 0;
		var totalDistance = 560;

		for ( var i = 60; i >= 0; i--) {
			currentPositionRight += (560/60);
			currentPositionLeft -= (560/60);
			timeout += i/5;
			setTimeout( "MoveDoor(\'loadingDoorRight\', " + currentPositionRight + ")", timeout );
			setTimeout( "MoveDoor(\'loadingDoorLeft\', " + currentPositionLeft + ")", timeout );
		}
		timeout += i/5;
		setTimeout( "HideDiv(\'loadingDoorRight\')", timeout );
		setTimeout( "HideDiv(\'loadingDoorLeft\')", timeout );
		if ( _displayAds && !_isTimedOut ) {
			setTimeout( "ShowDiv(\'config_banner\')", timeout );
		}
		
	}
}

//---------------------------------------------------------------------------------------------
function MoveDoor( menuDivName, currentPosition )
{
	document.getElementById( menuDivName ).style.left = currentPosition + "px";
}

//---------------------------------------------------------------------------------------------
function TipAnimationStates()
{
	this.tooltip_community = false;
	this.tooltip_gameinfo = false;
	this.tooltip_leaderboards = false;
	
	this.tooltip_community_menu = false;
	this.tooltip_gameinfo_menu = false;
	this.tooltip_leaderboards_menu = false;
}

//---------------------------------------------------------------------------------------------
function SetAnimState( divName, value )
{
	switch( divName )
	{
		case "tooltip_community":
		{
			this.tooltip_community = value;
			break;
		}
		case "tooltip_gameinfo":
		{	this.tooltip_gameinfo = value;
			break;
		}
		case "tooltip_leaderboards":
		{
			this.tooltip_leaderboards = value;
			break;
		}
	}
}

//---------------------------------------------------------------------------------------------
function GetAnimState( divName )
{
	switch( divName )
	{
		case "tooltip_community":
		{
			return this.tooltip_community;
			break;
		}
		case "tooltip_gameinfo":
		{
			return this.tooltip_gameinfo;
			break;
		}
		case "tooltip_leaderboards":
		{	return this.tooltip_leaderboards;
			break;
		}
	}
}

//---------------------------------------------------------------------------------------------
function SetMenuState( divName, value )
{
	switch( divName )
	{
		case "tooltip_community":
		{
			this.tooltip_community_menu = value;
			break;
		}
		case "tooltip_gameinfo":
		{
			this.tooltip_gameinfo_menu = value;
			break;
		}
		case "tooltip_leaderboards":
		{
			this.tooltip_leaderboards_menu = value;
			break;
		}
	}
}

//---------------------------------------------------------------------------------------------
function GetMenuState( divName )
{
	switch( divName )
	{
		case "tooltip_community":
		{
			return this.tooltip_community_menu;
			break;
		}
		case "tooltip_gameinfo":
		{
			return this.tooltip_gameinfo_menu;
			break;
		}
		case "tooltip_leaderboards":
		{
			return this.tooltip_leaderboards_menu;
			break;
		}
	}
}

//---------------------------------------------------------------------------------------------
function ShowToolTip( divName )
{
	if ( !tipAnim.GetAnimState( divName ) && !tipAnim.GetMenuState( divName ) ) {
		var timeout = 0;			
		tipAnim.SetAnimState( divName, true );
		
		document.getElementById( divName + "_bg" ).style.visibility = "visible";
		document.getElementById( divName ).style.visibility = "visible";
		
		for ( var i = 1; i <= 10; i++) {
			timeout = 10*i;
			setTimeout( "document.getElementById(\'" + divName + "\').style.filter = \'alpha(opacity=" + ((i*10)-5) + ")\';", timeout );
			setTimeout( "document.getElementById(\'" + divName + "_bg\').style.filter = \'alpha(opacity=" + ((i*10)-5) + ")\';", timeout );
			if ( i == 10 ) {
				setTimeout( "tipAnim.SetAnimState(\'" + divName + "\', false);", timeout );
				setTimeout( "tipAnim.SetMenuState(\'" + divName + "\', true);", timeout );
			}
		}
	}
	else {
		setTimeout( "document.getElementById(\'" + divName + "_bg\').style.visibility = \'visible\';", 100 );
		setTimeout( "document.getElementById(\'" + divName + "\').style.visibility = \'visible\';", 100 );
		setTimeout( "document.getElementById(\'" + divName + "_bg\').style.filter = \'alpha(opacity=95)\';", 100 );
		setTimeout( "document.getElementById(\'" + divName + "\').style.filter = \'alpha(opacity=95)\';", 100) ;
	}
}

//---------------------------------------------------------------------------------------------
function HideToolTip( divName )
{
	if ( !tipAnim.GetAnimState( divName ) && tipAnim.GetMenuState( divName ) ) {
		var timeout = 0;
		tipAnim.SetAnimState( divName, true );
		
		for ( var i = 9; i >= 0; i--) {
			timeout = 190 - 10*i;
			setTimeout( "document.getElementById(\'" + divName + "\').style.filter = \'alpha(opacity=" + i*10 + ")\';", timeout );
			setTimeout( "document.getElementById(\'" + divName + "_bg\').style.filter = \'alpha(opacity=" + i*10 + ")\';", timeout );
			if ( i == 0 ) {
				setTimeout( "tipAnim.SetAnimState(\'" + divName +"\', false);", timeout );
				setTimeout( "tipAnim.SetMenuState(\'" + divName +"\', false);", timeout );
			}
		}
		
		setTimeout( "document.getElementById(\'" + divName + "_bg\').style.visibility = \'hidden\';", 190 );
		setTimeout( "document.getElementById(\'" + divName + "\').style.visibility = \'hidden\';", 190 );
	}
	else {
		setTimeout( "document.getElementById(\'" + divName + "_bg\').style.filter = \'alpha(opacity=0)\';", 100 );
		setTimeout( "document.getElementById(\'" + divName + "\').style.filter = \'alpha(opacity=0)\';", 100 );
		setTimeout( "document.getElementById(\'" + divName + "_bg\').style.visibility = \'hidden\';", 100 );
		setTimeout( "document.getElementById(\'" + divName + "\').style.visibility = \'hidden\';", 100 );
	}
}

//---------------------------------------------------------------------------------------------
// End Animations
//---------------------------------------------------------------------------------------------