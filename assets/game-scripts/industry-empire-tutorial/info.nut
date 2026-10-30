class FirstRouteInfo extends GSInfo {
	function GetAuthor()      { return "Industry Empire"; }
	function GetName()        { return "First Route"; }
	function GetShortName()   { return "IERT"; }
	function GetDescription() { return "Two short chapters: a bus route, then your first cargo contract. Skip or replay from the story book."; }
	function GetVersion()     { return 2; }
	function MinVersionToLoad() { return 1; }
	function GetDate()        { return "20261030"; }
	function CreateInstance() { return "FirstRoute"; }
	function GetAPIVersion()  { return "14"; }
	function GetURL()         { return ""; }
}

RegisterGS(FirstRouteInfo());
