// SPDX-License-Identifier: GPL-2.0-only
class FirstContractInfo extends GSInfo {
    function GetAuthor() { return "Industry Empire"; }
    function GetName() { return "First Contract"; }
    function GetShortName() { return "IEFC"; }
    function GetDescription() { return "A purchase-first freight business career with real cargo delivery, contracts, overhead and reputation."; }
    function GetVersion() { return 1; }
    function MinVersionToLoad() { return 1; }
    function GetDate() { return "20261029"; }
    function CreateInstance() { return "FirstContract"; }
    function GetAPIVersion() { return "14"; }
}
RegisterGS(FirstContractInfo());
